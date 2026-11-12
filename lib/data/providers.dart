import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/app_settings.dart';
import 'daos/item_dao.dart';
import 'daos/set_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/trip_dao.dart';
import 'database.dart';
import 'seed/seed_loader.dart';

part 'providers.g.dart';

/// 앱 전체가 공유하는 단일 DB 연결.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
ItemDao itemDao(Ref ref) => ref.watch(appDatabaseProvider).itemDao;

@Riverpod(keepAlive: true)
SetDao setDao(Ref ref) => ref.watch(appDatabaseProvider).setDao;

@Riverpod(keepAlive: true)
TripDao tripDao(Ref ref) => ref.watch(appDatabaseProvider).tripDao;

@Riverpod(keepAlive: true)
SettingsDao settingsDao(Ref ref) => ref.watch(appDatabaseProvider).settingsDao;

@Riverpod(keepAlive: true)
SeedLoader seedLoader(Ref ref) => SeedLoader(ref.watch(appDatabaseProvider));

/// 앱 시작 시 시드 또는 기존 내장 아이템의 기본 아이콘 갱신을 기다린다.
@Riverpod(keepAlive: true)
Future<void> seedBootstrap(Ref ref) =>
    ref.watch(seedLoaderProvider).ensureSeeded();

/// 체크 화면 옵션(S09). S03 화면 켜짐·진동이 구독한다.
@Riverpod(keepAlive: true)
Stream<AppSettings> appSettings(Ref ref) =>
    ref.watch(settingsDaoProvider).watchSettings();
