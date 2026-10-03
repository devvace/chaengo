// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_add_sheet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 선택 상태. 딤 영역을 탭해 닫아도 선택은 남는다(02_screens.md S04).
/// 추가하면 비운다.

@ProviderFor(TripAddSelection)
final tripAddSelectionProvider = TripAddSelectionFamily._();

/// 선택 상태. 딤 영역을 탭해 닫아도 선택은 남는다(02_screens.md S04).
/// 추가하면 비운다.
final class TripAddSelectionProvider
    extends $NotifierProvider<TripAddSelection, Set<String>> {
  /// 선택 상태. 딤 영역을 탭해 닫아도 선택은 남는다(02_screens.md S04).
  /// 추가하면 비운다.
  TripAddSelectionProvider._({
    required TripAddSelectionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripAddSelectionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripAddSelectionHash();

  @override
  String toString() {
    return r'tripAddSelectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TripAddSelection create() => TripAddSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripAddSelectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripAddSelectionHash() => r'84b34390cafb8251f55499084ac70e92e4a5d8c3';

/// 선택 상태. 딤 영역을 탭해 닫아도 선택은 남는다(02_screens.md S04).
/// 추가하면 비운다.

final class TripAddSelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          TripAddSelection,
          Set<String>,
          Set<String>,
          Set<String>,
          String
        > {
  TripAddSelectionFamily._()
    : super(
        retry: null,
        name: r'tripAddSelectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// 선택 상태. 딤 영역을 탭해 닫아도 선택은 남는다(02_screens.md S04).
  /// 추가하면 비운다.

  TripAddSelectionProvider call(String tripId) =>
      TripAddSelectionProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripAddSelectionProvider';
}

/// 선택 상태. 딤 영역을 탭해 닫아도 선택은 남는다(02_screens.md S04).
/// 추가하면 비운다.

abstract class _$TripAddSelection extends $Notifier<Set<String>> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  Set<String> build(String tripId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// 트립에 아직 없는 아이템(숨김 제외).

@ProviderFor(tripAddCandidates)
final tripAddCandidatesProvider = TripAddCandidatesFamily._();

/// 트립에 아직 없는 아이템(숨김 제외).

final class TripAddCandidatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          AsyncValue<List<Item>>,
          AsyncValue<List<Item>>
        >
    with $Provider<AsyncValue<List<Item>>> {
  /// 트립에 아직 없는 아이템(숨김 제외).
  TripAddCandidatesProvider._({
    required TripAddCandidatesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripAddCandidatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripAddCandidatesHash();

  @override
  String toString() {
    return r'tripAddCandidatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Item>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Item>> create(Ref ref) {
    final argument = this.argument as String;
    return tripAddCandidates(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Item>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Item>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TripAddCandidatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripAddCandidatesHash() => r'4ffd5c9ceb6a27ab8948fb83f141669f23c55405';

/// 트립에 아직 없는 아이템(숨김 제외).

final class TripAddCandidatesFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<Item>>, String> {
  TripAddCandidatesFamily._()
    : super(
        retry: null,
        name: r'tripAddCandidatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 트립에 아직 없는 아이템(숨김 제외).

  TripAddCandidatesProvider call(String tripId) =>
      TripAddCandidatesProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripAddCandidatesProvider';
}

@ProviderFor(_tripAddItems)
final _tripAddItemsProvider = _TripAddItemsProvider._();

final class _TripAddItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          List<Item>,
          Stream<List<Item>>
        >
    with $FutureModifier<List<Item>>, $StreamProvider<List<Item>> {
  _TripAddItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_tripAddItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_tripAddItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Item>> create(Ref ref) {
    return _tripAddItems(ref);
  }
}

String _$_tripAddItemsHash() => r'2614ec46d4e6e1e4a18311b4d34600297c316898';

@ProviderFor(_tripAddInTrip)
final _tripAddInTripProvider = _TripAddInTripFamily._();

final class _TripAddInTripProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  _TripAddInTripProvider._({
    required _TripAddInTripFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'_tripAddInTripProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_tripAddInTripHash();

  @override
  String toString() {
    return r'_tripAddInTripProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    final argument = this.argument as String;
    return _tripAddInTrip(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _TripAddInTripProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_tripAddInTripHash() => r'44d8a16eaf08131c341382bb32f2910a226b6091';

final class _TripAddInTripFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Set<String>>, String> {
  _TripAddInTripFamily._()
    : super(
        retry: null,
        name: r'_tripAddInTripProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _TripAddInTripProvider call(String tripId) =>
      _TripAddInTripProvider._(argument: tripId, from: this);

  @override
  String toString() => r'_tripAddInTripProvider';
}
