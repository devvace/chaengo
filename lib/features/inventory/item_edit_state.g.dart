// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_edit_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 내장 아이템들이 쓰는 아이콘을 카테고리별로 모은다. 별도 목록을 두지 않고
/// 시드 데이터에서 파생시켜 아이콘이 추가되면 자동으로 따라온다.

@ProviderFor(iconCatalog)
final iconCatalogProvider = IconCatalogProvider._();

/// 내장 아이템들이 쓰는 아이콘을 카테고리별로 모은다. 별도 목록을 두지 않고
/// 시드 데이터에서 파생시켜 아이콘이 추가되면 자동으로 따라온다.

final class IconCatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<ItemCategory, List<String>>>,
          Map<ItemCategory, List<String>>,
          FutureOr<Map<ItemCategory, List<String>>>
        >
    with
        $FutureModifier<Map<ItemCategory, List<String>>>,
        $FutureProvider<Map<ItemCategory, List<String>>> {
  /// 내장 아이템들이 쓰는 아이콘을 카테고리별로 모은다. 별도 목록을 두지 않고
  /// 시드 데이터에서 파생시켜 아이콘이 추가되면 자동으로 따라온다.
  IconCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iconCatalogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iconCatalogHash();

  @$internal
  @override
  $FutureProviderElement<Map<ItemCategory, List<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<ItemCategory, List<String>>> create(Ref ref) {
    return iconCatalog(ref);
  }
}

String _$iconCatalogHash() => r'1f11b493e15cb2df1bde1b608000d487c83e7ec3';

@ProviderFor(ItemEditController)
final itemEditControllerProvider = ItemEditControllerFamily._();

final class ItemEditControllerProvider
    extends $AsyncNotifierProvider<ItemEditController, ItemEditUiState> {
  ItemEditControllerProvider._({
    required ItemEditControllerFamily super.from,
    required (String?, {ItemCategory? initialCategory}) super.argument,
  }) : super(
         retry: null,
         name: r'itemEditControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemEditControllerHash();

  @override
  String toString() {
    return r'itemEditControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ItemEditController create() => ItemEditController();

  @override
  bool operator ==(Object other) {
    return other is ItemEditControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemEditControllerHash() =>
    r'9da9a180d9ddbf000da90869ba27e56653b85d60';

final class ItemEditControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ItemEditController,
          AsyncValue<ItemEditUiState>,
          ItemEditUiState,
          FutureOr<ItemEditUiState>,
          (String?, {ItemCategory? initialCategory})
        > {
  ItemEditControllerFamily._()
    : super(
        retry: null,
        name: r'itemEditControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemEditControllerProvider call(
    String? itemId, {
    ItemCategory? initialCategory,
  }) => ItemEditControllerProvider._(
    argument: (itemId, initialCategory: initialCategory),
    from: this,
  );

  @override
  String toString() => r'itemEditControllerProvider';
}

abstract class _$ItemEditController extends $AsyncNotifier<ItemEditUiState> {
  late final _$args = ref.$arg as (String?, {ItemCategory? initialCategory});
  String? get itemId => _$args.$1;
  ItemCategory? get initialCategory => _$args.initialCategory;

  FutureOr<ItemEditUiState> build(
    String? itemId, {
    ItemCategory? initialCategory,
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ItemEditUiState>, ItemEditUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ItemEditUiState>, ItemEditUiState>,
              AsyncValue<ItemEditUiState>,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(_$args.$1, initialCategory: _$args.initialCategory),
    );
  }
}
