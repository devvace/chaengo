import 'package:flutter/foundation.dart';

import 'item.dart';

/// 트립 진행 상태. done은 읽기 전용 잠금을 뜻한다.
enum TripStatus {
  active('active'),
  done('done');

  const TripStatus(this.id);

  final String id;

  static TripStatus fromId(String id) =>
      values.firstWhere((s) => s.id == id, orElse: () => TripStatus.active);
}

/// 트립 안에서 아이템 하나가 가질 수 있는 상태 3종.
///
/// [excluded]는 "이번엔 안 가져감"이라 진행률 분모에서 빠진다.
enum PackState {
  unpacked('unpacked'),
  packed('packed'),
  excluded('excluded');

  const PackState(this.id);

  final String id;

  static PackState fromId(String id) =>
      values.firstWhere((s) => s.id == id, orElse: () => PackState.unpacked);
}

/// 이번에 트렁크에 실을 것. 생성 시 세트 구성을 복사해 원본과 분리된다.
@immutable
class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.sourceSetId,
    required this.savedAsSetId,
    required this.status,
    required this.createdAt,
    required this.completedAt,
  });

  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  /// 어느 세트에서 복사했는지. 그 세트가 지워지면 null이 된다.
  final String? sourceSetId;

  /// [세트로 저장]으로 만들어 둔 세트. 그 세트가 지워지면 null로 돌아가
  /// S01에서 다시 저장할 수 있게 된다.
  final String? savedAsSetId;
  final TripStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isActive => status == TripStatus.active;
  bool get isSavedAsSet => savedAsSetId != null;

  Trip copyWith({
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? Function()? savedAsSetId,
    TripStatus? status,
    DateTime? Function()? completedAt,
  }) {
    return Trip(
      id: id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sourceSetId: sourceSetId,
      savedAsSetId: savedAsSetId == null ? this.savedAsSetId : savedAsSetId(),
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt == null ? this.completedAt : completedAt(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trip &&
          other.id == id &&
          other.name == name &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.sourceSetId == sourceSetId &&
          other.savedAsSetId == savedAsSetId &&
          other.status == status &&
          other.createdAt == createdAt &&
          other.completedAt == completedAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    startDate,
    endDate,
    sourceSetId,
    savedAsSetId,
    status,
    createdAt,
    completedAt,
  );
}

/// 트립에 복사된 아이템 한 줄.
@immutable
class TripItem {
  const TripItem({required this.item, required this.qty, required this.state});

  final Item item;
  final int qty;
  final PackState state;

  bool get isPacked => state == PackState.packed;
  bool get isExcluded => state == PackState.excluded;

  /// S03 타일 탭. 제외 상태는 탭에 반응하지 않는다(롱프레스로만 복귀).
  PackState get toggled => switch (state) {
    PackState.unpacked => PackState.packed,
    PackState.packed => PackState.unpacked,
    PackState.excluded => PackState.excluded,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripItem &&
          other.item == item &&
          other.qty == qty &&
          other.state == state;

  @override
  int get hashCode => Object.hash(item, qty, state);
}

/// S01 카드와 S03 헤더가 쓰는 진행률. 분모에서 제외 아이템을 뺀다.
@immutable
class TripProgress {
  const TripProgress({
    required this.packed,
    required this.total,
    required this.excluded,
  });

  const TripProgress.empty() : packed = 0, total = 0, excluded = 0;

  /// 챙긴 개수.
  final int packed;

  /// 제외를 뺀 전체 개수. 진행률의 분모.
  final int total;

  /// 제외한 개수. "타프 1개 제외" 문구에 쓴다.
  final int excluded;

  int get remaining => total - packed;
  bool get isComplete => total > 0 && packed == total;

  /// 0.0 ~ 1.0. 분모가 0이면 0.
  double get ratio => total == 0 ? 0 : packed / total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripProgress &&
          other.packed == packed &&
          other.total == total &&
          other.excluded == excluded;

  @override
  int get hashCode => Object.hash(packed, total, excluded);
}

/// 트립 + 복사된 아이템 전체. S03이 다루는 단위.
@immutable
class TripDetail {
  const TripDetail({required this.trip, required this.items});

  final Trip trip;
  final List<TripItem> items;

  TripProgress get progress {
    var packed = 0;
    var excluded = 0;
    for (final item in items) {
      if (item.isExcluded) {
        excluded++;
      } else if (item.isPacked) {
        packed++;
      }
    }
    return TripProgress(
      packed: packed,
      total: items.length - excluded,
      excluded: excluded,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripDetail &&
          other.trip == trip &&
          listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(trip, Object.hashAll(items));
}
