// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryFilterController)
final inventoryFilterControllerProvider = InventoryFilterControllerProvider._();

final class InventoryFilterControllerProvider
    extends $NotifierProvider<InventoryFilterController, InventoryFilter> {
  InventoryFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryFilterControllerHash();

  @$internal
  @override
  InventoryFilterController create() => InventoryFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryFilter>(value),
    );
  }
}

String _$inventoryFilterControllerHash() =>
    r'281a565fa1008817a4e17acee4e6f2ce87bd4025';

abstract class _$InventoryFilterController extends $Notifier<InventoryFilter> {
  InventoryFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InventoryFilter, InventoryFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InventoryFilter, InventoryFilter>,
              InventoryFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 필터를 family 인자로 받지 않고 안에서 watch한다. 그래야 필터가 바뀌어
/// 다시 구독하는 동안에도 이전 결과를 유지해 목록이 깜빡이지 않는다.

@ProviderFor(_inventoryItems)
final _inventoryItemsProvider = _InventoryItemsProvider._();

/// 필터를 family 인자로 받지 않고 안에서 watch한다. 그래야 필터가 바뀌어
/// 다시 구독하는 동안에도 이전 결과를 유지해 목록이 깜빡이지 않는다.

final class _InventoryItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          List<Item>,
          Stream<List<Item>>
        >
    with $FutureModifier<List<Item>>, $StreamProvider<List<Item>> {
  /// 필터를 family 인자로 받지 않고 안에서 watch한다. 그래야 필터가 바뀌어
  /// 다시 구독하는 동안에도 이전 결과를 유지해 목록이 깜빡이지 않는다.
  _InventoryItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_inventoryItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_inventoryItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Item>> create(Ref ref) {
    return _inventoryItems(ref);
  }
}

String _$_inventoryItemsHash() => r'1c56f9552f5fce1e7474aaf768f8a1297fdc5674';

@ProviderFor(_inventoryCounts)
final _inventoryCountsProvider = _InventoryCountsProvider._();

final class _InventoryCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int builtIn, int custom})>,
          ({int builtIn, int custom}),
          Stream<({int builtIn, int custom})>
        >
    with
        $FutureModifier<({int builtIn, int custom})>,
        $StreamProvider<({int builtIn, int custom})> {
  _InventoryCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_inventoryCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_inventoryCountsHash();

  @$internal
  @override
  $StreamProviderElement<({int builtIn, int custom})> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<({int builtIn, int custom})> create(Ref ref) {
    return _inventoryCounts(ref);
  }
}

String _$_inventoryCountsHash() => r'7e1e4136eef94e134a62bab850ebd274e9f89ef3';

@ProviderFor(_inventorySetCounts)
final _inventorySetCountsProvider = _InventorySetCountsProvider._();

final class _InventorySetCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          Stream<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $StreamProvider<Map<String, int>> {
  _InventorySetCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_inventorySetCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_inventorySetCountsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, int>> create(Ref ref) {
    return _inventorySetCounts(ref);
  }
}

String _$_inventorySetCountsHash() =>
    r'151b06e2308a3a187fd6ed3c6922a7d63f7c9888';

@ProviderFor(inventoryUiState)
final inventoryUiStateProvider = InventoryUiStateProvider._();

final class InventoryUiStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<InventoryUiState>,
          AsyncValue<InventoryUiState>,
          AsyncValue<InventoryUiState>
        >
    with $Provider<AsyncValue<InventoryUiState>> {
  InventoryUiStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryUiStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryUiStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<InventoryUiState>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<InventoryUiState> create(Ref ref) {
    return inventoryUiState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<InventoryUiState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<InventoryUiState>>(value),
    );
  }
}

String _$inventoryUiStateHash() => r'1dab45a85528bd0768d17adb1ef60f046cdc9f83';
