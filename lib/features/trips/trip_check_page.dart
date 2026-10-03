import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../data/providers.dart';
import '../../domain/models/trip.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/buttons.dart';
import '../../widgets/category_header.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/item_tile.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/qty_sheet.dart';
import '../../widgets/tile_grid.dart';
import 'item_add_sheet.dart';
import 'trip_check_state.dart';

/// S03 트립 체크 — 핵심 화면. 타일 탭 = 즉시 토글 + 즉시 저장(저장 버튼 없음).
/// 이 화면에서만 화면 꺼짐을 막는다(설정에서 끌 수 있음).
class TripCheckPage extends ConsumerStatefulWidget {
  const TripCheckPage({
    super.key,
    required this.tripId,
    this.openAddSheet = false,
  });

  final String tripId;

  /// S02 [세트 없이 시작]에서 왔으면 들어오자마자 S04를 연다.
  final bool openAddSheet;

  @override
  ConsumerState<TripCheckPage> createState() => _TripCheckPageState();
}

class _TripCheckPageState extends ConsumerState<TripCheckPage> {
  var _wakelockOn = false;

  @override
  void initState() {
    super.initState();
    if (widget.openAddSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showItemAddSheet(context, widget.tripId);
      });
    }
  }

  @override
  void dispose() {
    _setWakelock(false);
    super.dispose();
  }

  /// 플러그인이 없는 환경(테스트)에서도 화면 동작은 계속되어야 한다.
  void _setWakelock(bool on) {
    if (_wakelockOn == on) return;
    _wakelockOn = on;
    WakelockPlus.toggle(enable: on).catchError((Object _) {});
  }

  /// 기기에 따라 진동이 없을 수 있으니 실패는 무시한다.
  void _haptic(TripCheckUiState state) {
    if (!state.settings.haptics) return;
    HapticFeedback.lightImpact().catchError((Object _) {});
  }

  Future<void> _toggle(TripCheckUiState state, TripItem item) async {
    if (state.readOnly || item.isExcluded) return;
    _haptic(state);
    await ref
        .read(tripDaoProvider)
        .setItemState(widget.tripId, item.item.id, item.toggled);
  }

  Future<void> _itemActions(TripCheckUiState state, TripItem item) async {
    if (state.readOnly) return;
    final action = await showModalBottomSheet<_ItemAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ItemActionSheet(item: item),
    );
    if (action == null || !mounted) return;
    final dao = ref.read(tripDaoProvider);
    final itemId = item.item.id;
    switch (action) {
      case _ItemAction.exclude:
        await dao.setItemState(widget.tripId, itemId, PackState.excluded);
      case _ItemAction.restore:
        await dao.setItemState(widget.tripId, itemId, PackState.unpacked);
      case _ItemAction.qty:
        final qty = await showQtySheet(
          context,
          itemName: item.item.name,
          initial: item.qty,
        );
        if (qty != null) await dao.setItemQty(widget.tripId, itemId, qty);
      case _ItemAction.remove:
        await dao.removeItem(widget.tripId, itemId);
    }
  }

  Future<void> _complete(TripCheckUiState state) async {
    final remaining = state.progress.remaining;
    if (remaining > 0) {
      final ok = await showConfirmDialog(
        context,
        title: '아직 안 챙긴 아이템이 $remaining개 있어요',
        message: '그래도 캠핑을 완료할까요? 완료하면 읽기 전용이 돼요.',
        confirmLabel: '완료',
      );
      if (!ok) return;
    }
    await ref.read(tripDaoProvider).completeTrip(widget.tripId);
    if (mounted) context.go(Routes.trips);
  }

  Future<void> _menu(TripCheckUiState state, _MenuAction action) async {
    final dao = ref.read(tripDaoProvider);
    switch (action) {
      case _MenuAction.reopen:
        try {
          await dao.reopenTrip(widget.tripId);
        } on StateError {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('진행 중인 트립이 있어 되돌릴 수 없어요')),
            );
          }
        }
      case _MenuAction.rename:
        final name = await showDialog<String>(
          context: context,
          builder: (context) => _RenameDialog(initial: state.detail.trip.name),
        );
        if (name != null && name.trim().isNotEmpty) {
          await dao.renameTrip(widget.tripId, name);
        }
      case _MenuAction.delete:
        final ok = await showConfirmDialog(
          context,
          title: '‘${state.detail.trip.name}’ 트립 삭제',
          message: '체크 기록이 모두 사라져요. 창고의 아이템과 세트는 그대로예요.',
          confirmLabel: '삭제',
          destructive: true,
        );
        if (!ok) return;
        await dao.deleteTrip(widget.tripId);
        if (mounted) context.go(Routes.trips);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(tripCheckUiStateProvider(widget.tripId));
    final state = async.value;
    // 진행 중 트립을 보고 있고 설정이 켜져 있을 때만 화면 꺼짐 방지.
    if (state != null) {
      _setWakelock(state.settings.keepScreenOn && !state.readOnly);
    }

    return Scaffold(
      body: SafeArea(
        child: switch (async) {
          AsyncValue(:final error?) => Center(child: Text('불러오지 못했어요\n$error')),
          AsyncValue(hasValue: true, value: null) => Center(
            child: Text('없는 트립이에요', style: AppText.caption),
          ),
          AsyncValue(value: final s?) => _buildBody(s),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildBody(TripCheckUiState state) {
    final view = ref.read(
      tripCheckViewControllerProvider(widget.tripId).notifier,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(state: state, onMenu: (a) => _menu(state, a)),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPadding,
            4,
            AppSizes.screenPadding,
            0,
          ),
          child: Row(
            children: [
              AppChip(
                label: '안 챙긴 것 먼저',
                leading: const Icon(Icons.check),
                selected: state.view.sort == TripSort.unpackedFirst,
                onTap: () => view.setSort(TripSort.unpackedFirst),
              ),
              const SizedBox(width: 8),
              AppChip(
                label: '카테고리순',
                leading: const Icon(Icons.check),
                selected: state.view.sort == TripSort.category,
                onTap: () => view.setSort(TripSort.category),
              ),
              const Spacer(),
              if (!state.readOnly)
                RoundIconButton(
                  icon: Icons.add,
                  semanticLabel: '아이템 추가',
                  onTap: () => showItemAddSheet(context, widget.tripId),
                ),
            ],
          ),
        ),
        Expanded(
          child: state.groups.isEmpty
              ? Center(
                  child: Text(
                    state.readOnly ? '아이템이 없어요' : '[+]로 아이템을 추가하세요',
                    style: AppText.caption,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding,
                    4,
                    AppSizes.screenPadding,
                    24,
                  ),
                  children: [
                    for (final group in state.groups) ...[
                      CategoryHeader(
                        title: group.category.label,
                        count: group.packed,
                        total: group.total,
                        onTap: () => view.toggleCollapsed(group.category),
                      ),
                      if (!group.collapsed) ...[
                        const SizedBox(height: 4),
                        TileGrid(
                          children: [
                            for (final item in group.items)
                              ItemTile.check(
                                key: ValueKey(item.item.id),
                                label: item.item.name,
                                glyph: item.item.glyph,
                                qty: item.qty,
                                state: switch (item.state) {
                                  PackState.unpacked => CheckTileState.unpacked,
                                  PackState.packed => CheckTileState.packed,
                                  PackState.excluded => CheckTileState.excluded,
                                },
                                onTap: state.readOnly
                                    ? null
                                    : () => _toggle(state, item),
                                onLongPress: state.readOnly
                                    ? null
                                    : () => _itemActions(state, item),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              12,
              AppSizes.screenPadding,
              12,
            ),
            child: state.readOnly
                ? const PrimaryButton(label: '완료한 트립이에요', onPressed: null)
                : PrimaryButton(
                    label: '캠핑 완료',
                    trailing: state.progress.remaining > 0
                        ? '${state.progress.remaining}개 남음'
                        : null,
                    onPressed: () => _complete(state),
                  ),
          ),
        ),
      ],
    );
  }
}

/// 앱바 + 진행. 스크롤해도 고정.
class _Header extends StatelessWidget {
  const _Header({required this.state, required this.onMenu});

  final TripCheckUiState state;
  final ValueChanged<_MenuAction> onMenu;

  @override
  Widget build(BuildContext context) {
    final progress = state.progress;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPadding - 10,
        4,
        AppSizes.screenPadding - 10,
        12,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.line, width: AppSizes.hairline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: '뒤로',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Text(
                  state.detail.trip.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.appBarTitle,
                ),
              ),
              PopupMenuButton<_MenuAction>(
                tooltip: '더보기',
                icon: const Icon(Icons.more_horiz),
                color: AppColors.bg,
                surfaceTintColor: Colors.transparent,
                onSelected: onMenu,
                itemBuilder: (context) => [
                  if (state.readOnly)
                    const PopupMenuItem(
                      value: _MenuAction.reopen,
                      child: Text('완료 취소'),
                    ),
                  const PopupMenuItem(
                    value: _MenuAction.rename,
                    child: Text('이름 변경'),
                  ),
                  PopupMenuItem(
                    value: _MenuAction.delete,
                    child: Text(
                      '삭제',
                      style: AppText.body.copyWith(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${progress.packed}',
                            style: AppText.progressNumber,
                          ),
                          TextSpan(
                            text: '/${progress.total}',
                            style: AppText.progressDenominator,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        withMonoDigits(state.summary, AppText.caption),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProgressBar(value: progress.ratio),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _MenuAction { reopen, rename, delete }

enum _ItemAction { exclude, restore, qty, remove }

/// 롱프레스 액션 시트: 제외(또는 제외 해제) / 수량 / 트립에서 삭제.
class _ItemActionSheet extends StatelessWidget {
  const _ItemActionSheet({required this.item});

  final TripItem item;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, _ItemAction action, {bool danger = false}) {
      return InkWell(
        onTap: () => Navigator.of(context).pop(action),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.buttonHeight),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPadding,
          ),
          child: Text(
            label,
            style: AppText.body.copyWith(
              color: danger ? AppColors.danger : AppColors.ink,
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              0,
              AppSizes.screenPadding,
              8,
            ),
            child: Text(item.item.name, style: AppText.cardTitle),
          ),
          if (item.isExcluded)
            row('제외 해제', _ItemAction.restore)
          else
            row('이번엔 제외', _ItemAction.exclude),
          row('수량 변경', _ItemAction.qty),
          row('트립에서 삭제', _ItemAction.remove, danger: true),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('트립 이름 변경'),
      content: TextField(controller: _controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: AppColors.inkSub),
          child: const Text('취소'),
        ),
        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => TextButton(
            onPressed: _controller.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(_controller.text),
            style: TextButton.styleFrom(foregroundColor: AppColors.ink),
            child: const Text('변경'),
          ),
        ),
      ],
    );
  }
}
