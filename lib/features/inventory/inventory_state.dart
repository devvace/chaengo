import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/async_combine.dart';

import '../../data/providers.dart';
import '../../domain/models/item.dart';
import '../../domain/models/item_category.dart';

part 'inventory_state.g.dart';

/// S07 검색어·카테고리 필터.
@immutable
class InventoryFilter {
  const InventoryFilter({this.query = '', this.category});

  final String query;

  /// null = 전체.
  final ItemCategory? category;

  bool get isSearching => query.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is InventoryFilter &&
      other.query == query &&
      other.category == category;

  @override
  int get hashCode => Object.hash(query, category);
}

/// S07 한 화면이 그리는 전부.
@immutable
class InventoryUiState {
  const InventoryUiState({
    required this.filter,
    required this.groups,
    required this.builtInCount,
    required this.customCount,
    required this.setCounts,
  });

  final InventoryFilter filter;

  /// 카테고리 순서대로, 비어 있는 카테고리는 빠진다.
  final List<({ItemCategory category, List<Item> items})> groups;
  final int builtInCount;
  final int customCount;

  /// 아이템 id → 담긴 세트 수. 없으면 0곳.
  final Map<String, int> setCounts;

  int setCountOf(String itemId) => setCounts[itemId] ?? 0;
  bool get isEmpty => groups.isEmpty;
}

@riverpod
class InventoryFilterController extends _$InventoryFilterController {
  @override
  InventoryFilter build() => const InventoryFilter();

  void setQuery(String query) =>
      state = InventoryFilter(query: query, category: state.category);

  void setCategory(ItemCategory? category) =>
      state = InventoryFilter(query: state.query, category: category);
}

/// 필터를 family 인자로 받지 않고 안에서 watch한다. 그래야 필터가 바뀌어
/// 다시 구독하는 동안에도 이전 결과를 유지해 목록이 깜빡이지 않는다.
@riverpod
Stream<List<Item>> _inventoryItems(Ref ref) {
  final filter = ref.watch(inventoryFilterControllerProvider);
  return ref
      .watch(itemDaoProvider)
      .watchItems(
        category: filter.category,
        search: filter.query,
        // 검색 중에만 숨김 아이템도 결과에 넣는다(회색).
        includeHidden: filter.isSearching,
      );
}

@riverpod
Stream<({int builtIn, int custom})> _inventoryCounts(Ref ref) =>
    ref.watch(itemDaoProvider).watchCounts();

@riverpod
Stream<Map<String, int>> _inventorySetCounts(Ref ref) =>
    ref.watch(itemDaoProvider).watchSetCounts();

@riverpod
AsyncValue<InventoryUiState> inventoryUiState(Ref ref) {
  final seeded = ref.watch(seedBootstrapProvider);
  final filter = ref.watch(inventoryFilterControllerProvider);
  final itemsAsync = ref.watch(_inventoryItemsProvider);
  final countsAsync = ref.watch(_inventoryCountsProvider);
  final setCountsAsync = ref.watch(_inventorySetCountsProvider);

  return combineAsync([seeded, itemsAsync, countsAsync, setCountsAsync], () {
    final items = itemsAsync.requireValue;
    final counts = countsAsync.requireValue;
    final groups = [
      for (final category in ItemCategory.values)
        if (items.where((i) => i.category == category).toList()
            case final inCategory when inCategory.isNotEmpty)
          (category: category, items: inCategory),
    ];
    return InventoryUiState(
      filter: filter,
      groups: groups,
      builtInCount: counts.builtIn,
      customCount: counts.custom,
      setCounts: setCountsAsync.requireValue,
    );
  });
}
