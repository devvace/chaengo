// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_dao.dart';

// ignore_for_file: type=lint
mixin _$SetDaoMixin on DatabaseAccessor<AppDatabase> {
  $GearSetsTable get gearSets => attachedDatabase.gearSets;
  $ItemsTable get items => attachedDatabase.items;
  $GearSetItemsTable get gearSetItems => attachedDatabase.gearSetItems;
  $TripsTable get trips => attachedDatabase.trips;
  SetDaoManager get managers => SetDaoManager(this);
}

class SetDaoManager {
  final _$SetDaoMixin _db;
  SetDaoManager(this._db);
  $$GearSetsTableTableManager get gearSets =>
      $$GearSetsTableTableManager(_db.attachedDatabase, _db.gearSets);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$GearSetItemsTableTableManager get gearSetItems =>
      $$GearSetItemsTableTableManager(_db.attachedDatabase, _db.gearSetItems);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db.attachedDatabase, _db.trips);
}
