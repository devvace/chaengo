import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../data/providers.dart';
import '../../domain/models/item.dart';
import '../../domain/models/item_category.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/buttons.dart';
import '../../widgets/search_field.dart';
import '../../widgets/small_icon_tile.dart';
import 'inventory_state.dart';
import 'item_actions.dart';

/// S07 창고(아이템 목록) — 하단 탭 3.
class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(inventoryUiStateProvider);
    final filter = ref.watch(inventoryFilterControllerProvider);
    final controller = ref.read(inventoryFilterControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              builtIn: ui.value?.builtInCount,
              custom: ui.value?.customCount,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenPadding,
              ),
              child: SearchField(
                hint: '아이템 이름',
                onChanged: controller.setQuery,
              ),
            ),
            const SizedBox(height: 4),
            _CategoryChips(
              selected: filter.category,
              onSelected: controller.setCategory,
            ),
            const Divider(),
            Expanded(
              child: ui.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Center(child: Text('불러오지 못했어요\n$e')),
                data: (state) => state.isEmpty
                    ? _Empty(searching: state.filter.isSearching)
                    : _ItemList(state: state),
              ),
            ),
            _AddBar(
              onAdd: () => context.push(Routes.itemNewIn(filter.category)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.builtIn, required this.custom});

  final int? builtIn;
  final int? custom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPadding,
        16,
        AppSizes.screenPadding,
        12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text('창고', style: AppText.screenTitle)),
          if (builtIn != null && custom != null)
            Text.rich(
              withMonoDigits('기본 $builtIn · 커스텀 $custom', AppText.caption),
            ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final ItemCategory? selected;
  final ValueChanged<ItemCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
      child: Row(
        children: [
          AppChip(
            label: '전체',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in ItemCategory.values) ...[
            const SizedBox(width: 8),
            AppChip(
              label: category.label,
              selected: selected == category,
              onTap: () => onSelected(category),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({required this.state});

  final InventoryUiState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        for (final group in state.groups) ...[
          SliverToBoxAdapter(
            child: _GroupHeader(
              category: group.category,
              count: group.items.length,
            ),
          ),
          SliverList.separated(
            itemCount: group.items.length,
            separatorBuilder: (context, _) => const Divider(
              indent: AppSizes.screenPadding,
              endIndent: AppSizes.screenPadding,
            ),
            itemBuilder: (context, i) {
              final item = group.items[i];
              return _ItemRow(
                key: ValueKey(item.id),
                item: item,
                setCount: state.setCountOf(item.id),
              );
            },
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.category, required this.count});

  final ItemCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPadding,
        20,
        AppSizes.screenPadding,
        4,
      ),
      child: Row(
        children: [
          Text(category.label, style: AppText.sectionLabel),
          const SizedBox(width: 6),
          Text('$count', style: AppText.monoLabel),
        ],
      ),
    );
  }
}

class _ItemRow extends ConsumerWidget {
  const _ItemRow({super.key, required this.item, required this.setCount});

  final Item item;
  final int setCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.read(itemDaoProvider);
    final muted = item.isHidden;

    final row = InkWell(
      onTap: () => context.push(Routes.itemEdit(item.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPadding,
          vertical: 10,
        ),
        child: Row(
          children: [
            SmallIconTile(
              glyph: item.glyph,
              tileSize: AppSizes.previewTile,
              iconSize: AppSizes.previewIcon,
              muted: muted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: muted ? AppColors.inkMute : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    withMonoDigits(
                      '기본 수량 ${item.defaultQty} · 세트 $setCount곳',
                      AppText.caption.copyWith(
                        color: muted ? AppColors.inkMute : AppColors.inkSub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppTag(
              item.isHidden
                  ? '숨김'
                  : item.isBuiltIn
                  ? '기본'
                  : '커스텀',
            ),
          ],
        ),
      ),
    );

    // 숨김 아이템은 검색에서만 보이며 스와이프가 없다(복구는 설정에서).
    if (item.isHidden) return row;

    final actionLabel = item.isBuiltIn ? '숨김' : '삭제';
    return Dismissible(
      key: ValueKey('swipe-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.surface,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.screenPadding),
        child: Text(
          actionLabel,
          style: AppText.button.copyWith(
            color: item.isBuiltIn ? AppColors.ink : AppColors.danger,
          ),
        ),
      ),
      // 실제 제거는 DB 스트림이 목록을 다시 그리며 처리한다. Dismissible이
      // 스스로 빼면 스트림 갱신 전 한 프레임 동안 트리 불일치가 나므로
      // 항상 false를 돌려준다.
      confirmDismiss: (_) async {
        if (item.isBuiltIn) {
          await dao.setHidden(item.id, hidden: true);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('‘${item.name}’ 숨김. 설정에서 복구할 수 있어요.')),
            );
          }
        } else {
          await confirmAndDeleteCustomItem(
            context,
            dao: dao,
            item: item,
            setCount: setCount,
          );
        }
        return false;
      },
      child: row,
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.searching});

  final bool searching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        searching ? '검색 결과가 없어요' : '이 카테고리에 아이템이 없어요',
        style: AppText.caption,
      ),
    );
  }
}

class _AddBar extends StatelessWidget {
  const _AddBar({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.line, width: AppSizes.hairline),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          12,
          AppSizes.screenPadding,
          12,
        ),
        child: PrimaryButton(label: '+ 아이템 추가', onPressed: onAdd),
      ),
    );
  }
}
