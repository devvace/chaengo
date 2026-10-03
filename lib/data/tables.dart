import 'package:drift/drift.dart';

import 'converters.dart';

/// 창고에 있는 모든 장비. 내장 아이템과 커스텀 아이템이 같은 표에 산다.
@DataClassName('ItemRow')
class Items extends Table {
  /// 내장 아이템은 시드 JSON의 id('tent'), 커스텀은 uuid v4.
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 20)();
  TextColumn get category =>
      text().map(const ItemCategoryConverter()).named('category_id')();

  /// null이면 카테고리 아이콘으로 폴백한다.
  TextColumn get iconKey => text().nullable()();

  /// 1–99. 범위는 DAO의 [requireValidQty]가 지킨다(drift가 컬럼
  /// 자기참조 check 제약을 생성해 주지 않는다).
  IntColumn get defaultQty => integer().withDefault(const Constant(1))();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  /// 같은 카테고리 안의 표시 순서. 시드는 파일 순서를 그대로 쓴다.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// 세트 템플릿. 트립은 여기서 구성을 복사해 간다.
@DataClassName('GearSetRow')
class GearSets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1)();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// 세트에 담긴 아이템. 아이템이 지워지면 함께 빠진다.
@DataClassName('GearSetItemRow')
class GearSetItems extends Table {
  TextColumn get setId =>
      text().references(GearSets, #id, onDelete: KeyAction.cascade)();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  IntColumn get qty => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {setId, itemId};
}

/// 한 번의 캠핑. 동시에 active는 하나뿐이며, 이 규칙은 DB의 부분 유니크
/// 인덱스(idx_trips_single_active)로도 막아 둔다.
@DataClassName('TripRow')
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1)();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();

  /// 복사해 온 원본 세트. 세트가 지워져도 트립 구성은 그대로 남는다.
  @ReferenceName('tripsFromSet')
  TextColumn get sourceSetId => text().nullable().references(
    GearSets,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// [세트로 저장]으로 만든 세트. 그 세트를 지우면 다시 저장할 수 있도록
  /// null로 되돌아간다.
  @ReferenceName('tripsSavedAsSet')
  TextColumn get savedAsSetId => text().nullable().references(
    GearSets,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get status => text().map(const TripStatusConverter())();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// 트립으로 복사된 아이템. 세트를 고쳐도 여기엔 영향이 없다.
@DataClassName('TripItemRow')
class TripItems extends Table {
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();
  IntColumn get qty => integer().withDefault(const Constant(1))();
  TextColumn get state => text().map(const PackStateConverter())();

  @override
  Set<Column<Object>> get primaryKey => {tripId, itemId};
}

/// 앱 설정(S09). 행은 항상 id = 1 하나뿐이다. 없으면 기본값으로 읽는다.
@DataClassName('AppSettingsRow')
class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  IntColumn get id => integer().withDefault(const Constant(1))();

  /// S03 화면 켜짐 유지. 기본 ON.
  BoolColumn get keepScreenOn => boolean().withDefault(const Constant(true))();

  /// 타일 탭 시 진동. 기본 ON.
  BoolColumn get haptics => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
