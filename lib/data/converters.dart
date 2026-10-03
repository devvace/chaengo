import 'package:drift/drift.dart';

import '../domain/models/item_category.dart';
import '../domain/models/trip.dart';

/// enum을 안정적인 문자열 id로 저장한다. 인덱스로 저장하면 enum 순서를
/// 바꾸는 순간 기존 DB와 백업 JSON이 어긋나므로 쓰지 않는다.
class ItemCategoryConverter extends TypeConverter<ItemCategory, String> {
  const ItemCategoryConverter();

  @override
  ItemCategory fromSql(String fromDb) => ItemCategory.fromId(fromDb);

  @override
  String toSql(ItemCategory value) => value.id;
}

class TripStatusConverter extends TypeConverter<TripStatus, String> {
  const TripStatusConverter();

  @override
  TripStatus fromSql(String fromDb) => TripStatus.fromId(fromDb);

  @override
  String toSql(TripStatus value) => value.id;
}

class PackStateConverter extends TypeConverter<PackState, String> {
  const PackStateConverter();

  @override
  PackState fromSql(String fromDb) => PackState.fromId(fromDb);

  @override
  String toSql(PackState value) => value.id;
}
