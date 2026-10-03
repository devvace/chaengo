import 'dart:io';

import 'package:chaengo/data/database.dart';
import 'package:chaengo/data/providers.dart';
import 'package:chaengo/data/seed/seed_loader.dart';
import 'package:chaengo/domain/models/trip.dart';
import 'package:chaengo/features/trips/trip_check_page.dart';
import 'package:chaengo/widgets/item_tile.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('타일 탭은 즉시 DB에 저장되고, 제외 타일은 탭해도 바뀌지 않는다', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final db = AppDatabase.withExecutor(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    late String tripId;
    await tester.runAsync(() async {
      await SeedLoader(db, bundle: _DiskBundle()).ensureSeeded();
      final setId = (await db.setDao.watchSets().first).single.set.id;
      tripId = await db.tripDao.createTrip(
        name: '테스트',
        startDate: DateTime(2026, 10, 10),
        endDate: DateTime(2026, 10, 11),
        setId: setId,
      );
      await db.tripDao.setItemState(tripId, 'tarp', PackState.excluded);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: TripCheckPage(tripId: tripId)),
      ),
    );
    for (var i = 0; i < 50; i++) {
      await _settle(tester);
      if (find.widgetWithText(ItemTile, '텐트').evaluate().isNotEmpty) break;
    }

    Future<PackState> stateOf(String itemId) async {
      final detail = await tester.runAsync(
        () => db.tripDao.watchTripDetail(tripId).first,
      );
      return detail!.items.firstWhere((i) => i.item.id == itemId).state;
    }

    await tester.tap(find.widgetWithText(ItemTile, '텐트'));
    await _settle(tester);
    expect(await stateOf('tent'), PackState.packed);

    await tester.tap(find.widgetWithText(ItemTile, '타프'));
    await _settle(tester);
    expect(await stateOf('tarp'), PackState.excluded);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(await File(key).readAsBytes());

  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      File(key).readAsString();
}
