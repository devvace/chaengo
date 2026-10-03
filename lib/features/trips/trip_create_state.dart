import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/async_combine.dart';
import '../../data/providers.dart';
import '../../domain/models/gear_set.dart';
import 'trip_format.dart';

part 'trip_create_state.g.dart';

/// S02 입력값. [setId]가 null이면 [세트 없이 시작].
@immutable
class TripCreateForm {
  const TripCreateForm({
    required this.name,
    required this.nameEdited,
    required this.start,
    required this.end,
    required this.setId,
    required this.initialized,
  });

  final String name;

  /// 사용자가 이름을 직접 고쳤으면 세트를 바꿔도 이름을 덮어쓰지 않는다.
  final bool nameEdited;
  final DateTime start;
  final DateTime end;
  final String? setId;

  /// 세트 목록이 들어와 기본 선택을 마쳤는지.
  final bool initialized;

  TripCreateForm copyWith({
    String? name,
    bool? nameEdited,
    DateTime? start,
    DateTime? end,
    String? Function()? setId,
    bool? initialized,
  }) => TripCreateForm(
    name: name ?? this.name,
    nameEdited: nameEdited ?? this.nameEdited,
    start: start ?? this.start,
    end: end ?? this.end,
    setId: setId == null ? this.setId : setId(),
    initialized: initialized ?? this.initialized,
  );
}

@immutable
class TripCreateUiState {
  const TripCreateUiState({required this.form, required this.sets});

  final TripCreateForm form;

  /// S05와 같은 순서(기본 최상단, 마지막 사용일 순).
  final List<GearSetDetail> sets;

  bool get canCreate => form.name.trim().isNotEmpty;
}

/// "세트명 + 월"(예: 감성캠핑 9월). 세트가 없으면 "N월 캠핑".
String defaultTripName(String? setName, DateTime start) =>
    setName == null ? '${start.month}월 캠핑' : '$setName ${start.month}월';

@riverpod
class TripCreateController extends _$TripCreateController {
  @override
  TripCreateForm build(String? preselectedSetId) {
    final weekend = TripFormat.thisWeekend(DateTime.now());
    return TripCreateForm(
      name: '',
      nameEdited: false,
      start: weekend.start,
      end: weekend.end,
      setId: preselectedSetId,
      initialized: false,
    );
  }

  /// 세트 목록이 처음 들어왔을 때 한 번. 미리 고른 세트가 없으면
  /// 마지막으로 쓴 세트(없으면 기본 세트)를 고른다.
  void initWith(List<GearSetDetail> sets) {
    if (state.initialized) return;
    var setId = state.setId;
    if (setId == null || !sets.any((s) => s.set.id == setId)) {
      final used = [...sets.where((s) => s.set.lastUsedAt != null)]
        ..sort((a, b) => b.set.lastUsedAt!.compareTo(a.set.lastUsedAt!));
      setId = used.isNotEmpty
          ? used.first.set.id
          : sets.isEmpty
          ? null
          : sets.first.set.id;
    }
    state = state.copyWith(
      setId: () => setId,
      initialized: true,
      name: defaultTripName(_nameOf(sets, setId), state.start),
    );
  }

  void setName(String name) =>
      state = state.copyWith(name: name, nameEdited: true);

  void selectSet(String? setId, List<GearSetDetail> sets) {
    state = state.copyWith(
      setId: () => setId,
      name: state.nameEdited
          ? null
          : defaultTripName(_nameOf(sets, setId), state.start),
    );
  }

  void setDates(DateTime start, DateTime end, List<GearSetDetail> sets) {
    final fixedEnd = end.isBefore(start) ? start : end;
    state = state.copyWith(
      start: start,
      end: fixedEnd,
      name: state.nameEdited
          ? null
          : defaultTripName(_nameOf(sets, state.setId), start),
    );
  }

  /// 만든 트립 id.
  Future<String> create() => ref
      .read(tripDaoProvider)
      .createTrip(
        name: state.name.trim(),
        startDate: state.start,
        endDate: state.end,
        setId: state.setId,
      );

  static String? _nameOf(List<GearSetDetail> sets, String? setId) {
    for (final s in sets) {
      if (s.set.id == setId) return s.set.name;
    }
    return null;
  }
}

@riverpod
Stream<List<GearSetDetail>> _tripCreateSets(Ref ref) =>
    ref.watch(setDaoProvider).watchSets();

@riverpod
AsyncValue<TripCreateUiState> tripCreateUiState(
  Ref ref,
  String? preselectedSetId,
) {
  final form = ref.watch(tripCreateControllerProvider(preselectedSetId));
  final setsAsync = ref.watch(_tripCreateSetsProvider);
  return combineAsync([
    setsAsync,
  ], () => TripCreateUiState(form: form, sets: setsAsync.requireValue));
}
