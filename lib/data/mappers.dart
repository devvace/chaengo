import '../domain/models/gear_set.dart';
import '../domain/models/item.dart';
import '../domain/models/trip.dart';
import 'database.dart';

extension ItemRowMapper on ItemRow {
  Item toModel() => Item(
    id: id,
    name: name,
    category: category,
    iconKey: iconKey,
    defaultQty: defaultQty,
    isBuiltIn: isBuiltIn,
    isHidden: isHidden,
    sortOrder: sortOrder,
  );
}

extension GearSetRowMapper on GearSetRow {
  GearSet toModel() => GearSet(
    id: id,
    name: name,
    isBuiltIn: isBuiltIn,
    lastUsedAt: lastUsedAt,
    createdAt: createdAt,
  );
}

extension TripRowMapper on TripRow {
  Trip toModel() => Trip(
    id: id,
    name: name,
    startDate: startDate,
    endDate: endDate,
    sourceSetId: sourceSetId,
    savedAsSetId: savedAsSetId,
    status: status,
    createdAt: createdAt,
    completedAt: completedAt,
  );
}

/// 카테고리 순서 → 카테고리 안 정렬 순서 → 이름. 목록·그리드 공통.
int compareItemsForDisplay(Item a, Item b) {
  final byCategory = a.category.index.compareTo(b.category.index);
  if (byCategory != 0) return byCategory;
  final byOrder = a.sortOrder.compareTo(b.sortOrder);
  if (byOrder != 0) return byOrder;
  return a.name.compareTo(b.name);
}

/// LIKE 패턴에 쓰이는 메타문자를 막는다. `\`를 이스케이프 문자로 쓴다.
String escapeLike(String raw) =>
    raw.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

/// 수량이 쓰이는 모든 경로(S03·S06 롱프레스, S08 스테퍼, 시드, 백업 가져오기)
/// 에서 1–99를 강제한다. drift가 컬럼 자기참조 check 제약을 생성하지
/// 않으므로 DB 대신 여기서 막는다.
int requireValidQty(int qty) {
  if (qty < 1 || qty > 99) {
    throw ArgumentError.value(qty, 'qty', '수량은 1–99여야 한다');
  }
  return qty;
}
