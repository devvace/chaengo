import 'dart:convert';
import 'dart:io';

import 'package:chaengo/data/database.dart';
import 'package:chaengo/data/seed/seed_loader.dart';
import 'package:chaengo/domain/models/app_settings.dart';
import 'package:chaengo/domain/models/item.dart';
import 'package:chaengo/domain/models/item_category.dart';
import 'package:chaengo/domain/models/trip.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트에서는 pubspec 에셋 번들 대신 저장소의 파일을 그대로 읽는다.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      File(key).readAsString();
}

void main() {
  late AppDatabase db;
  late SeedLoader loader;

  setUp(() async {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    loader = SeedLoader(db, bundle: _DiskBundle());
  });

  tearDown(() => db.close());

  DateTime at(int day) => DateTime(2026, 10, day);

  group('시드', () {
    test('seed_items.json을 읽어 내장 아이템·내장 세트를 넣는다', () async {
      await loader.ensureSeeded();

      final items = await db.itemDao.watchItems().first;
      final sets = await db.setDao.watchSets().first;

      final raw = jsonDecode(
        await File(SeedLoader.assetPath).readAsString(),
      ) as Map<String, dynamic>;
      expect(items, hasLength((raw['items'] as List).length));
      expect(items.every((i) => i.isBuiltIn), isTrue);
      expect(sets, hasLength(1));
      expect(sets.single.set.name, '기본 오토캠핑');
      expect(sets.single.set.isBuiltIn, isTrue);
      expect(sets.single.entries, hasLength(29));
    });

    test('두 번 호출해도 중복되지 않는다', () async {
      await loader.ensureSeeded();
      final before = await db.itemDao.watchItems().first;
      await loader.ensureSeeded();
      final after = await db.itemDao.watchItems().first;
      expect(after.length, before.length);
    });

    test('아이콘이 null인 아이템은 카테고리 아이콘으로 폴백한다', () async {
      await loader.ensureSeeded();
      final poles = await db.itemDao.findById('poles');
      expect(poles!.iconKey, isNull);
      expect(poles.glyph, SvgGlyph(ItemCategory.tent.iconKey));

      final tent = await db.itemDao.findById('tent');
      expect(tent!.glyph, const SvgGlyph('ic_tent'));
    });

    test('내장 아이템 수정은 이름·카테고리를 무시하고 아이콘·수량만 바꾼다', () async {
      await loader.ensureSeeded();
      final tent = (await db.itemDao.findById('tent'))!;
      await db.itemDao.updateItem(
        tent.copyWith(
          name: '바꾼 이름',
          category: ItemCategory.misc,
          iconKey: () => Item.emojiIconKey('⛺'),
          defaultQty: 2,
        ),
      );
      final after = (await db.itemDao.findById('tent'))!;
      expect(after.name, tent.name);
      expect(after.category, tent.category);
      expect(after.glyph, const EmojiGlyph('⛺'));
      expect(after.defaultQty, 2);
    });

    test('커스텀 아이템의 카테고리를 옮기면 새 카테고리 맨 뒤로 간다', () async {
      await loader.ensureSeeded();
      final id = await db.itemDao.createCustomItem(
        name: '사이드월',
        category: ItemCategory.tent,
      );
      final item = (await db.itemDao.findById(id))!;
      await db.itemDao.updateItem(item.copyWith(category: ItemCategory.misc));
      final misc = await db.itemDao
          .watchItems(category: ItemCategory.misc)
          .first;
      expect(misc.last.id, id);
    });

    test('이모지 아이콘은 접두어로 구분된다', () async {
      final id = await db.itemDao.createCustomItem(
        name: '바구니',
        category: ItemCategory.misc,
        iconKey: Item.emojiIconKey('🧺'),
      );
      final item = await db.itemDao.findById(id);
      expect(item!.iconKey, 'emoji:🧺');
      expect(item.glyph, const EmojiGlyph('🧺'));
      // 접두어만 있고 내용이 비면 카테고리 아이콘으로 폴백.
      expect(
        item.copyWith(iconKey: () => Item.emojiPrefix).glyph,
        SvgGlyph(ItemCategory.misc.iconKey),
      );
    });

    test('schemaVersion이 다르면 거부한다', () async {
      final bad = SeedLoader(db, bundle: _BrokenBundle({'schemaVersion': 99}));
      expect(bad.seed(), throwsA(isA<SeedFormatException>()));
    });

    test('카테고리가 enum과 어긋나면 거부한다', () async {
      final bad = SeedLoader(
        db,
        bundle: _BrokenBundle({
          'schemaVersion': kSchemaVersion,
          'categories': [
            for (final c in ItemCategory.values)
              {
                'id': c == ItemCategory.misc ? 'other' : c.id,
                'name': c.label,
                'icon': c.iconKey,
                'order': c.order,
              },
          ],
          'items': <Object>[],
          'sets': <Object>[],
        }),
      );
      expect(bad.seed(), throwsA(isA<SeedFormatException>()));
    });
  });

  group('아이템', () {
    setUp(() => loader.ensureSeeded());

    test('내장 아이템은 삭제할 수 없고 숨김만 된다', () async {
      expect(
        () => db.itemDao.deleteCustomItem('tent'),
        throwsA(isA<StateError>()),
      );

      await db.itemDao.setHidden('tent', hidden: true);
      final visible = await db.itemDao.watchItems().first;
      expect(visible.any((i) => i.id == 'tent'), isFalse);

      final hidden = await db.itemDao.watchHiddenItems().first;
      expect(hidden.map((i) => i.id), contains('tent'));
    });

    test('검색은 숨김 아이템을 선택적으로 포함한다', () async {
      await db.itemDao.setHidden('tent', hidden: true);
      expect(
        (await db.itemDao.watchItems(search: '텐트').first).map((i) => i.id),
        isNot(contains('tent')),
      );
      expect(
        (await db.itemDao.watchItems(search: '텐트', includeHidden: true).first)
            .map((i) => i.id),
        contains('tent'),
      );
    });

    test('커스텀 아이템을 지우면 담겨 있던 세트에서도 빠진다', () async {
      final itemId = await db.itemDao.createCustomItem(
        name: '화목난로',
        category: ItemCategory.fire,
        defaultQty: 1,
      );
      final setId = await db.setDao.createSet(
        name: '겨울',
        entries: {itemId: 1, 'tent': 1},
      );

      await db.itemDao.deleteCustomItem(itemId);

      final detail = await db.setDao.watchSetDetail(setId).first;
      expect(detail!.entries.map((e) => e.item.id), ['tent']);
    });

    test('세트 k곳은 캐시 없이 집계된다', () async {
      await db.setDao.createSet(name: '여름', entries: {'tent': 1, 'tarp': 1});
      await db.setDao.createSet(name: '겨울', entries: {'tent': 1});

      final counts = await db.itemDao.watchSetCounts().first;
      // 기본 세트 1 + 여름 + 겨울
      expect(counts['tent'], 3);
      expect(counts['tarp'], 2);
      expect(counts['cot'], isNull);
    });

    test('수량은 1–99를 벗어날 수 없다', () async {
      expect(
        () => db.itemDao.createCustomItem(
          name: '팩',
          category: ItemCategory.tent,
          defaultQty: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('기본 n · 커스텀 m을 센다', () async {
      await db.itemDao.createCustomItem(
        name: '우드테이블',
        category: ItemCategory.cooking,
      );
      final counts = await db.itemDao.watchCounts().first;
      expect(counts.custom, 1);
      expect(counts.builtIn, greaterThan(50));
    });
  });

  group('세트', () {
    setUp(() => loader.ensureSeeded());

    test('복제하면 "○○ 복사"로 구성까지 따라온다', () async {
      final sets = await db.setDao.watchSets().first;
      final origin = sets.single;

      final copyId = await db.setDao.duplicateSet(origin.set.id);
      final copy = await db.setDao.watchSetDetail(copyId).first;

      expect(copy!.set.name, '기본 오토캠핑 복사');
      expect(copy.set.isBuiltIn, isFalse);
      expect(copy.entries.length, origin.entries.length);
    });

    test('기본 세트는 삭제할 수 없다', () async {
      final sets = await db.setDao.watchSets().first;
      expect(
        () => db.setDao.deleteSet(sets.single.set.id),
        throwsA(isA<StateError>()),
      );
    });

    test('진행 중 트립이 쓰는 세트는 삭제할 수 없다', () async {
      final setId = await db.setDao.createSet(name: '가을', entries: {'tent': 1});
      await db.tripDao.createTrip(
        name: '가을 캠핑',
        startDate: at(10),
        endDate: at(11),
        setId: setId,
      );
      expect(await db.setDao.isInUse(setId), isTrue);
      expect(() => db.setDao.deleteSet(setId), throwsA(isA<StateError>()));
    });

    test('목록은 기본 세트가 맨 위, 나머지는 마지막 사용일 내림차순', () async {
      final a = await db.setDao.createSet(name: 'A');
      final b = await db.setDao.createSet(name: 'B');
      await db.setDao.touchLastUsed(a, at(1));
      await db.setDao.touchLastUsed(b, at(5));

      final sets = await db.setDao.watchSets().first;
      expect(sets.map((s) => s.set.name).toList(), ['기본 오토캠핑', 'B', 'A']);
    });
  });

  group('세트 편집 저장', () {
    test('updateSet은 이름과 구성을 함께 바꾼다', () async {
      await loader.ensureSeeded();
      final setId = await db.setDao.createSet(
        name: '여름',
        entries: const {'tent': 1},
      );
      await db.setDao.updateSet(
        setId,
        name: '여름 트렁크',
        entries: const {'tarp': 2},
      );
      final detail = await db.setDao.watchSetDetail(setId).first;
      expect(detail!.set.name, '여름 트렁크');
      expect(await db.setDao.getEntries(setId), {'tarp': 2});
    });
  });

  group('트립', () {
    setUp(() => loader.ensureSeeded());

    Future<String> createFromDefaultSet() async {
      final sets = await db.setDao.watchSets().first;
      return db.tripDao.createTrip(
        name: '10월 캠핑',
        startDate: at(10),
        endDate: at(12),
        setId: sets.single.set.id,
      );
    }

    test('생성 시 세트 구성을 복사하고, 이후 세트 수정은 영향이 없다', () async {
      final sets = await db.setDao.watchSets().first;
      final setId = sets.single.set.id;
      final tripId = await createFromDefaultSet();

      final before = await db.tripDao.watchTripDetail(tripId).first;
      expect(before!.items, hasLength(29));

      // 원본 세트를 비워도
      await db.setDao.saveEntries(setId, const {});

      final after = await db.tripDao.watchTripDetail(tripId).first;
      expect(after!.items, hasLength(29));
    });

    test('트립 생성은 원본 세트의 마지막 사용일을 갱신한다', () async {
      final sets = await db.setDao.watchSets().first;
      expect(sets.single.set.lastUsedAt, isNull);
      await createFromDefaultSet();
      final updated = await db.setDao.watchSets().first;
      expect(updated.single.set.lastUsedAt, isNotNull);
    });

    test('진행 중 구독은 완료·새 트립 생성을 따라간다', () async {
      final firstId = await createFromDefaultSet();
      final seen = <String?>[];
      final sub = db.tripDao.watchActiveTrip().listen(
        (detail) => seen.add(detail?.trip.name),
      );
      Future<void> settle() =>
          Future<void>.delayed(const Duration(milliseconds: 50));

      await settle();
      await db.tripDao.completeTrip(firstId);
      await settle();
      await db.tripDao.createTrip(
        name: '11월 캠핑',
        startDate: at(20),
        endDate: at(21),
      );
      await settle();
      await sub.cancel();

      expect(seen.first, '10월 캠핑');
      expect(seen, contains(null));
      expect(seen.last, '11월 캠핑');
    });

    test('커스텀 아이템을 지우면 완료된 트립에서도 빠진다', () async {
      final itemId = await db.itemDao.createCustomItem(
        name: '사이드월',
        category: ItemCategory.tent,
      );
      final tripId = await createFromDefaultSet();
      await db.tripDao.addItems(tripId, [itemId]);
      await db.tripDao.completeTrip(tripId);

      await db.itemDao.deleteCustomItem(itemId);

      final detail = await db.tripDao.watchTripDetail(tripId).first;
      expect(detail!.items.map((i) => i.item.id), isNot(contains(itemId)));
      expect(detail.items, hasLength(29));
    });

    test('숨긴 아이템은 세트에 남지만 목록에서 빠지고 트립으로 복사되지 않는다', () async {
      final setId = (await db.setDao.watchSets().first).single.set.id;
      await db.itemDao.setHidden('tent', hidden: true);

      expect(await db.setDao.getEntries(setId), contains('tent'));
      final detail = (await db.setDao.watchSets().first).single;
      expect(detail.entries.map((e) => e.item.id), isNot(contains('tent')));
      expect(detail.itemCount, 28);

      final tripId = await createFromDefaultSet();
      final trip = await db.tripDao.watchTripDetail(tripId).first;
      expect(trip!.items.map((i) => i.item.id), isNot(contains('tent')));
      expect(trip.items, hasLength(28));

      // 숨김을 풀면 세트에 그대로 돌아온다.
      await db.itemDao.setHidden('tent', hidden: false);
      expect((await db.setDao.watchSets().first).single.itemCount, 29);
    });

    test('active 트립은 하나뿐이다', () async {
      await createFromDefaultSet();
      expect(
        () => db.tripDao.createTrip(
          name: '겹치는 트립',
          startDate: at(20),
          endDate: at(21),
        ),
        throwsA(isA<StateError>()),
      );

      final active = await db.tripDao.findActiveTrip();
      await db.tripDao.completeTrip(active!.id);

      final second = await db.tripDao.createTrip(
        name: '다음 트립',
        startDate: at(20),
        endDate: at(21),
      );
      expect(second, isNotEmpty);
    });

    test('DAO를 우회해도 DB가 active 트립 둘을 막는다', () async {
      await createFromDefaultSet();
      expect(
        db
            .into(db.trips)
            .insert(
              TripsCompanion.insert(
                id: 'bypass',
                name: '우회',
                startDate: at(20),
                endDate: at(21),
                status: TripStatus.active,
                createdAt: DateTime.now(),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('진행률 분모에서 제외 아이템을 뺀다', () async {
      final tripId = await createFromDefaultSet();
      await db.tripDao.setItemState(tripId, 'tent', PackState.packed);
      await db.tripDao.setItemState(tripId, 'tarp', PackState.excluded);

      final detail = await db.tripDao.watchTripDetail(tripId).first;
      final progress = detail!.progress;
      expect(progress.packed, 1);
      expect(progress.excluded, 1);
      expect(progress.total, 28);
      expect(progress.remaining, 27);
    });

    test('제외 타일은 탭에 반응하지 않는다', () {
      const excluded = PackState.excluded;
      expect(
        TripItem(item: _dummyItem, qty: 1, state: excluded).toggled,
        PackState.excluded,
      );
    });

    test('S04 추가는 미챙김으로 들어가고 중복을 만들지 않는다', () async {
      final tripId = await createFromDefaultSet();
      await db.tripDao.addItems(tripId, ['cot', 'tent']);

      final detail = await db.tripDao.watchTripDetail(tripId).first;
      final cot = detail!.items.firstWhere((i) => i.item.id == 'cot');
      expect(cot.state, PackState.unpacked);
      expect(cot.qty, 2); // 시드의 기본 수량
      expect(detail.items.where((i) => i.item.id == 'tent'), hasLength(1));
    });

    test('세트로 저장하면 savedAsSetId가 기록되고, 세트를 지우면 null로 돌아간다', () async {
      final tripId = await createFromDefaultSet();
      await db.tripDao.completeTrip(tripId);

      final setId = await db.tripDao.saveTripAsSet(tripId);
      expect((await db.tripDao.findById(tripId))!.savedAsSetId, setId);

      final saved = await db.setDao.watchSetDetail(setId).first;
      expect(saved!.set.name, '10월 캠핑');
      expect(saved.entries, hasLength(29));

      await db.setDao.deleteSet(setId);
      expect((await db.tripDao.findById(tripId))!.savedAsSetId, isNull);
    });

    test('S06에서 고친 구성으로 세트로 저장할 수 있다', () async {
      final tripId = await createFromDefaultSet();
      await db.tripDao.completeTrip(tripId);

      final setId = await db.tripDao.saveTripAsSet(
        tripId,
        name: '가을 트렁크',
        entries: const {'tent': 1, 'pegs': 20},
      );

      final saved = await db.setDao.watchSetDetail(setId).first;
      expect(saved!.set.name, '가을 트렁크');
      expect(
        {for (final e in saved.entries) e.item.id: e.qty},
        {'tent': 1, 'pegs': 20},
      );
      expect((await db.tripDao.findById(tripId))!.savedAsSetId, setId);
    });

    test('완료 목록은 최신순이다', () async {
      final first = await createFromDefaultSet();
      await db.tripDao.completeTrip(first);
      final second = await db.tripDao.createTrip(
        name: '두 번째',
        startDate: at(20),
        endDate: at(21),
      );
      await db.tripDao.completeTrip(second);

      final done = await db.tripDao.watchDoneTrips().first;
      expect(done.map((d) => d.trip.name).toList(), ['두 번째', '10월 캠핑']);
    });

    test('완료 취소는 진행 중 트립이 따로 있으면 막힌다', () async {
      final first = await createFromDefaultSet();
      await db.tripDao.completeTrip(first);
      await db.tripDao.createTrip(
        name: '진행 중',
        startDate: at(20),
        endDate: at(21),
      );
      expect(() => db.tripDao.reopenTrip(first), throwsA(isA<StateError>()));
    });

    test('트립을 지워도 아이템 원본은 남는다', () async {
      final tripId = await createFromDefaultSet();
      await db.tripDao.deleteTrip(tripId);
      expect(await db.tripDao.findById(tripId), isNull);
      expect(await db.itemDao.findById('tent'), isNotNull);
    });
  });

  group('설정', () {
    test('저장된 값이 없으면 둘 다 기본 ON', () async {
      expect(await db.settingsDao.getSettings(), AppSettings.defaults);
    });

    test('저장하면 구독자에게 반영되고, 전체 초기화 후에도 남는다', () async {
      await loader.ensureSeeded();
      const off = AppSettings(keepScreenOn: false, haptics: false);
      await db.settingsDao.saveSettings(off);
      expect(await db.settingsDao.watchSettings().first, off);

      await loader.resetToSeed();
      expect(await db.settingsDao.getSettings(), off);
    });
  });

  group('초기화', () {
    test('전체 초기화는 사용자 데이터를 지우고 내장 데이터를 복원한다', () async {
      await loader.ensureSeeded();
      await db.itemDao.createCustomItem(
        name: '커스텀',
        category: ItemCategory.misc,
      );
      await db.setDao.createSet(name: '내 세트');
      await db.tripDao.createTrip(name: '트립', startDate: at(1), endDate: at(2));

      await loader.resetToSeed();

      final items = await db.itemDao.watchItems().first;
      final sets = await db.setDao.watchSets().first;
      expect(items.every((i) => i.isBuiltIn), isTrue);
      expect(sets, hasLength(1));
      expect(sets.single.set.isBuiltIn, isTrue);
      expect(await db.tripDao.findActiveTrip(), isNull);
    });
  });
}

final _dummyItem = Item(
  id: 'x',
  name: 'x',
  category: ItemCategory.misc,
  iconKey: null,
  defaultQty: 1,
  isBuiltIn: false,
  isHidden: false,
  sortOrder: 0,
);

class _BrokenBundle extends CachingAssetBundle {
  _BrokenBundle(this.payload);

  final Map<String, Object?> payload;

  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(
    Uint8List.fromList(utf8.encode(jsonEncode(payload))),
  );

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      jsonEncode(payload);
}
