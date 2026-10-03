// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_list_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_tripListActive)
final _tripListActiveProvider = _TripListActiveProvider._();

final class _TripListActiveProvider
    extends
        $FunctionalProvider<
          AsyncValue<TripDetail?>,
          TripDetail?,
          Stream<TripDetail?>
        >
    with $FutureModifier<TripDetail?>, $StreamProvider<TripDetail?> {
  _TripListActiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_tripListActiveProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_tripListActiveHash();

  @$internal
  @override
  $StreamProviderElement<TripDetail?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TripDetail?> create(Ref ref) {
    return _tripListActive(ref);
  }
}

String _$_tripListActiveHash() => r'b7cace067ba2e66dfba6c793cdb551785c75be4c';

@ProviderFor(_tripListDone)
final _tripListDoneProvider = _TripListDoneProvider._();

final class _TripListDoneProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TripDetail>>,
          List<TripDetail>,
          Stream<List<TripDetail>>
        >
    with $FutureModifier<List<TripDetail>>, $StreamProvider<List<TripDetail>> {
  _TripListDoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_tripListDoneProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_tripListDoneHash();

  @$internal
  @override
  $StreamProviderElement<List<TripDetail>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TripDetail>> create(Ref ref) {
    return _tripListDone(ref);
  }
}

String _$_tripListDoneHash() => r'04a5f41103540bbaf2fb8ada534fcdf3cbdcb7f2';

@ProviderFor(_tripListSets)
final _tripListSetsProvider = _TripListSetsProvider._();

final class _TripListSetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GearSetDetail>>,
          List<GearSetDetail>,
          Stream<List<GearSetDetail>>
        >
    with
        $FutureModifier<List<GearSetDetail>>,
        $StreamProvider<List<GearSetDetail>> {
  _TripListSetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_tripListSetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_tripListSetsHash();

  @$internal
  @override
  $StreamProviderElement<List<GearSetDetail>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GearSetDetail>> create(Ref ref) {
    return _tripListSets(ref);
  }
}

String _$_tripListSetsHash() => r'208c81e949e00d2257a8a25ceb42c203214e64b5';

@ProviderFor(tripListUiState)
final tripListUiStateProvider = TripListUiStateProvider._();

final class TripListUiStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<TripListUiState>,
          AsyncValue<TripListUiState>,
          AsyncValue<TripListUiState>
        >
    with $Provider<AsyncValue<TripListUiState>> {
  TripListUiStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripListUiStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripListUiStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<TripListUiState>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<TripListUiState> create(Ref ref) {
    return tripListUiState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<TripListUiState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<TripListUiState>>(value),
    );
  }
}

String _$tripListUiStateHash() => r'792fecdba964741129070bdf056e64e1a9e359e6';
