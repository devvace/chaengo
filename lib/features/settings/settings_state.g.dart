// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 플랫폼 분기 없이 공통 키만 읽는다(manufacturer는 Android에만 있다).

@ProviderFor(appInfo)
final appInfoProvider = AppInfoProvider._();

/// 플랫폼 분기 없이 공통 키만 읽는다(manufacturer는 Android에만 있다).

final class AppInfoProvider
    extends $FunctionalProvider<AsyncValue<AppInfo>, AppInfo, FutureOr<AppInfo>>
    with $FutureModifier<AppInfo>, $FutureProvider<AppInfo> {
  /// 플랫폼 분기 없이 공통 키만 읽는다(manufacturer는 Android에만 있다).
  AppInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInfoHash();

  @$internal
  @override
  $FutureProviderElement<AppInfo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppInfo> create(Ref ref) {
    return appInfo(ref);
  }
}

String _$appInfoHash() => r'8bcc0dade1c0e253d7a6b6c7f5994ac53d82aa45';

@ProviderFor(_settingsHidden)
final _settingsHiddenProvider = _SettingsHiddenProvider._();

final class _SettingsHiddenProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          List<Item>,
          Stream<List<Item>>
        >
    with $FutureModifier<List<Item>>, $StreamProvider<List<Item>> {
  _SettingsHiddenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_settingsHiddenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_settingsHiddenHash();

  @$internal
  @override
  $StreamProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Item>> create(Ref ref) {
    return _settingsHidden(ref);
  }
}

String _$_settingsHiddenHash() => r'fa0826b45a478853f3d6f8a7ebd929bc333ef377';

@ProviderFor(_settingsCounts)
final _settingsCountsProvider = _SettingsCountsProvider._();

final class _SettingsCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int builtIn, int custom})>,
          ({int builtIn, int custom}),
          Stream<({int builtIn, int custom})>
        >
    with
        $FutureModifier<({int builtIn, int custom})>,
        $StreamProvider<({int builtIn, int custom})> {
  _SettingsCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_settingsCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_settingsCountsHash();

  @$internal
  @override
  $StreamProviderElement<({int builtIn, int custom})> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<({int builtIn, int custom})> create(Ref ref) {
    return _settingsCounts(ref);
  }
}

String _$_settingsCountsHash() => r'4faa8e5269bd0703c63b5618a81b1034670c0de9';

@ProviderFor(settingsUiState)
final settingsUiStateProvider = SettingsUiStateProvider._();

final class SettingsUiStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<SettingsUiState>,
          AsyncValue<SettingsUiState>,
          AsyncValue<SettingsUiState>
        >
    with $Provider<AsyncValue<SettingsUiState>> {
  SettingsUiStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsUiStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsUiStateHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<SettingsUiState>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<SettingsUiState> create(Ref ref) {
    return settingsUiState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SettingsUiState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SettingsUiState>>(value),
    );
  }
}

String _$settingsUiStateHash() => r'ef14b799b15ff2a5870cf33f154efa253811ec91';

@ProviderFor(hiddenItems)
final hiddenItemsProvider = HiddenItemsProvider._();

final class HiddenItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          List<Item>,
          Stream<List<Item>>
        >
    with $FutureModifier<List<Item>>, $StreamProvider<List<Item>> {
  HiddenItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiddenItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiddenItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Item>> create(Ref ref) {
    return hiddenItems(ref);
  }
}

String _$hiddenItemsHash() => r'97b89dcac36866d1d3b3e86287907b368b552006';
