import 'package:flutter/foundation.dart';

import 'item.dart';

/// 상황별 아이템 묶음 템플릿. Dart의 `Set`과 겹치지 않게 GearSet으로 둔다.
///
/// 트립을 만들 때 이 구성을 **복사**하므로, 이후 세트를 고쳐도
/// 이미 만든 트립에는 영향이 없다.
@immutable
class GearSet {
  const GearSet({
    required this.id,
    required this.name,
    required this.isBuiltIn,
    required this.lastUsedAt,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// 앱 내장 세트("기본 오토캠핑"). 삭제 불가, 편집은 가능.
  final bool isBuiltIn;

  /// 이 세트로 트립을 만든 마지막 시각. S05 정렬과 S02 기본 선택에 쓴다.
  final DateTime? lastUsedAt;
  final DateTime createdAt;

  GearSet copyWith({String? name, DateTime? Function()? lastUsedAt}) {
    return GearSet(
      id: id,
      name: name ?? this.name,
      isBuiltIn: isBuiltIn,
      lastUsedAt: lastUsedAt == null ? this.lastUsedAt : lastUsedAt(),
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GearSet &&
          other.id == id &&
          other.name == name &&
          other.isBuiltIn == isBuiltIn &&
          other.lastUsedAt == lastUsedAt &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, name, isBuiltIn, lastUsedAt, createdAt);
}

/// 세트에 담긴 아이템 한 줄.
@immutable
class GearSetEntry {
  const GearSetEntry({required this.item, required this.qty});

  final Item item;
  final int qty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GearSetEntry && other.item == item && other.qty == qty;

  @override
  int get hashCode => Object.hash(item, qty);
}

/// 세트 + 담긴 아이템 전체. S06 편집 화면이 다루는 단위.
@immutable
class GearSetDetail {
  const GearSetDetail({required this.set, required this.entries});

  final GearSet set;
  final List<GearSetEntry> entries;

  int get itemCount => entries.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GearSetDetail &&
          other.set == set &&
          listEquals(other.entries, entries);

  @override
  int get hashCode => Object.hash(set, Object.hashAll(entries));
}
