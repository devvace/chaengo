import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/gear_set.dart';
import '../../domain/models/trip.dart';
import '../database.dart';
import '../mappers.dart';
import '../tables.dart';

part 'set_dao.g.dart';

/// 세트 목록(S05)·세트 편집(S06)이 쓰는 질의.
@DriftAccessor(tables: [GearSets, GearSetItems, Items, Trips])
class SetDao extends DatabaseAccessor<AppDatabase> with _$SetDaoMixin {
  SetDao(super.db);

  static const _uuid = Uuid();

  /// S05 목록. 기본 세트가 맨 위, 나머지는 마지막 사용일 내림차순.
  /// 아이콘 미리보기 때문에 담긴 아이템까지 함께 읽는다.
  Stream<List<GearSetDetail>> watchSets() {
    final query = select(gearSets).join([
      leftOuterJoin(gearSetItems, gearSetItems.setId.equalsExp(gearSets.id)),
      leftOuterJoin(items, items.id.equalsExp(gearSetItems.itemId)),
    ]);
    return query.watch().map((rows) {
      final details = _groupIntoDetails(rows);
      details.sort(_compareSetsForDisplay);
      return details;
    });
  }

  /// S06 편집 대상 한 건.
  Stream<GearSetDetail?> watchSetDetail(String setId) {
    final query = select(gearSets).join([
      leftOuterJoin(gearSetItems, gearSetItems.setId.equalsExp(gearSets.id)),
      leftOuterJoin(items, items.id.equalsExp(gearSetItems.itemId)),
    ])..where(gearSets.id.equals(setId));
    return query.watch().map((rows) {
      final details = _groupIntoDetails(rows);
      return details.isEmpty ? null : details.first;
    });
  }

  Future<GearSet?> findById(String setId) async {
    final row = await (select(
      gearSets,
    )..where((t) => t.id.equals(setId))).getSingleOrNull();
    return row?.toModel();
  }

  /// 빈 세트 또는 주어진 구성으로 새 세트를 만든다. 생성된 id를 돌려준다.
  Future<String> createSet({
    required String name,
    Map<String, int> entries = const {},
    bool isBuiltIn = false,
    String? id,
  }) async {
    final setId = id ?? _uuid.v4();
    await transaction(() async {
      await into(gearSets).insert(
        GearSetsCompanion.insert(
          id: setId,
          name: name.trim(),
          isBuiltIn: Value(isBuiltIn),
          createdAt: DateTime.now(),
        ),
      );
      await _replaceEntries(setId, entries);
    });
    return setId;
  }

  /// S05 [복제]. 이름은 "○○ 복사", 구성은 그대로 가져간다.
  Future<String> duplicateSet(String setId) async {
    final source = await findById(setId);
    if (source == null) {
      throw StateError('없는 세트를 복제할 수 없다: $setId');
    }
    final entries = await getEntries(setId);
    return createSet(name: '${source.name} 복사', entries: entries);
  }

  Future<void> renameSet(String setId, String name) async {
    await (update(gearSets)..where((t) => t.id.equals(setId))).write(
      GearSetsCompanion(name: Value(name.trim())),
    );
  }

  /// S06 [저장](기존 세트). 이름과 담김 구성을 한 번에 바꾼다.
  Future<void> updateSet(
    String setId, {
    required String name,
    required Map<String, int> entries,
  }) async {
    await transaction(() async {
      await renameSet(setId, name);
      await _replaceEntries(setId, entries);
    });
  }

  /// 담김 구성을 통째로 교체한다.
  Future<void> saveEntries(String setId, Map<String, int> entries) async {
    await transaction(() => _replaceEntries(setId, entries));
  }

  /// 타일 탭 = 담기. 수량은 아이템의 기본 수량을 따른다.
  Future<void> addItem(String setId, String itemId, {int? qty}) async {
    final resolvedQty =
        qty ??
        (await attachedDatabase.itemDao.findById(itemId))?.defaultQty ??
        1;
    requireValidQty(resolvedQty);
    await into(gearSetItems).insertOnConflictUpdate(
      GearSetItemsCompanion.insert(
        setId: setId,
        itemId: itemId,
        qty: Value(resolvedQty),
      ),
    );
  }

  /// 타일 탭 = 빼기.
  Future<void> removeItem(String setId, String itemId) async {
    await (delete(
      gearSetItems,
    )..where((t) => t.setId.equals(setId) & t.itemId.equals(itemId))).go();
  }

  /// 롱프레스 수량 조절(1–99).
  Future<void> setQty(String setId, String itemId, int qty) async {
    requireValidQty(qty);
    await (update(gearSetItems)
          ..where((t) => t.setId.equals(setId) & t.itemId.equals(itemId)))
        .write(GearSetItemsCompanion(qty: Value(qty)));
  }

  /// 진행 중 트립이 이 세트에서 나왔으면 "사용 중"이라 삭제를 막는다.
  Future<bool> isInUse(String setId) async {
    final row =
        await (select(trips)..where(
              (t) =>
                  t.sourceSetId.equals(setId) &
                  t.status.equalsValue(TripStatus.active),
            ))
            .getSingleOrNull();
    return row != null;
  }

  /// S06 [세트 삭제]. 내장 세트와 사용 중 세트는 지울 수 없다.
  Future<void> deleteSet(String setId) async {
    final set = await findById(setId);
    if (set == null) return;
    if (set.isBuiltIn) {
      throw StateError('기본 세트는 삭제할 수 없다: $setId');
    }
    if (await isInUse(setId)) {
      throw StateError('진행 중 트립이 쓰고 있는 세트는 삭제할 수 없다: $setId');
    }
    await (delete(gearSets)..where((t) => t.id.equals(setId))).go();
  }

  /// 이 세트로 트립을 만들 때 호출한다. S05 정렬과 S02 기본 선택의 기준.
  Future<void> touchLastUsed(String setId, DateTime at) async {
    await (update(gearSets)..where((t) => t.id.equals(setId))).write(
      GearSetsCompanion(lastUsedAt: Value(at)),
    );
  }

  /// 아이템 id → 수량. S06 편집 초기값.
  Future<Map<String, int>> getEntries(String setId) async {
    final rows = await (select(
      gearSetItems,
    )..where((t) => t.setId.equals(setId))).get();
    return {for (final row in rows) row.itemId: row.qty};
  }

  Future<void> _replaceEntries(String setId, Map<String, int> entries) async {
    await (delete(gearSetItems)..where((t) => t.setId.equals(setId))).go();
    if (entries.isEmpty) return;
    entries.values.forEach(requireValidQty);
    await batch((b) {
      b.insertAll(gearSetItems, [
        for (final entry in entries.entries)
          GearSetItemsCompanion.insert(
            setId: setId,
            itemId: entry.key,
            qty: Value(entry.value),
          ),
      ]);
    });
  }

  List<GearSetDetail> _groupIntoDetails(List<TypedResult> rows) {
    final sets = <String, GearSet>{};
    final entries = <String, List<GearSetEntry>>{};
    for (final row in rows) {
      final set = row.readTable(gearSets).toModel();
      sets.putIfAbsent(set.id, () => set);
      final bucket = entries.putIfAbsent(set.id, () => <GearSetEntry>[]);
      final itemRow = row.readTableOrNull(items);
      final entryRow = row.readTableOrNull(gearSetItems);
      // 숨긴 아이템은 세트에 남아 있지만(숨김을 풀면 돌아온다) 화면에는
      // 보이지 않는다. 결정(2026-10-03).
      if (itemRow != null && entryRow != null && !itemRow.isHidden) {
        bucket.add(GearSetEntry(item: itemRow.toModel(), qty: entryRow.qty));
      }
    }
    return [
      for (final set in sets.values)
        GearSetDetail(
          set: set,
          entries: entries[set.id]!
            ..sort((a, b) => compareItemsForDisplay(a.item, b.item)),
        ),
    ];
  }

  /// 기본 세트 최상단, 나머지는 마지막 사용일 내림차순(없으면 생성일).
  static int _compareSetsForDisplay(GearSetDetail a, GearSetDetail b) {
    if (a.set.isBuiltIn != b.set.isBuiltIn) {
      return a.set.isBuiltIn ? -1 : 1;
    }
    final aAt = a.set.lastUsedAt ?? a.set.createdAt;
    final bAt = b.set.lastUsedAt ?? b.set.createdAt;
    return bAt.compareTo(aAt);
  }
}
