import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/models/item_category.dart';
import '../domain/models/trip.dart';
import 'converters.dart';
import 'daos/item_dao.dart';
import 'daos/set_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/trip_dao.dart';
import 'tables.dart';

part 'database.g.dart';

/// DB 스키마 버전. 백업 JSON도 **같은 값**을 쓴다
/// (assets/seed_items.json의 schemaVersion과도 일치해야 한다).
const int kSchemaVersion = 1;

/// active 트립이 둘 이상 생기지 못하게 막는 부분 유니크 인덱스.
/// 앱 로직(TripDao)에서도 막지만, 마지막 방어선을 DB에 둔다.
const String _singleActiveTripIndex =
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_trips_single_active "
    "ON trips (status) WHERE status = 'active'";

@DriftDatabase(
  tables: [Items, GearSets, GearSetItems, Trips, TripItems, AppSettingsTable],
  daos: [ItemDao, SetDao, TripDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'chaengo'));

  /// 테스트용. 메모리 DB 등 연결을 직접 넘긴다.
  AppDatabase.withExecutor(super.executor);

  /// 날짜를 ISO-8601 문자열로 저장한다. drift 기본값인 unix 초로 두면
  /// 같은 초에 완료한 트립의 '최신순'이 뒤섞이고, 백업 JSON에서도
  /// 시간대 정보가 사라진다.
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  int get schemaVersion => kSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(_singleActiveTripIndex);
    },
    beforeOpen: (details) async {
      // onDelete(cascade/setNull)는 이 PRAGMA가 켜져 있어야 동작한다.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// 전체 초기화(S09). 표를 비우기만 하고 다시 시드하는 건 호출자 몫이다.
  /// 설정(화면 켜짐·진동)은 데이터가 아니라 기기 취향이므로 남긴다.
  Future<void> clearAll() async {
    await transaction(() async {
      await delete(tripItems).go();
      await delete(trips).go();
      await delete(gearSetItems).go();
      await delete(gearSets).go();
      await delete(items).go();
    });
  }
}
