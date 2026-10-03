import 'package:chaengo/app/theme/tokens.dart';
import 'package:chaengo/data/database.dart';
import 'package:chaengo/data/providers.dart';
import 'package:chaengo/features/inventory/inventory_page.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('숨긴 아이템은 목록에서 빠지고, 검색하면 회색 숨김 태그로 나온다', (tester) async {
    // 위젯 테스트의 가짜 시간 안에서는 drift가 스트림 정리를 미루면 끝나지
    // 않으므로 즉시 닫도록 한다.
    final db = AppDatabase.withExecutor(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: InventoryPage()),
      ),
    );
    // 화면이 띄우는 seedBootstrap이 시드를 넣을 때까지 기다린다.
    await _settle(tester);
    await tester.runAsync(() => db.itemDao.setHidden('tent', hidden: true));
    await _settle(tester);

    // 목록에는 없다.
    expect(find.text('텐트'), findsNothing);
    expect(find.text('타프'), findsOneWidget);

    // 검색하면 숨김 태그와 함께 나온다.
    await tester.enterText(find.byType(TextField), '텐트');
    await _settle(tester);
    final grayRow = find.byWidgetPredicate(
      (w) => w is Text && w.data == '텐트' && w.style?.color == AppColors.inkMute,
    );
    expect(grayRow, findsOneWidget);
    expect(find.text('숨김'), findsOneWidget);

    // 화면을 내린 뒤 실제 비동기 안에서 DB를 닫아야 가짜 시간에 걸리지 않는다.
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });
}

/// drift 스트림은 실제 비동기라 runAsync로 한 번 흘려보낸 뒤 그린다.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}
