import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../data/providers.dart';
import '../../domain/models/item_category.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/qty_stepper.dart';
import '../../widgets/small_icon_tile.dart';
import 'item_actions.dart';
import 'item_edit_state.dart';

/// S08 아이템 추가 / 수정. 저장하면 아이템 id를 pop 결과로 돌려준다
/// (S04·S06에서 왔으면 그 화면이 자동 선택/담김에 쓴다).
class ItemEditPage extends ConsumerStatefulWidget {
  const ItemEditPage({super.key, required this.itemId, this.initialCategory});

  final String? itemId;
  final ItemCategory? initialCategory;

  @override
  ConsumerState<ItemEditPage> createState() => _ItemEditPageState();
}

class _ItemEditPageState extends ConsumerState<ItemEditPage> {
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();
  var _seeded = false;

  ItemEditControllerProvider get _provider => itemEditControllerProvider(
    widget.itemId,
    initialCategory: widget.initialCategory,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final id = await ref.read(_provider.notifier).save();
    if (id != null && mounted) context.pop(id);
  }

  Future<void> _delete(ItemEditUiState state) async {
    final item = state.original!;
    final dao = ref.read(itemDaoProvider);
    final setCounts = await dao.watchSetCounts().first;
    if (!mounted) return;
    final deleted = await confirmAndDeleteCustomItem(
      context,
      dao: dao,
      item: item,
      setCount: setCounts[item.id] ?? 0,
    );
    if (deleted && mounted) context.pop();
  }

  Future<void> _pickCategory(ItemEditUiState state) async {
    final picked = await showModalBottomSheet<ItemCategory>(
      context: context,
      showDragHandle: true,
      builder: (context) => _CategorySheet(selected: state.category),
    );
    if (picked != null) ref.read(_provider.notifier).setCategory(picked);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_provider);
    final state = async.value;
    if (state != null && !_seeded) {
      _seeded = true;
      _nameController.text = state.name;
      _emojiController.text = state.emoji ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '닫기',
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.itemId == null ? '아이템 추가' : '아이템 수정'),
      ),
      body: switch (async) {
        AsyncValue(:final error?) => Center(child: Text('불러오지 못했어요\n$error')),
        AsyncValue(value: final s?)
            when s.original == null && widget.itemId != null =>
          Center(child: Text('없는 아이템이에요', style: AppText.caption)),
        AsyncValue(value: final s?) => _buildForm(s),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildForm(ItemEditUiState state) {
    final notifier = ref.read(_provider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              8,
              AppSizes.screenPadding,
              24,
            ),
            children: [
              _Label('이름'),
              TextField(
                controller: _nameController,
                readOnly: !state.canEditIdentity,
                onChanged: notifier.setName,
                maxLength: kItemNameMaxLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                textInputAction: TextInputAction.done,
                style: AppText.body.copyWith(
                  color: state.canEditIdentity
                      ? AppColors.ink
                      : AppColors.inkMute,
                ),
                decoration: InputDecoration(
                  hintText: '예: 사이드월',
                  counterText: '',
                  // 읽기 전용이면 카테고리 칸과 같은 회색 테두리.
                  enabledBorder: state.canEditIdentity
                      ? null
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.inputRadius,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.lineStrong,
                            width: AppSizes.border,
                          ),
                        ),
                ),
              ),
              if (state.isBuiltIn) _Hint('기본 아이템은 이름·카테고리를 바꿀 수 없어요'),
              if (state.duplicate case final dup?)
                _DuplicateNotice(
                  onOpen: () =>
                      context.pushReplacement(Routes.itemEdit(dup.id)),
                ),
              const SizedBox(height: 20),
              _Label('카테고리'),
              _CategoryField(
                category: state.category,
                enabled: state.canEditIdentity,
                onTap: () => _pickCategory(state),
              ),
              const SizedBox(height: 20),
              _Label('아이콘'),
              Row(
                children: [
                  AppChip(
                    label: '기본 아이콘',
                    selected: state.iconTab == IconTab.builtIn,
                    onTap: () => notifier.setIconTab(IconTab.builtIn),
                  ),
                  const SizedBox(width: 8),
                  AppChip(
                    label: '이모지',
                    selected: state.iconTab == IconTab.emoji,
                    onTap: () => notifier.setIconTab(IconTab.emoji),
                  ),
                  const Spacer(),
                  SmallIconTile(
                    glyph: state.glyph,
                    tileSize: AppSizes.previewTile,
                    iconSize: AppSizes.previewIcon,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.iconTab == IconTab.builtIn) ...[
                _Hint('선택한 카테고리의 아이콘이 먼저 보여요. 고르지 않으면 카테고리 아이콘을 써요.'),
                const SizedBox(height: 12),
                _IconGrid(
                  icons: state.orderedIcons,
                  selected: state.iconKey,
                  onTap: notifier.toggleIcon,
                ),
              ] else
                _EmojiField(
                  controller: _emojiController,
                  onChanged: notifier.setEmoji,
                ),
              const SizedBox(height: 20),
              _Label('기본 수량'),
              Row(
                children: [
                  Expanded(
                    child: Text('세트에 담을 때 처음 수량', style: AppText.caption),
                  ),
                  QtyStepper(value: state.qty, onChanged: notifier.setQty),
                ],
              ),
              if (state.canDelete) ...[
                const SizedBox(height: 32),
                Center(
                  child: DangerTextButton(
                    label: '아이템 삭제',
                    onPressed: () => _delete(state),
                  ),
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
                12,
                AppSizes.screenPadding,
                12,
              ),
              child: PrimaryButton(
                label: '저장',
                onPressed: state.canSave ? _save : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppText.sectionLabel),
  );
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(text, style: AppText.caption),
  );
}

class _DuplicateNotice extends StatelessWidget {
  const _DuplicateNotice({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(child: Text('이미 있는 기본 아이템이에요', style: AppText.caption)),
          PillButton(label: '열기', onPressed: onOpen),
        ],
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.category,
    required this.enabled,
    required this.onTap,
  });

  final ItemCategory category;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.ink : AppColors.inkMute;
    return Semantics(
      button: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          height: AppSizes.inputHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.inputRadius),
            border: Border.all(
              color: enabled ? AppColors.ink : AppColors.lineStrong,
              width: AppSizes.border,
            ),
          ),
          child: Row(
            children: [
              AppIcon(category.iconKey, size: AppSizes.rowIcon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category.label,
                  style: AppText.body.copyWith(color: color),
                ),
              ),
              if (enabled) Icon(Icons.expand_more, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({required this.selected});

  final ItemCategory selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
              child: Text('카테고리', style: AppText.cardTitle),
            ),
            for (final category in ItemCategory.values)
              InkWell(
                onTap: () => Navigator.of(context).pop(category),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: AppSizes.buttonHeight,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenPadding,
                  ),
                  child: Row(
                    children: [
                      AppIcon(
                        category.iconKey,
                        size: AppSizes.rowIcon,
                        color: AppColors.ink,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category.label,
                          style: category == selected
                              ? AppText.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                )
                              : AppText.body,
                        ),
                      ),
                      if (category == selected)
                        const Icon(Icons.check, color: AppColors.ink),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// 기본 아이콘 그리드: 5열 60px. 선택 = 2px ink 테두리 + surface.
class _IconGrid extends StatelessWidget {
  const _IconGrid({
    required this.icons,
    required this.selected,
    required this.onTap,
  });

  final List<String> icons;
  final String? selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = AppSizes.pickerColumns;
        final gap =
            ((constraints.maxWidth - AppSizes.pickerTile * columns) /
                    (columns - 1))
                .clamp(0.0, double.infinity);
        return Wrap(
          spacing: gap,
          runSpacing: AppSizes.tileGapY,
          children: [
            for (final key in icons)
              _IconOption(
                assetKey: key,
                selected: key == selected,
                onTap: () => onTap(key),
              ),
          ],
        );
      },
    );
  }
}

class _IconOption extends StatelessWidget {
  const _IconOption({
    required this.assetKey,
    required this.selected,
    required this.onTap,
  });

  final String assetKey;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: AppSizes.pickerTile,
          height: AppSizes.pickerTile,
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : AppColors.bg,
            borderRadius: BorderRadius.circular(AppSizes.smallTileRadius),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.lineStrong,
              width: selected ? AppSizes.borderStrong : AppSizes.border,
            ),
          ),
          alignment: Alignment.center,
          child: AppIcon(
            assetKey,
            size: AppSizes.pickerIcon,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

/// OS 키보드의 이모지 피커로 한 글자를 받는다. 여러 개를 치면 마지막 하나만 남긴다.
class _EmojiField extends StatelessWidget {
  const _EmojiField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  void _handle(String raw) {
    final chars = raw.characters.where((c) => c.trim().isNotEmpty);
    final last = chars.isEmpty ? '' : chars.last;
    if (controller.text != last) {
      controller.value = TextEditingValue(
        text: last,
        selection: TextSelection.collapsed(offset: last.length),
      );
    }
    onChanged(last);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: _handle,
          textAlign: TextAlign.center,
          style: AppText.screenTitle,
          decoration: const InputDecoration(hintText: '이모지 1개'),
        ),
        const SizedBox(height: 6),
        Text('키보드의 이모지 버튼으로 골라 주세요', style: AppText.caption),
      ],
    );
  }
}
