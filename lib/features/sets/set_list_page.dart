import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../data/providers.dart';
import '../../domain/models/gear_set.dart';
import '../../widgets/buttons.dart';
import '../../widgets/small_icon_tile.dart';
import '../trips/start_trip.dart';
import 'set_list_state.dart';

/// S05 세트 목록 — 하단 탭 2.
class SetListPage extends ConsumerWidget {
  const SetListPage({super.key});

  /// 아이콘 미리보기 최대 개수(나머지는 "+n").
  static const _previewCount = 7;

  Future<void> _duplicate(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final newId = await ref.read(setDaoProvider).duplicateSet(id);
    if (context.mounted) await context.push(Routes.setEdit(newId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(setListUiStateProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPadding,
                16,
                AppSizes.screenPadding,
                12,
              ),
              child: Text('세트', style: AppText.screenTitle),
            ),
            Expanded(
              child: ui.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Center(child: Text('불러오지 못했어요\n$e')),
                data: (state) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding,
                    0,
                    AppSizes.screenPadding,
                    16,
                  ),
                  itemCount: state.sets.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final detail = state.sets[i];
                    final id = detail.set.id;
                    return _SetCard(
                      key: ValueKey(id),
                      detail: detail,
                      inUse: state.inUseSetId == id,
                      onEdit: () => context.push(Routes.setEdit(id)),
                      onDuplicate: () => _duplicate(context, ref, id),
                      onStartTrip: () => startNewTrip(context, ref, setId: id),
                    );
                  },
                ),
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.line,
                    width: AppSizes.hairline,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding,
                  12,
                  AppSizes.screenPadding,
                  12,
                ),
                child: PrimaryButton(
                  label: '+ 새 세트',
                  onPressed: () => context.push(Routes.setNew),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetCard extends StatelessWidget {
  const _SetCard({
    super.key,
    required this.detail,
    required this.inUse,
    required this.onEdit,
    required this.onDuplicate,
    required this.onStartTrip,
  });

  final GearSetDetail detail;
  final bool inUse;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onStartTrip;

  String get _usage {
    if (inUse) return '사용 중';
    final at = detail.set.lastUsedAt;
    return at == null ? '' : '${at.month}/${at.day} 사용';
  }

  @override
  Widget build(BuildContext context) {
    final set = detail.set;
    final entries = detail.entries;
    final preview = entries.take(SetListPage._previewCount).toList();
    final rest = entries.length - preview.length;
    final usage = _usage;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.lineStrong, width: AppSizes.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  set.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.cardTitle,
                ),
              ),
              if (set.isBuiltIn) ...[
                const SizedBox(width: 8),
                const AppTag('기본'),
              ],
              const Spacer(),
              Text.rich(
                withMonoDigits(
                  [
                    '${entries.length}개',
                    if (usage.isNotEmpty) usage,
                  ].join(' · '),
                  AppText.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text('아직 담긴 아이템이 없어요', style: AppText.caption)
          else
            Row(
              children: [
                for (final entry in preview) ...[
                  Flexible(
                    child: SmallIconTile(
                      glyph: entry.item.glyph,
                      tileSize: AppSizes.rowTile,
                      iconSize: AppSizes.rowIcon,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (rest > 0) Text('+$rest', style: AppText.monoSmall),
              ],
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              PillButton(label: '편집', onPressed: onEdit),
              const SizedBox(width: 8),
              PillButton(label: '복제', onPressed: onDuplicate),
              const Spacer(),
              PillButton(
                label: '이 세트로 트립',
                style: PillStyle.filled,
                onPressed: onStartTrip,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
