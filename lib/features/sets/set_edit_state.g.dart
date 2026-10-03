// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_edit_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SetEditController)
final setEditControllerProvider = SetEditControllerFamily._();

final class SetEditControllerProvider
    extends $AsyncNotifierProvider<SetEditController, SetDraft> {
  SetEditControllerProvider._({
    required SetEditControllerFamily super.from,
    required SetEditArgs super.argument,
  }) : super(
         retry: null,
         name: r'setEditControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setEditControllerHash();

  @override
  String toString() {
    return r'setEditControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SetEditController create() => SetEditController();

  @override
  bool operator ==(Object other) {
    return other is SetEditControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setEditControllerHash() => r'6d6b2191a2a44643d6fec22f3de5b1c87e4a5581';

final class SetEditControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SetEditController,
          AsyncValue<SetDraft>,
          SetDraft,
          FutureOr<SetDraft>,
          SetEditArgs
        > {
  SetEditControllerFamily._()
    : super(
        retry: null,
        name: r'setEditControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SetEditControllerProvider call(SetEditArgs args) =>
      SetEditControllerProvider._(argument: args, from: this);

  @override
  String toString() => r'setEditControllerProvider';
}

abstract class _$SetEditController extends $AsyncNotifier<SetDraft> {
  late final _$args = ref.$arg as SetEditArgs;
  SetEditArgs get args => _$args;

  FutureOr<SetDraft> build(SetEditArgs args);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SetDraft>, SetDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SetDraft>, SetDraft>,
              AsyncValue<SetDraft>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(_setEditItems)
final _setEditItemsProvider = _SetEditItemsProvider._();

final class _SetEditItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          List<Item>,
          Stream<List<Item>>
        >
    with $FutureModifier<List<Item>>, $StreamProvider<List<Item>> {
  _SetEditItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_setEditItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_setEditItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Item>> create(Ref ref) {
    return _setEditItems(ref);
  }
}

String _$_setEditItemsHash() => r'6f0b5d3f0cef5d009928f1fe7d84a4c50e897c48';

@ProviderFor(_setEditActiveTrip)
final _setEditActiveTripProvider = _SetEditActiveTripProvider._();

final class _SetEditActiveTripProvider
    extends
        $FunctionalProvider<
          AsyncValue<TripDetail?>,
          TripDetail?,
          Stream<TripDetail?>
        >
    with $FutureModifier<TripDetail?>, $StreamProvider<TripDetail?> {
  _SetEditActiveTripProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_setEditActiveTripProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_setEditActiveTripHash();

  @$internal
  @override
  $StreamProviderElement<TripDetail?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TripDetail?> create(Ref ref) {
    return _setEditActiveTrip(ref);
  }
}

String _$_setEditActiveTripHash() =>
    r'9ba2b3fe3a9ed1ca965457611ec8a36b076456b0';

@ProviderFor(setEditUiState)
final setEditUiStateProvider = SetEditUiStateFamily._();

final class SetEditUiStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<SetEditUiState>,
          AsyncValue<SetEditUiState>,
          AsyncValue<SetEditUiState>
        >
    with $Provider<AsyncValue<SetEditUiState>> {
  SetEditUiStateProvider._({
    required SetEditUiStateFamily super.from,
    required SetEditArgs super.argument,
  }) : super(
         retry: null,
         name: r'setEditUiStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setEditUiStateHash();

  @override
  String toString() {
    return r'setEditUiStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<SetEditUiState>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<SetEditUiState> create(Ref ref) {
    final argument = this.argument as SetEditArgs;
    return setEditUiState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SetEditUiState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SetEditUiState>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SetEditUiStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setEditUiStateHash() => r'c28af9243b9576a3609f0c3344dec20c574ba566';

final class SetEditUiStateFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<SetEditUiState>, SetEditArgs> {
  SetEditUiStateFamily._()
    : super(
        retry: null,
        name: r'setEditUiStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SetEditUiStateProvider call(SetEditArgs args) =>
      SetEditUiStateProvider._(argument: args, from: this);

  @override
  String toString() => r'setEditUiStateProvider';
}
