import 'dart:convert';
import 'dart:io';

import 'package:chaengo/data/backup/backup_codec.dart';
import 'package:chaengo/data/database.dart';
import 'package:chaengo/data/seed/built_in_icon_updates.dart';
import 'package:chaengo/data/seed/seed_loader.dart';
import 'package:chaengo/domain/models/item.dart';
import 'package:chaengo/domain/models/item_category.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
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
  late AppDatabase db;
  late SeedLoader loader;
  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    loader = SeedLoader(db, bundle: _DiskBundle());
  });
  tearDown(() => db.close());

  Future<void> setLegacyIcons() async {
    for (final e in builtInIconUpdates.entries) {
      await (db.update(db.items)..where((t) => t.id.equals(e.key))).write(
        ItemsCompanion(iconKey: Value(e.value.previous)),
      );
    }
  }

  test(
    'fresh seed uses approved assets and keeps rope on its fallback',
    () async {
      await loader.ensureSeeded();
      for (final e in builtInIconUpdates.entries) {
        final item = (await db.itemDao.findById(e.key))!;
        expect(item.iconKey, e.value.current, reason: e.key);
        expect(File('assets/icons/${item.iconKey}.svg').existsSync(), isTrue);
      }
      expect((await db.itemDao.findById('pegs'))!.iconKey, 'ic_peg');
      expect(
        (await db.itemDao.findById('peg_hammer'))!.iconKey,
        'ic_peg_hammer',
      );
      expect((await db.itemDao.findById('gas'))!.iconKey, 'ic_gas_canister');
      expect((await db.itemDao.findById('butane'))!.iconKey, 'ic_butane');
      expect((await db.itemDao.findById('rope'))!.iconKey, isNull);
      expect(File('assets/icons/ic_rope.svg').existsSync(), isFalse);
    },
  );

  test(
    'existing DB refresh preserves custom glyphs and unrelated data',
    () async {
      await loader.ensureSeeded();
      await setLegacyIcons();
      final heater = (await db.itemDao.findById('heater'))!;
      await db.itemDao.updateItem(heater.copyWith(defaultQty: 3));
      await db.itemDao.setHidden('heater', hidden: true);
      final jacket = (await db.itemDao.findById('jacket'))!;
      await db.itemDao.updateItem(
        jacket.copyWith(iconKey: () => Item.emojiIconKey('🧥')),
      );
      final speaker = (await db.itemDao.findById('speaker'))!;
      await db.itemDao.updateItem(
        speaker.copyWith(iconKey: () => 'ic_lantern'),
      );
      final custom = await db.itemDao.createCustomItem(
        name: '내 에어펌프',
        category: ItemCategory.bedding,
      );
      final before = jsonDecode(
        await BackupCodec(db).exportJson(),
      ) as Map<String, dynamic>;
      await loader.ensureSeeded();
      for (final e in builtInIconUpdates.entries) {
        if (e.key == 'jacket' || e.key == 'speaker') continue;
        expect((await db.itemDao.findById(e.key))!.iconKey, e.value.current);
      }
      expect(
        (await db.itemDao.findById('jacket'))!.glyph,
        const EmojiGlyph('🧥'),
      );
      expect((await db.itemDao.findById('speaker'))!.iconKey, 'ic_lantern');
      expect((await db.itemDao.findById(custom))!.iconKey, isNull);
      final updatedHeater = (await db.itemDao.findById('heater'))!;
      expect(updatedHeater.defaultQty, 3);
      expect(updatedHeater.isHidden, isTrue);
      final after = jsonDecode(
        await BackupCodec(db).exportJson(),
      ) as Map<String, dynamic>;
      expect(after['sets'], before['sets']);
      expect(after['trips'], before['trips']);
      final snapshot = await db.select(db.items).get();
      await loader.ensureSeeded();
      expect(await db.select(db.items).get(), snapshot);
    },
  );

  test(
    'legacy backup restore also refreshes defaults without removing items',
    () async {
      await loader.ensureSeeded();
      await setLegacyIcons();
      final codec = BackupCodec(db);
      final legacy = codec.parse(await codec.exportJson());
      final count = (await db.select(db.items).get()).length;
      await codec.restore(legacy);
      for (final e in builtInIconUpdates.entries) {
        expect((await db.itemDao.findById(e.key))!.iconKey, e.value.current);
      }
      expect((await db.select(db.items).get()).length, count);
      expect((await db.itemDao.findById('rope'))!.iconKey, isNull);
    },
  );
}
