import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/trip.dart';
import '../database.dart';
import '../mappers.dart';
import '../tables.dart';

part 'trip_dao.g.dart';

/// 트립 목록(S01)·생성(S02)·체크(S03)·아이템 추가(S04)가 쓰는 질의.
@DriftAccessor(tables: [Trips, TripItems, GearSets, GearSetItems, Items])
class TripDao extends DatabaseAccessor<AppDatabase> with _$TripDaoMixin {
  TripDao(super.db);

  static const _uuid = Uuid();

  /// S01 진행 중 카드. active 트립은 하나뿐이다.
  /// 스트림을 중첩(asyncExpand)하면 안쪽 watch가 끝나지 않아 완료·새 트립
  /// 전환이 반영되지 않으므로, 조인 한 번으로 구독한다.
  Stream<TripDetail?> watchActiveTrip() {
    final query = select(trips).join([
      leftOuterJoin(tripItems, tripItems.tripId.equalsExp(trips.id)),
      leftOuterJoin(items, items.id.equalsExp(tripItems.itemId)),
    ])..where(trips.status.equalsValue(TripStatus.active));
    return query.watch().map((rows) {
      final details = _groupIntoDetails(rows);
      return details.isEmpty ? null : details.first;
    });
  }

  /// S01 완료 리스트. 최신순.
  Stream<List<TripDetail>> watchDoneTrips() {
    final query = select(trips).join([
      leftOuterJoin(tripItems, tripItems.tripId.equalsExp(trips.id)),
      leftOuterJoin(items, items.id.equalsExp(tripItems.itemId)),
    ])..where(trips.status.equalsValue(TripStatus.done));
    return query.watch().map((rows) {
      final details = _groupIntoDetails(rows);
      details.sort((a, b) {
        final aAt = a.trip.completedAt ?? a.trip.createdAt;
        final bAt = b.trip.completedAt ?? b.trip.createdAt;
        final byCompleted = bAt.compareTo(aAt);
        if (byCompleted != 0) return byCompleted;
        // 같은 시각이면 나중에 만든 트립이 위로.
        return b.trip.createdAt.compareTo(a.trip.createdAt);
      });
      return details;
    });
  }

  /// S03이 구독하는 트립 한 건.
  Stream<TripDetail?> watchTripDetail(String tripId) {
    final query = select(trips).join([
      leftOuterJoin(tripItems, tripItems.tripId.equalsExp(trips.id)),
      leftOuterJoin(items, items.id.equalsExp(tripItems.itemId)),
    ])..where(trips.id.equals(tripId));
    return query.watch().map((rows) {
      final details = _groupIntoDetails(rows);
      return details.isEmpty ? null : details.first;
    });
  }

  Future<Trip?> findById(String tripId) async {
    final row = await (select(
      trips,
    )..where((t) => t.id.equals(tripId))).getSingleOrNull();
    return row?.toModel();
  }

  Future<Trip?> findActiveTrip() async {
    final row = await (select(
      trips,
    )..where((t) => t.status.equalsValue(TripStatus.active))).getSingleOrNull();
    return row?.toModel();
  }

  /// S02 [트립 만들기]. 세트 구성을 **복사**하므로 이후 세트를 고쳐도
  /// 이 트립은 그대로다. [setId]가 null이면 빈 트립([세트 없이 시작]).
  ///
  /// 이미 진행 중인 트립이 있으면 [StateError]를 던진다. S01이 먼저
  /// "기존 트립을 완료 처리할까요?"로 확인한 뒤 [completeTrip]을 부른다.
  Future<String> createTrip({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? setId,
  }) async {
    final tripId = _uuid.v4();
    await transaction(() async {
      if (await findActiveTrip() != null) {
        throw StateError('진행 중인 트립이 이미 있다');
      }
      final now = DateTime.now();
      await into(trips).insert(
        TripsCompanion.insert(
          id: tripId,
          name: name.trim(),
          startDate: startDate,
          endDate: endDate,
          sourceSetId: Value(setId),
          status: TripStatus.active,
          createdAt: now,
        ),
      );
      if (setId != null) {
        // 숨긴 아이템은 세트에 남아 있어도 트립으로 복사하지 않는다.
        final entries =
            await (select(gearSetItems).join([
                  innerJoin(items, items.id.equalsExp(gearSetItems.itemId)),
                ])..where(
                  gearSetItems.setId.equals(setId) &
                      items.isHidden.equals(false),
                ))
                .map((row) => row.readTable(gearSetItems))
                .get();
        if (entries.isNotEmpty) {
          await batch((b) {
            b.insertAll(tripItems, [
              for (final entry in entries)
                TripItemsCompanion.insert(
                  tripId: tripId,
                  itemId: entry.itemId,
                  qty: Value(entry.qty),
                  state: PackState.unpacked,
                ),
            ]);
          });
        }
        await attachedDatabase.setDao.touchLastUsed(setId, now);
      }
    });
    return tripId;
  }

  /// S03 타일 탭. 즉시 저장이라 별도 저장 버튼이 없다.
  Future<void> setItemState(
    String tripId,
    String itemId,
    PackState state,
  ) async {
    await (update(tripItems)
          ..where((t) => t.tripId.equals(tripId) & t.itemId.equals(itemId)))
        .write(TripItemsCompanion(state: Value(state)));
  }

  /// 롱프레스 수량 조절(1–99).
  Future<void> setItemQty(String tripId, String itemId, int qty) async {
    requireValidQty(qty);
    await (update(tripItems)
          ..where((t) => t.tripId.equals(tripId) & t.itemId.equals(itemId)))
        .write(TripItemsCompanion(qty: Value(qty)));
  }

  /// S04 [n개 추가]. 미챙김 상태로 들어간다. 이미 있는 아이템은 건너뛴다.
  Future<void> addItems(String tripId, Iterable<String> itemIds) async {
    final ids = itemIds.toList();
    if (ids.isEmpty) return;
    final itemRows = await attachedDatabase.itemDao.getByIds(ids);
    await batch((b) {
      b.insertAll(tripItems, [
        for (final item in itemRows)
          TripItemsCompanion.insert(
            tripId: tripId,
            itemId: item.id,
            qty: Value(item.defaultQty),
            state: PackState.unpacked,
          ),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  /// 롱프레스 > 트립에서 삭제.
  Future<void> removeItem(String tripId, String itemId) async {
    await (delete(
      tripItems,
    )..where((t) => t.tripId.equals(tripId) & t.itemId.equals(itemId))).go();
  }

  /// S04가 쓰는 "트립에 아직 없는 아이템" 판정용.
  Stream<Set<String>> watchTripItemIds(String tripId) {
    return (select(tripItems)..where((t) => t.tripId.equals(tripId)))
        .watch()
        .map((rows) => {for (final row in rows) row.itemId});
  }

  /// S03 [캠핑 완료]. 완료하면 읽기 전용으로 잠긴다.
  Future<void> completeTrip(String tripId) async {
    await (update(trips)..where((t) => t.id.equals(tripId))).write(
      TripsCompanion(
        status: const Value(TripStatus.done),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  /// ⋯ > 완료 취소. 진행 중 트립이 따로 있으면 되돌릴 수 없다.
  Future<void> reopenTrip(String tripId) async {
    await transaction(() async {
      final active = await findActiveTrip();
      if (active != null && active.id != tripId) {
        throw StateError('진행 중인 트립이 이미 있다');
      }
      await (update(trips)..where((t) => t.id.equals(tripId))).write(
        const TripsCompanion(
          status: Value(TripStatus.active),
          completedAt: Value(null),
        ),
      );
    });
  }

  Future<void> renameTrip(String tripId, String name) async {
    await (update(trips)..where((t) => t.id.equals(tripId))).write(
      TripsCompanion(name: Value(name.trim())),
    );
  }

  Future<void> deleteTrip(String tripId) async {
    await (delete(trips)..where((t) => t.id.equals(tripId))).go();
  }

  /// S01 완료 트립 [세트로 저장] → S06에서 [저장]을 누를 때 호출한다.
  /// [entries]가 null이면 트립 구성을 그대로 복사하고, 있으면 S06에서
  /// 고친 구성으로 만든다. 다시 저장하지 못하도록 트립에 세트 id를 기록하며,
  /// 나중에 그 세트를 지우면 FK(setNull)가 기록을 지워 다시 저장할 수 있다.
  Future<String> saveTripAsSet(
    String tripId, {
    String? name,
    Map<String, int>? entries,
  }) async {
    late String setId;
    await transaction(() async {
      final trip = await findById(tripId);
      if (trip == null) {
        throw StateError('없는 트립은 세트로 저장할 수 없다: $tripId');
      }
      final resolved =
          entries ??
          {
            for (final row in await (select(
              tripItems,
            )..where((t) => t.tripId.equals(tripId))).get())
              row.itemId: row.qty,
          };
      setId = await attachedDatabase.setDao.createSet(
        name: name ?? trip.name,
        entries: resolved,
      );
      await (update(trips)..where((t) => t.id.equals(tripId))).write(
        TripsCompanion(savedAsSetId: Value(setId)),
      );
    });
    return setId;
  }

  /// S06이 "트립에서 저장" 모드로 열릴 때 초기 구성.
  Future<Map<String, int>> tripEntries(String tripId) async {
    final rows = await (select(
      tripItems,
    )..where((t) => t.tripId.equals(tripId))).get();
    return {for (final row in rows) row.itemId: row.qty};
  }

  List<TripDetail> _groupIntoDetails(List<TypedResult> rows) {
    final tripsById = <String, Trip>{};
    final itemsByTrip = <String, List<TripItem>>{};
    for (final row in rows) {
      final trip = row.readTable(trips).toModel();
      tripsById.putIfAbsent(trip.id, () => trip);
      final bucket = itemsByTrip.putIfAbsent(trip.id, () => <TripItem>[]);
      final itemRow = row.readTableOrNull(items);
      final tripItemRow = row.readTableOrNull(tripItems);
      if (itemRow != null && tripItemRow != null) {
        bucket.add(
          TripItem(
            item: itemRow.toModel(),
            qty: tripItemRow.qty,
            state: tripItemRow.state,
          ),
        );
      }
    }
    return [
      for (final trip in tripsById.values)
        TripDetail(
          trip: trip,
          items: itemsByTrip[trip.id]!
            ..sort((a, b) => compareItemsForDisplay(a.item, b.item)),
        ),
    ];
  }
}
