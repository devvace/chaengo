import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/async_combine.dart';
import '../../data/providers.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/item_category.dart';
import '../../domain/models/trip.dart';

part 'trip_check_state.g.dart';

enum TripSort {
  /// 기본. 각 카테고리 안에서 안 챙긴 것 → 챙긴 것 → 제외 순.
  unpackedFirst,

  /// 카테고리 안 원래 순서(세트 순서) 그대로.
  category,
}

/// 화면에만 있는 보기 상태(DB에 저장하지 않는다).
@immutable
class TripCheckView {
  const TripCheckView({
    this.sort = TripSort.unpackedFirst,
    this.collapsed = const {},
  });

  final TripSort sort;
  final Set<ItemCategory> collapsed;
}

@immutable
class TripCheckGroup {
  const TripCheckGroup({
    required this.category,
    required this.items,
    required this.collapsed,
  });

  final ItemCategory category;
  final List<TripItem> items;
  final bool collapsed;

  int get packed => items.where((i) => i.isPacked).length;

  /// 제외를 뺀 개수(헤더 분모).
  int get total => items.where((i) => !i.isExcluded).length;
}

/// S03 한 화면.
@immutable
class TripCheckUiState {
  const TripCheckUiState({
    required this.detail,
    required this.view,
    required this.groups,
    required this.settings,
  });

  final TripDetail detail;
  final TripCheckView view;
  final List<TripCheckGroup> groups;
  final AppSettings settings;

  /// 완료한 트립은 읽기 전용.
  bool get readOnly => !detail.trip.isActive;
  TripProgress get progress => detail.progress;

  /// "타프 제외 · 22개 남음" / "타프 외 2개 제외 · …".
  String get summary {
    final p = progress;
    final excluded = detail.items.where((i) => i.isExcluded).toList();
    final parts = <String>[
      if (excluded.length == 1) '${excluded.single.item.name} 제외',
      if (excluded.length > 1)
        '${excluded.first.item.name} 외 ${excluded.length - 1}개 제외',
      if (p.total == 0)
        '아이템이 없어요'
      else if (p.remaining == 0)
        '다 챙겼어요'
      else
        '${p.remaining}개 남음',
    ];
    return parts.join(' · ');
  }
}

@riverpod
class TripCheckViewController extends _$TripCheckViewController {
  @override
  TripCheckView build(String tripId) => const TripCheckView();

  void setSort(TripSort sort) =>
      state = TripCheckView(sort: sort, collapsed: state.collapsed);

  void toggleCollapsed(ItemCategory category) {
    final next = {...state.collapsed};
    if (!next.remove(category)) next.add(category);
    state = TripCheckView(sort: state.sort, collapsed: next);
  }
}

@riverpod
Stream<TripDetail?> _tripCheckDetail(Ref ref, String tripId) =>
    ref.watch(tripDaoProvider).watchTripDetail(tripId);

/// null = 트립이 없음(삭제됨).
@riverpod
AsyncValue<TripCheckUiState?> tripCheckUiState(Ref ref, String tripId) {
  final detailAsync = ref.watch(_tripCheckDetailProvider(tripId));
  final settingsAsync = ref.watch(appSettingsProvider);
  final view = ref.watch(tripCheckViewControllerProvider(tripId));
  return combineAsync([detailAsync, settingsAsync], () {
    final detail = detailAsync.requireValue;
    if (detail == null) return null;
    return TripCheckUiState(
      detail: detail,
      view: view,
      settings: settingsAsync.requireValue,
      groups: [
        for (final category in ItemCategory.values)
          if (_itemsOf(detail, category, view.sort) case final items
              when items.isNotEmpty)
            TripCheckGroup(
              category: category,
              items: items,
              collapsed: view.collapsed.contains(category),
            ),
      ],
    );
  });
}

List<TripItem> _itemsOf(
  TripDetail detail,
  ItemCategory category,
  TripSort sort,
) {
  // DAO가 이미 카테고리 안 순서로 정렬해 준다.
  final items = detail.items.where((i) => i.item.category == category).toList();
  if (sort == TripSort.category) return items;
  int rank(TripItem i) => switch (i.state) {
    PackState.unpacked => 0,
    PackState.packed => 1,
    PackState.excluded => 2,
  };
  // List.sort는 안정 정렬이 아니므로 원래 순서를 보조 키로 쓴다.
  final indexed = items.indexed.toList()
    ..sort((a, b) {
      final byRank = rank(a.$2).compareTo(rank(b.$2));
      return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
    });
  return [for (final (_, item) in indexed) item];
}
