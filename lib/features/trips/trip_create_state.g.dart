// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_create_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TripCreateController)
final tripCreateControllerProvider = TripCreateControllerFamily._();

final class TripCreateControllerProvider
    extends $NotifierProvider<TripCreateController, TripCreateForm> {
  TripCreateControllerProvider._({
    required TripCreateControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tripCreateControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripCreateControllerHash();

  @override
  String toString() {
    return r'tripCreateControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TripCreateController create() => TripCreateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripCreateForm value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripCreateForm>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripCreateControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripCreateControllerHash() =>
    r'2ff39b2064759680bb18dd7e07f7ec2e652405b3';

final class TripCreateControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TripCreateController,
          TripCreateForm,
          TripCreateForm,
          TripCreateForm,
          String?
        > {
  TripCreateControllerFamily._()
    : super(
        retry: null,
        name: r'tripCreateControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripCreateControllerProvider call(String? preselectedSetId) =>
      TripCreateControllerProvider._(argument: preselectedSetId, from: this);

  @override
  String toString() => r'tripCreateControllerProvider';
}

abstract class _$TripCreateController extends $Notifier<TripCreateForm> {
  late final _$args = ref.$arg as String?;
  String? get preselectedSetId => _$args;

  TripCreateForm build(String? preselectedSetId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TripCreateForm, TripCreateForm>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TripCreateForm, TripCreateForm>,
              TripCreateForm,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(_tripCreateSets)
final _tripCreateSetsProvider = _TripCreateSetsProvider._();

final class _TripCreateSetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GearSetDetail>>,
          List<GearSetDetail>,
          Stream<List<GearSetDetail>>
        >
    with
        $FutureModifier<List<GearSetDetail>>,
        $StreamProvider<List<GearSetDetail>> {
  _TripCreateSetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_tripCreateSetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_tripCreateSetsHash();

  @$internal
  @override
  $StreamProviderElement<List<GearSetDetail>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GearSetDetail>> create(Ref ref) {
    return _tripCreateSets(ref);
  }
}

String _$_tripCreateSetsHash() => r'b635040fab58cbd41a4becfa708352b6056eb50a';

@ProviderFor(tripCreateUiState)
final tripCreateUiStateProvider = TripCreateUiStateFamily._();

final class TripCreateUiStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<TripCreateUiState>,
          AsyncValue<TripCreateUiState>,
          AsyncValue<TripCreateUiState>
        >
    with $Provider<AsyncValue<TripCreateUiState>> {
  TripCreateUiStateProvider._({
    required TripCreateUiStateFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tripCreateUiStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripCreateUiStateHash();

  @override
  String toString() {
    return r'tripCreateUiStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<TripCreateUiState>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<TripCreateUiState> create(Ref ref) {
    final argument = this.argument as String?;
    return tripCreateUiState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<TripCreateUiState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<TripCreateUiState>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripCreateUiStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripCreateUiStateHash() => r'34ec23ac777631d1f57876678feb25d8809a59b0';

final class TripCreateUiStateFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<TripCreateUiState>, String?> {
  TripCreateUiStateFamily._()
    : super(
        retry: null,
        name: r'tripCreateUiStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripCreateUiStateProvider call(String? preselectedSetId) =>
      TripCreateUiStateProvider._(argument: preselectedSetId, from: this);

  @override
  String toString() => r'tripCreateUiStateProvider';
}
