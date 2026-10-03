// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 전체가 공유하는 단일 DB 연결.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// 앱 전체가 공유하는 단일 DB 연결.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// 앱 전체가 공유하는 단일 DB 연결.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

@ProviderFor(itemDao)
final itemDaoProvider = ItemDaoProvider._();

final class ItemDaoProvider
    extends $FunctionalProvider<ItemDao, ItemDao, ItemDao>
    with $Provider<ItemDao> {
  ItemDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemDaoHash();

  @$internal
  @override
  $ProviderElement<ItemDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItemDao create(Ref ref) {
    return itemDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItemDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItemDao>(value),
    );
  }
}

String _$itemDaoHash() => r'8b7bc0d3842cdb792b8af3c2bb5ebab399f7b1a2';

@ProviderFor(setDao)
final setDaoProvider = SetDaoProvider._();

final class SetDaoProvider extends $FunctionalProvider<SetDao, SetDao, SetDao>
    with $Provider<SetDao> {
  SetDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setDaoHash();

  @$internal
  @override
  $ProviderElement<SetDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SetDao create(Ref ref) {
    return setDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetDao>(value),
    );
  }
}

String _$setDaoHash() => r'667e9913e1148d20ccec9d379ba2376333853ee5';

@ProviderFor(tripDao)
final tripDaoProvider = TripDaoProvider._();

final class TripDaoProvider
    extends $FunctionalProvider<TripDao, TripDao, TripDao>
    with $Provider<TripDao> {
  TripDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripDaoHash();

  @$internal
  @override
  $ProviderElement<TripDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TripDao create(Ref ref) {
    return tripDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripDao>(value),
    );
  }
}

String _$tripDaoHash() => r'a060578a095e319fb0b378aaa366d7a29377c593';

@ProviderFor(settingsDao)
final settingsDaoProvider = SettingsDaoProvider._();

final class SettingsDaoProvider
    extends $FunctionalProvider<SettingsDao, SettingsDao, SettingsDao>
    with $Provider<SettingsDao> {
  SettingsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsDaoHash();

  @$internal
  @override
  $ProviderElement<SettingsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsDao create(Ref ref) {
    return settingsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsDao>(value),
    );
  }
}

String _$settingsDaoHash() => r'a0a5073bee4b1c7ab22a219c1b79798d6aef8421';

@ProviderFor(seedLoader)
final seedLoaderProvider = SeedLoaderProvider._();

final class SeedLoaderProvider
    extends $FunctionalProvider<SeedLoader, SeedLoader, SeedLoader>
    with $Provider<SeedLoader> {
  SeedLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seedLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seedLoaderHash();

  @$internal
  @override
  $ProviderElement<SeedLoader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SeedLoader create(Ref ref) {
    return seedLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeedLoader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeedLoader>(value),
    );
  }
}

String _$seedLoaderHash() => r'bbbba73442f835a7ac3b0c0bb5c489ffb54d95f1';

/// 앱 시작 시 한 번 기다린다. 아이템이 이미 있으면 바로 끝난다.

@ProviderFor(seedBootstrap)
final seedBootstrapProvider = SeedBootstrapProvider._();

/// 앱 시작 시 한 번 기다린다. 아이템이 이미 있으면 바로 끝난다.

final class SeedBootstrapProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 앱 시작 시 한 번 기다린다. 아이템이 이미 있으면 바로 끝난다.
  SeedBootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seedBootstrapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seedBootstrapHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return seedBootstrap(ref);
  }
}

String _$seedBootstrapHash() => r'd123f32f9e0760801f9b903a40da7bf02e315525';

/// 체크 화면 옵션(S09). S03 화면 켜짐·진동이 구독한다.

@ProviderFor(appSettings)
final appSettingsProvider = AppSettingsProvider._();

/// 체크 화면 옵션(S09). S03 화면 켜짐·진동이 구독한다.

final class AppSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppSettings>,
          AppSettings,
          Stream<AppSettings>
        >
    with $FutureModifier<AppSettings>, $StreamProvider<AppSettings> {
  /// 체크 화면 옵션(S09). S03 화면 켜짐·진동이 구독한다.
  AppSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsHash();

  @$internal
  @override
  $StreamProviderElement<AppSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppSettings> create(Ref ref) {
    return appSettings(ref);
  }
}

String _$appSettingsHash() => r'1f76b2017c3f239a40799cf74e3f163a4dc8a2dd';
