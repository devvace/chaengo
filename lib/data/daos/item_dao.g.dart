// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_dao.dart';

// ignore_for_file: type=lint
mixin _$ItemDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItemsTable get items => attachedDatabase.items;
  $GearSetsTable get gearSets => attachedDatabase.gearSets;
  $GearSetItemsTable get gearSetItems => attachedDatabase.gearSetItems;
  ItemDaoManager get managers => ItemDaoManager(this);
}

class ItemDaoManager {
  final _$ItemDaoMixin _db;
  ItemDaoManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$GearSetsTableTableManager get gearSets =>
      $$GearSetsTableTableManager(_db.attachedDatabase, _db.gearSets);
  $$GearSetItemsTableTableManager get gearSetItems =>
      $$GearSetItemsTableTableManager(_db.attachedDatabase, _db.gearSetItems);
}
