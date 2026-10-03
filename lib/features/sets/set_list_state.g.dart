// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_list_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_setListSets)
final _setListSetsProvider = _SetListSetsProvider._();

final class _SetListSetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GearSetDetail>>,
          List<GearSetDetail>,
          Stream<List<GearSetDetail>>
        >
    with
        $FutureModifier<List<GearSetDetail>>,
        $StreamProvider<List<GearSetDetail>> {
  _SetListSetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_setListSetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_setListSetsHash();

  @$internal
  @override
  $StreamProviderElement<List<GearSetDetail>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GearSetDetail>> create(Ref ref) {
    return _setListSets(ref);
  }
}

String _$_setListSetsHash() => r'4ebe672aa33fe3b439e2b428aa6ee0413ebafe60';

@ProviderFor(_setListActiveTrip)
final _setListActiveTripProvider = _SetListActiveTripProvider._();

final class _SetListActiveTripProvider
    extends
        $FunctionalProvider<
          AsyncValue<TripDetail?>,
          TripDetail?,
          Stream<TripDetail?>
        >
    with $FutureModifier<TripDetail?>, $StreamProvider<TripDetail?> {
  _SetListActiveTripProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_setListActiveTripProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_setListActiveTripHash();

  @$internal
  @override
  $StreamProviderElement<TripDetail?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TripDetail?> create(Ref ref) {
    return _setListActiveTrip(ref);
  }
}

String _$_setListActiveTripHash() =>
    r'3e720aa81de6acc2ccd90be02ae7c3cc19fb3f3e';

@ProviderFor(setListUiState)
final setListUiStateProvider = SetListUiStateProvider._();

final class SetListUiStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<SetListUiState>,
          AsyncValue<SetListUiState>,
          AsyncValue<SetListUiState>
        >
    with $Provider<AsyncValue<SetListUiState>> {
  SetListUiStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setListUiStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setListUiStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<SetListUiState>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<SetListUiState> create(Ref ref) {
    return setListUiState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SetListUiState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SetListUiState>>(value),
    );
  }
}

String _$setListUiStateHash() => r'2a6acde8e5387c76e0c6420bd5dbad036b6b2201';
