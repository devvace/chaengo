import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dev/tile_gallery.dart';
import '../domain/models/item_category.dart';
import '../features/inventory/inventory_page.dart';
import '../features/inventory/item_edit_page.dart';
import '../features/settings/hidden_items_page.dart';
import '../features/settings/settings_page.dart';
import '../features/sets/set_edit_page.dart';
import '../features/sets/set_edit_state.dart';
import '../features/sets/set_list_page.dart';
import '../features/trips/trip_check_page.dart';
import '../features/trips/trip_create_page.dart';
import '../features/trips/trip_list_page.dart';
import '../widgets/app_tab_bar.dart';

/// 경로 상수. 화면에서 문자열을 직접 쓰지 않는다.
abstract final class Routes {
  static const trips = '/trips';
  static const sets = '/sets';
  static const inventory = '/inventory';
  static const settings = '/settings';
  static const hiddenItems = '/settings/hidden';

  /// S08. 하단 탭을 덮는 풀스크린. pop 결과로 저장된 아이템 id를 돌려준다.
  static const itemNew = '/item/new';

  /// S08 추가 모드. [category]가 있으면 그 카테고리를 미리 고른다.
  static String itemNewIn(ItemCategory? category) =>
      category == null ? itemNew : '$itemNew?category=${category.id}';
  static String itemEdit(String id) => '/item/$id';

  /// S06. 저장하면 세트 id를 pop 결과로 돌려준다.
  static const setNew = '/set/new';
  static String setEdit(String id) => '/set/$id';

  /// S01 완료 트립 [세트로 저장].
  static String setFromTrip(String tripId) => '$setNew?fromTrip=$tripId';

  /// S02. [setId]가 있으면 그 세트를 고른 상태로 연다. 진입은 항상
  /// startNewTrip()을 거친다(진행 중 트립 확인).
  static const tripNew = '/trip/new';
  static String tripNewWith(String setId) => '$tripNew?set=$setId';

  /// S03. [openAddSheet]면 들어오자마자 S04를 연다.
  static String trip(String id, {bool openAddSheet = false}) =>
      openAddSheet ? '/trip/$id?add=1' : '/trip/$id';

  static const devTiles = '/dev/tiles';
}

final _rootKey = GlobalKey<NavigatorState>();

GoRouter buildRouter() => GoRouter(
  navigatorKey: _rootKey,
  initialLocation: Routes.trips,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _TabShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.trips,
              builder: (context, state) => const TripListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.sets,
              builder: (context, state) => const SetListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.inventory,
              builder: (context, state) => const InventoryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'hidden',
                  builder: (context, state) => const HiddenItemsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: Routes.itemNew,
      builder: (context, state) => ItemEditPage(
        itemId: null,
        initialCategory: ItemCategory.tryFromId(
          state.uri.queryParameters['category'] ?? '',
        ),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/item/:id',
      builder: (context, state) =>
          ItemEditPage(itemId: state.pathParameters['id']),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: Routes.setNew,
      builder: (context, state) => SetEditPage(
        args: SetEditArgs(fromTripId: state.uri.queryParameters['fromTrip']),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/set/:id',
      builder: (context, state) =>
          SetEditPage(args: SetEditArgs(setId: state.pathParameters['id'])),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: Routes.tripNew,
      builder: (context, state) =>
          TripCreatePage(preselectedSetId: state.uri.queryParameters['set']),
    ),
    GoRoute(
      parentNavigatorKey: _rootKey,
      path: '/trip/:id',
      builder: (context, state) => TripCheckPage(
        tripId: state.pathParameters['id']!,
        openAddSheet: state.uri.queryParameters['add'] == '1',
      ),
    ),
    if (kDebugMode)
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: Routes.devTiles,
        builder: (context, state) => const TileGalleryPage(),
      ),
  ],
);

class _TabShell extends StatelessWidget {
  const _TabShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppTabBar(
        currentIndex: shell.currentIndex,
        // 현재 탭을 다시 누르면 그 탭의 첫 화면으로.
        onTap: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
