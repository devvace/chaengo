import 'dart:io';

import 'package:chaengo/data/database.dart';
import 'package:chaengo/data/providers.dart';
import 'package:chaengo/data/seed/seed_loader.dart';
import 'package:chaengo/features/sets/set_edit_page.dart';
import 'package:chaengo/features/sets/set_edit_state.dart';
import 'package:chaengo/widgets/item_tile.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late GoRouter router;
  Object? popped;

  setUp(() {
    db = AppDatabase.withExecutor(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    popped = null;
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  popped = await context.push<String>('/edit'),
              child: const Text('open'),
            ),
          ),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) =>
                  const SetEditPage(args: SetEditArgs()),
            ),
          ],
        ),
      ],
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    // rootBundle 캐시가 이전 테스트의 가짜 시간에 묶이지 않도록 시드는
    // 저장소 파일에서 직접 넣는다. 화면의 seedBootstrap은 개수만 확인한다.
    await tester.runAsync(
      () => SeedLoader(db, bundle: _DiskBundle()).ensureSeeded(),
    );
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.text('open'));
    // 시드가 들어와 타일이 그려질 때까지 기다린다.
    for (var i = 0; i < 50; i++) {
      await _settle(tester);
      if (find.widgetWithText(ItemTile, '텐트').evaluate().isNotEmpty) break;
    }
  }

  Future<void> tearDownApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  }

  testWidgets('새 세트: 이름 + 타일 탭 → 저장하면 DB에 생기고 id를 돌려준다', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), '여름');
    await tester.tap(find.widgetWithText(ItemTile, '텐트'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget); // 담김 개수

    await tester.tap(find.text('저장'));
    await _settle(tester);

    expect(popped, isA<String>());
    final entries = await tester.runAsync(
      () => db.setDao.getEntries(popped! as String),
    );
    expect(entries, {'tent': 1});
    await tearDownApp(tester);
  });

  testWidgets('저장 안 하고 닫으면 폐기 확인을 띄우고, 버리면 아무것도 안 생긴다', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(ItemTile, '텐트'));
    await tester.pump();
    await tester.tap(find.byTooltip('닫기'));
    await _settle(tester);
    expect(find.text('변경 사항을 버릴까요?'), findsOneWidget);

    await tester.tap(find.text('버리기'));
    await _settle(tester);
    expect(find.text('open'), findsOneWidget);
    expect(popped, isNull);

    final sets = await tester.runAsync(() => db.setDao.watchSets().first);
    expect(sets, hasLength(1)); // 기본 세트만
    await tearDownApp(tester);
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
