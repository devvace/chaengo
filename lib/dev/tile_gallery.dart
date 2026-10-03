import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/tokens.dart';
import '../app/theme/typography.dart';
import '../data/providers.dart';
import '../domain/models/item.dart';
import '../domain/models/item_category.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_icon.dart';
import '../widgets/app_tab_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/category_header.dart';
import '../widgets/item_tile.dart';
import '../widgets/progress_bar.dart';
import '../widgets/tile_grid.dart';

/// 2단계 점검용 데모 화면: 타일 두 문법의 모든 상태, 공통 위젯, 아이콘 전체.
/// 실제 화면이 붙으면 main.dart 연결이 라우터로 바뀐다. DB에는 쓰지 않는다.
class TileGalleryPage extends ConsumerStatefulWidget {
  const TileGalleryPage({super.key});

  @override
  ConsumerState<TileGalleryPage> createState() => _TileGalleryPageState();
}

class _TileGalleryPageState extends ConsumerState<TileGalleryPage> {
  final _checkStates = <String, CheckTileState>{};
  final _included = <String, bool>{};
  var _sortUnpackedFirst = true;
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final bootstrap = ref.watch(seedBootstrapProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('타일·위젯 데모')),
      bottomNavigationBar: AppTabBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
      body: bootstrap.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('시드 실패: $e')),
        data: (_) => StreamBuilder<List<Item>>(
          stream: ref.watch(itemDaoProvider).watchItems(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <Item>[];
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPadding,
                8,
                AppSizes.screenPadding,
                32,
              ),
              children: [
                ..._section('S03 체크 문법 (탭 = 챙김 토글, 길게 = 제외 토글)'),
                TileGrid(
                  children: const [
                    ItemTile.check(
                      label: '미챙김',
                      glyph: SvgGlyph('ic_tent'),
                      state: CheckTileState.unpacked,
                    ),
                    ItemTile.check(
                      label: '챙김',
                      glyph: SvgGlyph('ic_tent'),
                      state: CheckTileState.packed,
                    ),
                    ItemTile.check(
                      label: '제외',
                      glyph: SvgGlyph('ic_tent'),
                      state: CheckTileState.excluded,
                    ),
                    ItemTile.check(
                      label: '수량 12',
                      glyph: SvgGlyph('ic_peg'),
                      state: CheckTileState.unpacked,
                      qty: 12,
                    ),
                  ],
                ),
                ..._section('S06 편집 문법 (탭 = 담기·빼기)'),
                TileGrid(
                  children: const [
                    ItemTile.edit(
                      label: '담김',
                      glyph: SvgGlyph('ic_tent'),
                      included: true,
                    ),
                    ItemTile.edit(
                      label: '안 담김',
                      glyph: SvgGlyph('ic_tent'),
                      included: false,
                    ),
                    ItemTile.edit(
                      label: '수량 4',
                      glyph: SvgGlyph('ic_chair'),
                      included: true,
                      qty: 4,
                    ),
                    ItemTile.edit(
                      label: '이름이 길어 두 줄로 넘어가는 아이템',
                      glyph: SvgGlyph('cat_misc'),
                      included: true,
                    ),
                    ItemTile.edit(
                      label: '이모지 담김',
                      glyph: EmojiGlyph('🧺'),
                      included: true,
                    ),
                    ItemTile.edit(
                      label: '이모지 안 담김',
                      glyph: EmojiGlyph('🧺'),
                      included: false,
                    ),
                    ItemTile.check(
                      label: '이모지 챙김',
                      glyph: EmojiGlyph('🧺'),
                      state: CheckTileState.packed,
                    ),
                    ItemTile.check(
                      label: '이모지 제외',
                      glyph: EmojiGlyph('🧺'),
                      state: CheckTileState.excluded,
                    ),
                  ],
                ),
                ..._section('진행바·버튼·칩'),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '12', style: AppText.progressNumber),
                      TextSpan(text: '/34', style: AppText.progressDenominator),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const ProgressBar(value: 12 / 34),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '23',
                              style: AppText.bigNumber.copyWith(
                                color: AppColors.cardDarkText,
                              ),
                            ),
                            TextSpan(
                              text: '/34',
                              style: AppText.bigNumberDenominator,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ProgressBar.onDark(value: 23 / 34),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppChip(
                      label: '안 챙긴 것 먼저',
                      selected: _sortUnpackedFirst,
                      leading: const Icon(Icons.check),
                      onTap: () => setState(() => _sortUnpackedFirst = true),
                    ),
                    AppChip(
                      label: '카테고리순',
                      selected: !_sortUnpackedFirst,
                      leading: const Icon(Icons.check),
                      onTap: () => setState(() => _sortUnpackedFirst = false),
                    ),
                    RoundIconButton(
                      icon: Icons.add,
                      semanticLabel: '아이템 추가',
                      onTap: () {},
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    PillButton(label: '세트로 저장', onPressed: () {}),
                    const PillButton(
                      label: '저장됨',
                      style: PillStyle.muted,
                      onPressed: null,
                    ),
                    PillButton(
                      label: '저장',
                      style: PillStyle.filled,
                      onPressed: () {},
                    ),
                    const AppTag('기본'),
                    const AppTag('커스텀'),
                  ],
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: '캠핑 완료',
                  trailing: '11개 남음',
                  onPressed: () {},
                ),
                const SizedBox(height: 8),
                SecondaryButton(
                  label: '새 트립',
                  icon: Icons.add,
                  onPressed: () {},
                ),
                const SizedBox(height: 8),
                const PrimaryButton(label: '트립 만들기 (비활성)', onPressed: null),
                DangerTextButton(label: '세트 삭제', onPressed: () {}),
                ..._section('시드 아이템 ${items.length}개 — S03 문법으로 눌러보기'),
                for (final category in ItemCategory.values)
                  ..._categoryBlock(
                    category,
                    items.where((i) => i.category == category).toList(),
                  ),
                ..._section('같은 아이템 — S06 문법'),
                TileGrid(
                  children: [
                    for (final item in items.take(12))
                      ItemTile.edit(
                        label: item.name,
                        glyph: item.glyph,
                        included: _included[item.id] ?? false,
                        qty: item.defaultQty,
                        onTap: () => setState(
                          () => _included[item.id] =
                              !(_included[item.id] ?? false),
                        ),
                      ),
                  ],
                ),
                ..._section('카테고리·탭 아이콘'),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final c in ItemCategory.values)
                      AppIcon(c.iconKey, size: 32, color: AppColors.ink),
                    for (final k in const [
                      'tab_trips',
                      'tab_sets',
                      'tab_inventory',
                      'tab_settings',
                    ])
                      AppIcon(k, size: 32, color: AppColors.ink),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _section(String title) => [
    const SizedBox(height: 24),
    Text(title, style: AppText.sectionLabel),
    const SizedBox(height: 12),
  ];

  List<Widget> _categoryBlock(ItemCategory category, List<Item> items) {
    final states = [
      for (final item in items)
        _checkStates[item.id] ?? CheckTileState.unpacked,
    ];
    final excluded = states.where((s) => s == CheckTileState.excluded).length;
    final packed = states.where((s) => s == CheckTileState.packed).length;
    return [
      const SizedBox(height: 12),
      CategoryHeader(
        title: category.label,
        count: packed,
        total: items.length - excluded,
      ),
      const SizedBox(height: 12),
      TileGrid(
        children: [
          for (final item in items)
            ItemTile.check(
              label: item.name,
              glyph: item.glyph,
              qty: item.defaultQty,
              state: _checkStates[item.id] ?? CheckTileState.unpacked,
              onTap: () => setState(() {
                final current =
                    _checkStates[item.id] ?? CheckTileState.unpacked;
                _checkStates[item.id] = current == CheckTileState.packed
                    ? CheckTileState.unpacked
                    : CheckTileState.packed;
              }),
              onLongPress: () => setState(() {
                final current =
                    _checkStates[item.id] ?? CheckTileState.unpacked;
                _checkStates[item.id] = current == CheckTileState.excluded
                    ? CheckTileState.unpacked
                    : CheckTileState.excluded;
              }),
            ),
        ],
      ),
    ];
  }
}
