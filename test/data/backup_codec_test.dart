import 'dart:convert';
import 'dart:io';

import 'package:chaengo/data/backup/backup_codec.dart';
import 'package:chaengo/data/database.dart';
import 'package:chaengo/data/seed/seed_loader.dart';
import 'package:chaengo/domain/models/app_settings.dart';
import 'package:chaengo/domain/models/item_category.dart';
import 'package:chaengo/domain/models/trip.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(await File(key).readAsBytes());

  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      File(key).readAsString();
}

void main() {
  late AppDatabase source;
  late AppDatabase target;

  setUp(() async {
    source = AppDatabase.withExecutor(NativeDatabase.memory());
    target = AppDatabase.withExecutor(NativeDatabase.memory());
    await SeedLoader(source, bundle: _DiskBundle()).ensureSeeded();
    await SeedLoader(target, bundle: _DiskBundle()).ensureSeeded();
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  Future<String> buildSourceData() async {
    final custom = await source.itemDao.createCustomItem(
      name: '사이드월',
      category: ItemCategory.tent,
      iconKey: 'emoji:🧱',
      defaultQty: 2,
    );
    await source.itemDao.setHidden('tarp', hidden: true);
    final setId = await source.setDao.createSet(
      name: '여름',
      entries: {'tent': 1, custom: 3},
    );
    final done = await source.tripDao.createTrip(
      name: '8월',
      startDate: DateTime(2026, 8, 14),
      endDate: DateTime(2026, 8, 16),
      setId: setId,
    );
    await source.tripDao.setItemState(done, 'tent', PackState.packed);
    await source.tripDao.completeTrip(done);
    await source.tripDao.saveTripAsSet(done);
    await source.tripDao.createTrip(
      name: '10월',
      startDate: DateTime(2026, 10, 10),
      endDate: DateTime(2026, 10, 11),
    );
    await source.settingsDao.saveSettings(
      const AppSettings(keepScreenOn: false, haptics: true),
    );
    return BackupCodec(source).exportJson(now: DateTime(2026, 10, 3, 12));
  }

  test('내보낸 JSON을 다른 DB에 가져오면 같은 내용이 된다', () async {
    final json = await buildSourceData();
    final codec = BackupCodec(target);
    final data = codec.parse(json);
    expect(data.exportedAt, DateTime(2026, 10, 3, 12));
    await codec.restore(data);

    // 다시 내보내 비교하면 시각만 빼고 동일하다.
    final again = await codec.exportJson(now: DateTime(2026, 10, 3, 12));
    expect(jsonDecode(again), jsonDecode(json));

    final active = await target.tripDao.findActiveTrip();
    expect(active!.name, '10월');
    expect(
      await target.settingsDao.getSettings(),
      const AppSettings(keepScreenOn: false, haptics: true),
    );
    final tarp = await target.itemDao.findById('tarp');
    expect(tarp!.isHidden, isTrue);
  });

  test('schemaVersion이 다르면 막는다', () async {
    final json = jsonDecode(await buildSourceData()) as Map<String, Object?>;
    json['schemaVersion'] = kSchemaVersion + 1;
    expect(
      () => BackupCodec(target).parse(jsonEncode(json)),
      throwsA(isA<BackupVersionException>()),
    );
  });

  test('없는 아이템을 참조하면 형식 오류이고, 기존 데이터는 그대로다', () async {
    final json = jsonDecode(await buildSourceData()) as Map<String, Object?>;
    ((json['sets']! as List).first as Map)['items'] = [
      {'item': 'ghost', 'qty': 1},
    ];
    expect(
      () => BackupCodec(target).parse(jsonEncode(json)),
      throwsA(isA<BackupFormatException>()),
    );
    expect(await target.setDao.watchSets().first, hasLength(1));
  });

  test('JSON이 아니면 형식 오류', () {
    expect(
      () => BackupCodec(target).parse('not json'),
      throwsA(isA<BackupFormatException>()),
    );
  });
}
