// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_check_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TripCheckViewController)
final tripCheckViewControllerProvider = TripCheckViewControllerFamily._();

final class TripCheckViewControllerProvider
    extends $NotifierProvider<TripCheckViewController, TripCheckView> {
  TripCheckViewControllerProvider._({
    required TripCheckViewControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripCheckViewControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripCheckViewControllerHash();

  @override
  String toString() {
    return r'tripCheckViewControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TripCheckViewController create() => TripCheckViewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripCheckView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripCheckView>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripCheckViewControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripCheckViewControllerHash() =>
    r'482099f0a233530ee8f27be78af6060c5403cbb3';

final class TripCheckViewControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TripCheckViewController,
          TripCheckView,
          TripCheckView,
          TripCheckView,
          String
        > {
  TripCheckViewControllerFamily._()
    : super(
        retry: null,
        name: r'tripCheckViewControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripCheckViewControllerProvider call(String tripId) =>
      TripCheckViewControllerProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripCheckViewControllerProvider';
}

abstract class _$TripCheckViewController extends $Notifier<TripCheckView> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  TripCheckView build(String tripId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TripCheckView, TripCheckView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TripCheckView, TripCheckView>,
              TripCheckView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(_tripCheckDetail)
final _tripCheckDetailProvider = _TripCheckDetailFamily._();

final class _TripCheckDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<TripDetail?>,
          TripDetail?,
          Stream<TripDetail?>
        >
    with $FutureModifier<TripDetail?>, $StreamProvider<TripDetail?> {
  _TripCheckDetailProvider._({
    required _TripCheckDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'_tripCheckDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_tripCheckDetailHash();

  @override
  String toString() {
    return r'_tripCheckDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<TripDetail?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TripDetail?> create(Ref ref) {
    final argument = this.argument as String;
    return _tripCheckDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _TripCheckDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_tripCheckDetailHash() => r'3104a44a9c936cb6f26335fc8c4c574497b1b670';

final class _TripCheckDetailFamily extends $Family
    with $FunctionalFamilyOverride<Stream<TripDetail?>, String> {
  _TripCheckDetailFamily._()
    : super(
        retry: null,
        name: r'_tripCheckDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _TripCheckDetailProvider call(String tripId) =>
      _TripCheckDetailProvider._(argument: tripId, from: this);

  @override
  String toString() => r'_tripCheckDetailProvider';
}

/// null = 트립이 없음(삭제됨).

@ProviderFor(tripCheckUiState)
final tripCheckUiStateProvider = TripCheckUiStateFamily._();

/// null = 트립이 없음(삭제됨).

final class TripCheckUiStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<TripCheckUiState?>,
          AsyncValue<TripCheckUiState?>,
          AsyncValue<TripCheckUiState?>
        >
    with $Provider<AsyncValue<TripCheckUiState?>> {
  /// null = 트립이 없음(삭제됨).
  TripCheckUiStateProvider._({
    required TripCheckUiStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripCheckUiStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripCheckUiStateHash();

  @override
  String toString() {
    return r'tripCheckUiStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<TripCheckUiState?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<TripCheckUiState?> create(Ref ref) {
    final argument = this.argument as String;
    return tripCheckUiState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<TripCheckUiState?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<TripCheckUiState?>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripCheckUiStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripCheckUiStateHash() => r'bf181c70e8ff8eb6a1ff01d1f214dfbf1e7030de';

/// null = 트립이 없음(삭제됨).

final class TripCheckUiStateFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<TripCheckUiState?>, String> {
  TripCheckUiStateFamily._()
    : super(
        retry: null,
        name: r'tripCheckUiStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// null = 트립이 없음(삭제됨).

  TripCheckUiStateProvider call(String tripId) =>
      TripCheckUiStateProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripCheckUiStateProvider';
}
