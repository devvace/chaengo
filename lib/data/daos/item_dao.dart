import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/item.dart';
import '../../domain/models/item_category.dart';
import '../database.dart';
import '../mappers.dart';
import '../tables.dart';

part 'item_dao.g.dart';

/// 창고(S07·S08)와 아이템을 참조하는 화면들이 쓰는 질의.
@DriftAccessor(tables: [Items, GearSetItems])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(super.db);

  static const _uuid = Uuid();

  /// [includeHidden]은 S07 검색에서만 true다(숨김 아이템을 회색으로 보여준다).
  Stream<List<Item>> watchItems({
    ItemCategory? category,
    String search = '',
    bool includeHidden = false,
  }) {
    final query = select(items);
    if (!includeHidden) {
      query.where((t) => t.isHidden.equals(false));
    }
    if (category != null) {
      query.where((t) => t.category.equalsValue(category));
    }
    final keyword = search.trim();
    if (keyword.isNotEmpty) {
      query.where(
        (t) => t.name.like('%${escapeLike(keyword)}%', escapeChar: r'\'),
      );
    }
    return query.watch().map(_toSortedModels);
  }

  /// 세트 편집(S06) 그리드가 쓰는 전체 아이템. 숨김은 빠진다.
  Stream<List<Item>> watchVisibleItems() => watchItems();

  /// 설정 > 숨긴 아이템 보기(S09).
  Stream<List<Item>> watchHiddenItems() => (select(
    items,
  )..where((t) => t.isHidden.equals(true))).watch().map(_toSortedModels);

  Future<Item?> findById(String id) async {
    final row = await (select(
      items,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.toModel();
  }

  Future<List<Item>> getByIds(Iterable<String> ids) async {
    final wanted = ids.toList();
    if (wanted.isEmpty) return const [];
    final rows = await (select(items)..where((t) => t.id.isIn(wanted))).get();
    return _toSortedModels(rows);
  }

  /// S07 앱바의 "기본 n · 커스텀 m".
  Stream<({int builtIn, int custom})> watchCounts() {
    final total = items.id.count();
    final query = selectOnly(items)
      ..addColumns([items.isBuiltIn, total])
      ..groupBy([items.isBuiltIn]);
    return query.watch().map((rows) {
      var builtIn = 0;
      var custom = 0;
      for (final row in rows) {
        final count = row.read(total) ?? 0;
        if (row.read(items.isBuiltIn) ?? false) {
          builtIn = count;
        } else {
          custom = count;
        }
      }
      return (builtIn: builtIn, custom: custom);
    });
  }

  /// S07 행의 "세트 k곳". 캐시 컬럼 없이 매번 집계한다.
  /// 담긴 세트가 없는 아이템은 결과 맵에 들어 있지 않다(= 0곳).
  Stream<Map<String, int>> watchSetCounts() {
    final count = gearSetItems.setId.count();
    final query = selectOnly(gearSetItems)
      ..addColumns([gearSetItems.itemId, count])
      ..groupBy([gearSetItems.itemId]);
    return query.watch().map(
      (rows) => {
        for (final row in rows)
          row.read(gearSetItems.itemId)!: row.read(count) ?? 0,
      },
    );
  }

  /// 같은 이름의 아이템이 이미 있는지(S08의 "이미 있는 아이템 → 열기").
  /// [builtInOnly]면 내장 아이템만 찾는다.
  Future<Item?> findByName(
    String name, {
    String? excludeId,
    bool builtInOnly = false,
  }) async {
    final query = select(items)..where((t) => t.name.equals(name.trim()));
    if (builtInOnly) {
      query.where((t) => t.isBuiltIn.equals(true));
    }
    if (excludeId != null) {
      query.where((t) => t.id.equals(excludeId).not());
    }
    final rows = await (query..limit(1)).get();
    return rows.isEmpty ? null : rows.first.toModel();
  }

  /// 커스텀 아이템 추가(S08). 생성된 id를 돌려준다.
  Future<String> createCustomItem({
    required String name,
    required ItemCategory category,
    String? iconKey,
    int defaultQty = 1,
  }) async {
    requireValidQty(defaultQty);
    final id = _uuid.v4();
    await into(items).insert(
      ItemsCompanion.insert(
        id: id,
        name: name.trim(),
        category: category,
        iconKey: Value(iconKey),
        defaultQty: Value(defaultQty),
        isBuiltIn: const Value(false),
        sortOrder: Value(await _nextSortOrder(category)),
      ),
    );
    return id;
  }

  /// 아이템 수정(S08). 내장 아이템은 수량·아이콘만 바뀌고, 이름·카테고리는
  /// 넘어온 값과 상관없이 그대로 둔다.
  Future<void> updateItem(Item item) async {
    requireValidQty(item.defaultQty);
    final current = await findById(item.id);
    if (current == null) return;
    final builtIn = current.isBuiltIn;
    var sortOrder = current.sortOrder;
    if (!builtIn && item.category != current.category) {
      // 카테고리를 옮기면 새 카테고리의 맨 뒤에 붙인다.
      sortOrder = await _nextSortOrder(item.category);
    }
    await (update(items)..where((t) => t.id.equals(item.id))).write(
      ItemsCompanion(
        name: builtIn ? const Value.absent() : Value(item.name.trim()),
        category: builtIn ? const Value.absent() : Value(item.category),
        iconKey: Value(item.iconKey),
        defaultQty: Value(item.defaultQty),
        sortOrder: Value(sortOrder),
      ),
    );
  }

  /// 내장 아이템의 '삭제' 대체 수단.
  Future<void> setHidden(String id, {required bool hidden}) async {
    await (update(items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(isHidden: Value(hidden)),
    );
  }

  /// 커스텀 아이템 삭제. 담겨 있던 세트·트립에서도 함께 빠진다(FK cascade).
  /// 내장 아이템은 삭제할 수 없고 숨김만 가능하다.
  Future<void> deleteCustomItem(String id) async {
    final item = await findById(id);
    if (item == null) return;
    if (item.isBuiltIn) {
      throw StateError('내장 아이템은 삭제할 수 없다: $id');
    }
    await (delete(items)..where((t) => t.id.equals(id))).go();
  }

  Future<int> _nextSortOrder(ItemCategory category) async {
    final maxOrder = items.sortOrder.max();
    final row =
        await (selectOnly(items)
              ..addColumns([maxOrder])
              ..where(items.category.equalsValue(category)))
            .getSingle();
    return (row.read(maxOrder) ?? 0) + 1;
  }

  List<Item> _toSortedModels(List<ItemRow> rows) =>
      rows.map((row) => row.toModel()).toList()..sort(compareItemsForDisplay);
}
