import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/async_combine.dart';
import '../../data/providers.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/item.dart';

part 'settings_state.g.dart';

/// 피드백 메일 받는 주소. url_launcher는 mailto에만 쓴다.
const kFeedbackEmail = 'devvace@gmail.com';

/// 정보 섹션과 피드백 메일 본문에 쓰는 앱·기기 정보.
@immutable
class AppInfo {
  const AppInfo({
    required this.version,
    required this.build,
    required this.device,
    required this.os,
  });

  final String version;
  final String build;
  final String device;
  final String os;
}

/// 플랫폼 분기 없이 공통 키만 읽는다(manufacturer는 Android에만 있다).
@Riverpod(keepAlive: true)
Future<AppInfo> appInfo(Ref ref) async {
  final package = await PackageInfo.fromPlatform();
  var device = '';
  try {
    final data = (await DeviceInfoPlugin().deviceInfo).data;
    final machine = data['utsname'] is Map
        ? (data['utsname'] as Map)['machine']
        : null;
    device = [
      data['manufacturer'],
      data['model'],
      machine,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
  } on Object {
    // 기기 정보는 없어도 된다.
  }
  return AppInfo(
    version: package.version,
    build: package.buildNumber,
    device: device,
    os: '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
  );
}

/// S09 한 화면.
@immutable
class SettingsUiState {
  const SettingsUiState({
    required this.settings,
    required this.hiddenCount,
    required this.builtInCount,
  });

  final AppSettings settings;
  final int hiddenCount;

  /// 기본 아이템 DB 개수(숨김 포함).
  final int builtInCount;
}

@riverpod
Stream<List<Item>> _settingsHidden(Ref ref) =>
    ref.watch(itemDaoProvider).watchHiddenItems();

@riverpod
Stream<({int builtIn, int custom})> _settingsCounts(Ref ref) =>
    ref.watch(itemDaoProvider).watchCounts();

@riverpod
AsyncValue<SettingsUiState> settingsUiState(Ref ref) {
  final seeded = ref.watch(seedBootstrapProvider);
  final settingsAsync = ref.watch(appSettingsProvider);
  final hiddenAsync = ref.watch(_settingsHiddenProvider);
  final countsAsync = ref.watch(_settingsCountsProvider);
  return combineAsync(
    [seeded, settingsAsync, hiddenAsync, countsAsync],
    () => SettingsUiState(
      settings: settingsAsync.requireValue,
      hiddenCount: hiddenAsync.requireValue.length,
      builtInCount: countsAsync.requireValue.builtIn,
    ),
  );
}

@riverpod
Stream<List<Item>> hiddenItems(Ref ref) =>
    ref.watch(itemDaoProvider).watchHiddenItems();
