import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/async_combine.dart';
import '../../data/providers.dart';
import '../../domain/models/gear_set.dart';
import '../../domain/models/trip.dart';

part 'trip_list_state.g.dart';

/// S01 한 화면.
@immutable
class TripListUiState {
  const TripListUiState({
    required this.active,
    required this.activeSetName,
    required this.done,
  });

  final TripDetail? active;

  /// 진행 중 트립의 원본 세트 이름. 세트 없이 시작했거나 지워졌으면 null.
  final String? activeSetName;

  /// 최신순.
  final List<TripDetail> done;

  /// "아직 안 챙김" 미리보기 대상(제외는 빠진다).
  List<TripItem> get unpacked => [
    for (final item in active?.items ?? const <TripItem>[])
      if (item.state == PackState.unpacked) item,
  ];
}

@riverpod
Stream<TripDetail?> _tripListActive(Ref ref) =>
    ref.watch(tripDaoProvider).watchActiveTrip();

@riverpod
Stream<List<TripDetail>> _tripListDone(Ref ref) =>
    ref.watch(tripDaoProvider).watchDoneTrips();

@riverpod
Stream<List<GearSetDetail>> _tripListSets(Ref ref) =>
    ref.watch(setDaoProvider).watchSets();

@riverpod
AsyncValue<TripListUiState> tripListUiState(Ref ref) {
  final seeded = ref.watch(seedBootstrapProvider);
  final activeAsync = ref.watch(_tripListActiveProvider);
  final doneAsync = ref.watch(_tripListDoneProvider);
  final setsAsync = ref.watch(_tripListSetsProvider);
  return combineAsync([seeded, activeAsync, doneAsync, setsAsync], () {
    final active = activeAsync.requireValue;
    final sourceId = active?.trip.sourceSetId;
    String? setName;
    for (final s in setsAsync.requireValue) {
      if (s.set.id == sourceId) setName = s.set.name;
    }
    return TripListUiState(
      active: active,
      activeSetName: setName,
      done: doneAsync.requireValue,
    );
  });
}
