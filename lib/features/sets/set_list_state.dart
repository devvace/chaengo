import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/async_combine.dart';
import '../../data/providers.dart';
import '../../domain/models/gear_set.dart';
import '../../domain/models/trip.dart';

part 'set_list_state.g.dart';

/// S05 한 화면. 세트는 DAO가 이미 정렬(기본 최상단, 마지막 사용일 내림차순).
@immutable
class SetListUiState {
  const SetListUiState({required this.sets, required this.inUseSetId});

  final List<GearSetDetail> sets;

  /// 진행 중 트립의 원본 세트 id("사용 중").
  final String? inUseSetId;
}

@riverpod
Stream<List<GearSetDetail>> _setListSets(Ref ref) =>
    ref.watch(setDaoProvider).watchSets();

@riverpod
Stream<TripDetail?> _setListActiveTrip(Ref ref) =>
    ref.watch(tripDaoProvider).watchActiveTrip();

@riverpod
AsyncValue<SetListUiState> setListUiState(Ref ref) {
  final seeded = ref.watch(seedBootstrapProvider);
  final setsAsync = ref.watch(_setListSetsProvider);
  final activeAsync = ref.watch(_setListActiveTripProvider);
  return combineAsync(
    [seeded, setsAsync, activeAsync],
    () => SetListUiState(
      sets: setsAsync.requireValue,
      inUseSetId: activeAsync.requireValue?.trip.sourceSetId,
    ),
  );
}
