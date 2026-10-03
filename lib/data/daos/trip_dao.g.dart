// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_dao.dart';

// ignore_for_file: type=lint
mixin _$TripDaoMixin on DatabaseAccessor<AppDatabase> {
  $GearSetsTable get gearSets => attachedDatabase.gearSets;
  $TripsTable get trips => attachedDatabase.trips;
  $ItemsTable get items => attachedDatabase.items;
  $TripItemsTable get tripItems => attachedDatabase.tripItems;
  $GearSetItemsTable get gearSetItems => attachedDatabase.gearSetItems;
  TripDaoManager get managers => TripDaoManager(this);
}

class TripDaoManager {
  final _$TripDaoMixin _db;
  TripDaoManager(this._db);
  $$GearSetsTableTableManager get gearSets =>
      $$GearSetsTableTableManager(_db.attachedDatabase, _db.gearSets);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db.attachedDatabase, _db.trips);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$TripItemsTableTableManager get tripItems =>
      $$TripItemsTableTableManager(_db.attachedDatabase, _db.tripItems);
  $$GearSetItemsTableTableManager get gearSetItems =>
      $$GearSetItemsTableTableManager(_db.attachedDatabase, _db.gearSetItems);
}
