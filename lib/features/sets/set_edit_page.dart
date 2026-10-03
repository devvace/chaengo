import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../domain/models/item.dart';
import '../../widgets/buttons.dart';
import '../../widgets/category_header.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/item_tile.dart';
import '../../widgets/qty_sheet.dart';
import '../../widgets/tile_grid.dart';
import 'set_edit_state.dart';

/// S06 세트 편집. S03과 달리 [저장]을 눌러야 반영되며, 저장하지 않고
/// 나가면 폐기 확인을 띄운다. 저장하면 세트 id를 pop 결과로 돌려준다.
class SetEditPage extends ConsumerStatefulWidget {
  const SetEditPage({super.key, required this.args});

  final SetEditArgs args;

  @override
  ConsumerState<SetEditPage> createState() => _SetEditPageState();
}

class _SetEditPageState extends ConsumerState<SetEditPage> {
  final _nameController = TextEditingController();
  var _seeded = false;

  /// 저장·삭제·폐기 확인을 마친 뒤에는 PopScope를 통과시킨다.
  var _leaving = false;

  SetEditControllerProvider get _controller =>
      setEditControllerProvider(widget.args);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _leave([Object? result]) {
    setState(() => _leaving = true);
    // PopScope가 갱신된 canPop을 반영한 다음 프레임에 닫는다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop(result);
    });
  }

  Future<void> _confirmDiscard() async {
    final ok = await showConfirmDialog(
      context,
      title: '변경 사항을 버릴까요?',
      message: '저장하지 않은 내용은 사라집니다.',
      confirmLabel: '버리기',
      destructive: true,
    );
    if (ok && mounted) _leave();
  }

  Future<void> _save() async {
    final id = await ref.read(_controller.notifier).save();
    if (id != null && mounted) _leave(id);
  }

  Future<void> _delete(SetEditUiState state) async {
    final ok = await showConfirmDialog(
      context,
      title: '‘${state.name}’ 세트 삭제',
      message: '이미 만든 트립에는 영향이 없어요.',
      confirmLabel: '삭제',
      destructive: true,
    );
    if (!ok) return;
    await ref.read(_controller.notifier).delete();
    if (mounted) _leave();
  }

  Future<void> _addCustomItem() async {
    final id = await context.push<String>(Routes.itemNew);
    if (id != null) {
      await ref.read(_controller.notifier).includeNewItem(id);
    }
  }

  Future<void> _editQty(SetEditUiState state, Item item) async {
    final qty = await showQtySheet(
      context,
      itemName: item.name,
      initial: state.qtyOf(item.id),
    );
    if (qty != null) ref.read(_controller.notifier).setQty(item.id, qty);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(setEditUiStateProvider(widget.args));
    final state = async.value;
    if (state != null && !_seeded) {
      _seeded = true;
      _nameController.text = state.name;
    }
    final dirty = state?.draft.isDirty ?? false;

    return PopScope(
      canPop: _leaving || !dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: '닫기',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          centerTitle: true,
          title: const Text('세트 편집'),
          actions: [
            PillButton(
              label: '저장',
              style: state?.canSave ?? false
                  ? PillStyle.filled
                  : PillStyle.muted,
              onPressed: state?.canSave ?? false ? _save : null,
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: switch (async) {
          AsyncValue(:final error?) => Center(child: Text('불러오지 못했어요\n$error')),
          AsyncValue(value: final s?)
              when s.original == null && widget.args.setId != null =>
            Center(child: Text('없는 세트예요', style: AppText.caption)),
          AsyncValue(value: final s?) => _buildBody(s),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildBody(SetEditUiState state) {
    final notifier = ref.read(_controller.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            4,
            AppSizes.screenPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('세트 이름', style: AppText.sectionLabel),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                onChanged: notifier.setName,
                textInputAction: TextInputAction.done,
                style: AppText.cardTitle.copyWith(fontSize: 18),
                decoration: const InputDecoration(hintText: '예: 여름 트렁크'),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${state.includedCount}', style: AppText.countNumber),
                  Text(
                    '개 담김',
                    style: AppText.categoryHeader.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.inkSub,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '탭 = 담기·빼기 · 길게 = 수량',
                    style: AppText.tileLabel.copyWith(color: AppColors.inkMute),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              6,
              AppSizes.screenPadding,
              24,
            ),
            children: [
              for (final group in state.groups) ...[
                const SizedBox(height: 12),
                CategoryHeader(
                  title: group.category.label,
                  count: state.includedIn(group.items),
                  total: group.items.length,
                ),
                const SizedBox(height: 12),
                TileGrid(
                  children: [
                    for (final item in group.items)
                      ItemTile.edit(
                        key: ValueKey(item.id),
                        label: item.name,
                        glyph: item.glyph,
                        included: state.isIncluded(item.id),
                        qty: state.qtyOf(item.id),
                        onTap: () => notifier.toggle(item),
                        onLongPress: () => _editQty(state, item),
                      ),
                  ],
                ),
              ],
            ],
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
                8,
                AppSizes.screenPadding,
                8,
              ),
              child: Row(
                children: [
                  DangerTextButton(
                    label: '세트 삭제',
                    onPressed: state.canDelete ? () => _delete(state) : null,
                  ),
                  const Spacer(),
                  PillButton(
                    label: '창고에 없는 아이템',
                    icon: Icons.add,
                    onPressed: _addCustomItem,
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
