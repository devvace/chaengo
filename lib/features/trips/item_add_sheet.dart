import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/async_combine.dart';
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

part 'item_add_sheet.g.dart';

/// S04 아이템 추가 시트(S03 위, 높이 ~76%).
Future<void> showItemAddSheet(BuildContext context, String tripId) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: _sheetHeight,
        child: ItemAddSheet(tripId: tripId),
      ),
    );

const _sheetHeight = 0.76;

/// 선택 상태. 딤 영역을 탭해 닫아도 선택은 남는다(02_screens.md S04).
/// 추가하면 비운다.
@Riverpod(keepAlive: true)
class TripAddSelection extends _$TripAddSelection {
  @override
  Set<String> build(String tripId) => const {};

  void toggle(String itemId) {
    final next = {...state};
    if (!next.remove(itemId)) next.add(itemId);
    state = next;
  }

  void add(String itemId) => state = {...state, itemId};

  void clear() => state = const {};
}

/// 트립에 아직 없는 아이템(숨김 제외).
@riverpod
AsyncValue<List<Item>> tripAddCandidates(Ref ref, String tripId) {
  final itemsAsync = ref.watch(_tripAddItemsProvider);
  final inTripAsync = ref.watch(_tripAddInTripProvider(tripId));
  return combineAsync([itemsAsync, inTripAsync], () {
    final inTrip = inTripAsync.requireValue;
    return [
      for (final item in itemsAsync.requireValue)
        if (!inTrip.contains(item.id)) item,
    ];
  });
}

@riverpod
Stream<List<Item>> _tripAddItems(Ref ref) =>
    ref.watch(itemDaoProvider).watchVisibleItems();

@riverpod
Stream<Set<String>> _tripAddInTrip(Ref ref, String tripId) =>
    ref.watch(tripDaoProvider).watchTripItemIds(tripId);

class ItemAddSheet extends ConsumerStatefulWidget {
  const ItemAddSheet({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<ItemAddSheet> createState() => _ItemAddSheetState();
}

class _ItemAddSheetState extends ConsumerState<ItemAddSheet> {
  var _query = '';
  ItemCategory? _category;
  var _adding = false;

  TripAddSelectionProvider get _selection =>
      tripAddSelectionProvider(widget.tripId);

  Future<void> _createCustom() async {
    final id = await context.push<String>(Routes.itemNewIn(_category));
    if (id != null) ref.read(_selection.notifier).add(id);
  }

  Future<void> _addSelected(Set<String> ids) async {
    if (_adding || ids.isEmpty) return;
    setState(() => _adding = true);
    await ref.read(tripDaoProvider).addItems(widget.tripId, ids);
    ref.read(_selection.notifier).clear();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final candidates = ref.watch(tripAddCandidatesProvider(widget.tripId));
    final selected = ref.watch(_selection);
    final all = candidates.value ?? const <Item>[];

    // 남은 아이템이 있는 카테고리만 칩으로(전부 담긴 카테고리는 숨김).
    final categories = [
      for (final c in ItemCategory.values)
        if (all.any((i) => i.category == c)) c,
    ];
    final category = categories.contains(_category) ? _category : null;
    final keyword = _query.trim();
    final visible = [
      for (final item in all)
        if ((category == null || item.category == category) &&
            (keyword.isEmpty || item.name.contains(keyword)))
          item,
    ];
    // 선택했지만 필터에 가려진 것도 추가 대상이다(이미 트립에 들어간 건 제외).
    final pending = selected.where((id) => all.any((i) => i.id == id)).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('아이템 추가', style: AppText.cardTitle),
              const SizedBox(width: 8),
              Text('이번 트립에 없는 아이템', style: AppText.caption),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPadding,
          ),
          child: SearchField(
            hint: '아이템 이름',
            onChanged: (q) => setState(() => _query = q),
          ),
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPadding,
          ),
          child: Row(
            children: [
              AppChip(
                label: '전체',
                selected: category == null,
                onTap: () => setState(() => _category = null),
              ),
              for (final c in categories) ...[
                const SizedBox(width: 8),
                AppChip(
                  label: c.label,
                  selected: category == c,
                  onTap: () => setState(() => _category = c),
                ),
              ],
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: visible.isEmpty
              ? Center(
                  child: Text(
                    all.isEmpty ? '창고의 아이템이 모두 담겨 있어요' : '검색 결과가 없어요',
                    style: AppText.caption,
                  ),
                )
              : ListView.separated(
                  itemCount: visible.length,
                  separatorBuilder: (context, _) => const Divider(
                    indent: AppSizes.screenPadding,
                    endIndent: AppSizes.screenPadding,
                  ),
                  itemBuilder: (context, i) {
                    final item = visible[i];
                    return _CandidateRow(
                      key: ValueKey(item.id),
                      item: item,
                      selected: selected.contains(item.id),
                      onToggle: () =>
                          ref.read(_selection.notifier).toggle(item.id),
                    );
                  },
                ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.line, width: AppSizes.hairline),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPadding,
                4,
                AppSizes.screenPadding,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton(
                    onPressed: _createCustom,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      minimumSize: const Size.fromHeight(
                        AppSizes.minTouchTarget,
                      ),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '찾는 아이템이 없나요? ',
                            style: AppText.caption,
                          ),
                          TextSpan(
                            text: '커스텀 아이템 만들기',
                            style: AppText.caption.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  PrimaryButton(
                    label: pending.isEmpty ? '추가' : '${pending.length}개 추가',
                    onPressed: pending.isEmpty || _adding
                        ? null
                        : () => _addSelected(pending),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    super.key,
    required this.item,
    required this.selected,
    required this.onToggle,
  });

  final Item item;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final meta = item.isBuiltIn
        ? item.category.label
        : '${item.category.label} · 커스텀';
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPadding,
          vertical: 8,
        ),
        child: Row(
          children: [
            SmallIconTile(
              glyph: item.glyph,
              tileSize: AppSizes.rowTile,
              iconSize: AppSizes.rowIcon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppText.body.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(meta, style: AppText.caption),
                ],
              ),
            ),
            Semantics(
              button: true,
              selected: selected,
              label: selected ? '${item.name} 선택 해제' : '${item.name} 선택',
              excludeSemantics: true,
              child: SizedBox.square(
                dimension: AppSizes.minTouchTarget,
                child: Center(
                  child: Container(
                    width: AppSizes.chipHeight,
                    height: AppSizes.chipHeight,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.ink : AppColors.bg,
                      border: Border.all(
                        color: selected ? AppColors.ink : AppColors.lineStrong,
                        width: AppSizes.border,
                      ),
                    ),
                    child: Icon(
                      selected ? Icons.check : Icons.add,
                      size: 16,
                      color: selected ? AppColors.bg : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
