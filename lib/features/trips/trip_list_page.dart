import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';
import '../../domain/models/trip.dart';
import '../../widgets/buttons.dart';
import '../../widgets/dashed_border.dart';
import '../../widgets/item_glyph_view.dart';
import '../../widgets/progress_bar.dart';
import 'start_trip.dart';
import 'trip_format.dart';
import 'trip_list_state.dart';

/// S01 트립 목록(홈) — 하단 탭 1, 앱 시작 화면.
class TripListPage extends ConsumerWidget {
  const TripListPage({super.key});

  /// "아직 안 챙김" 미리보기 개수.
  static const _previewCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(tripListUiStateProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AppBar(),
            Expanded(
              child: ui.when(
                loading: () => const SizedBox.shrink(),
                error: (e, _) => Center(child: Text('불러오지 못했어요\n$e')),
                data: (state) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.screenPadding,
                    4,
                    AppSizes.screenPadding,
                    16,
                  ),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text('진행 중', style: AppText.sectionLabel),
                        ),
                        if (state.active?.trip case final trip?)
                          if (TripFormat.countdown(
                                trip.startDate,
                                trip.endDate,
                                DateTime.now(),
                              )
                              case final countdown?)
                            Text.rich(
                              withMonoDigits(
                                countdown,
                                AppText.tileLabel.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.inkMute,
                                ),
                              ),
                            ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (state.active case final active?) ...[
                      _ActiveCard(
                        detail: active,
                        setName: state.activeSetName,
                        onOpen: () => context.push(Routes.trip(active.trip.id)),
                      ),
                      if (state.unpacked.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _UnpackedPreview(
                          items: state.unpacked,
                          max: _previewCount,
                        ),
                      ],
                    ] else
                      const _NoActiveTrip(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text('완료', style: AppText.sectionLabel),
                        ),
                        Text('${state.done.length}', style: AppText.monoLabel),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (state.done.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('아직 완료한 트립이 없어요', style: AppText.caption),
                      )
                    else
                      for (final detail in state.done)
                        _DoneRow(
                          key: ValueKey(detail.trip.id),
                          detail: detail,
                          onOpen: () =>
                              context.push(Routes.trip(detail.trip.id)),
                          onSaveAsSet: () =>
                              context.push(Routes.setFromTrip(detail.trip.id)),
                        ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPadding,
                8,
                AppSizes.screenPadding,
                12,
              ),
              child: SecondaryButton(
                label: '새 트립',
                icon: Icons.add,
                onPressed: () => startNewTrip(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

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
          Text('챙고', style: AppText.wordmark),
          const SizedBox(width: 8),
          Text(
            'CHAENGO',
            style: AppText.wordmarkSub.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 11 * 0.12,
            ),
          ),
          const Spacer(),
          Text.rich(
            withMonoDigits(TripFormat.today(DateTime.now()), AppText.caption),
          ),
        ],
      ),
    );
  }
}

/// 진행 중 트립 검은 카드. 카드 전체 탭 → S03.
class _ActiveCard extends StatelessWidget {
  const _ActiveCard({
    required this.detail,
    required this.setName,
    required this.onOpen,
  });

  final TripDetail detail;
  final String? setName;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final trip = detail.trip;
    final progress = detail.progress;
    final subStyle = AppText.caption.copyWith(color: AppColors.cardDarkSub);
    final sub = [
      TripFormat.range(trip.startDate, trip.endDate),
      if (setName != null) '$setName 세트',
    ].join(' · ');

    return Semantics(
      button: true,
      label: '${trip.name} 체크 이어하기',
      child: GestureDetector(
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.name,
                          style: AppText.cardTitle.copyWith(
                            fontSize: 19,
                            letterSpacing: 19 * -0.01,
                            color: AppColors.cardDarkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(withMonoDigits(sub, subStyle)),
                      ],
                    ),
                  ),
                  Container(
                    width: AppSizes.pillHeight,
                    height: AppSizes.pillHeight,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardDarkLine,
                        width: AppSizes.border,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: AppColors.cardDarkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${progress.packed}',
                          style: AppText.bigNumber.copyWith(
                            color: AppColors.cardDarkText,
                          ),
                        ),
                        TextSpan(
                          text: '/${progress.total}',
                          style: AppText.bigNumberDenominator,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text.rich(
                    withMonoDigits(
                      progress.remaining == 0
                          ? '다 챙겼어요'
                          : '${progress.remaining}개 남음',
                      subStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProgressBar.onDark(value: progress.ratio),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카드 아래 "아직 안 챙김" 미니 타일 + "+n".
class _UnpackedPreview extends StatelessWidget {
  const _UnpackedPreview({required this.items, required this.max});

  final List<TripItem> items;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = items.take(max).toList();
    final rest = items.length - shown.length;
    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            '아직 안 챙김',
            style: AppText.tileLabel.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColors.inkSub,
            ),
          ),
        ),
        for (final item in shown) ...[
          const SizedBox(width: 8),
          _Mini(
            child: ItemGlyphView(
              item.item.glyph,
              size: AppSizes.previewIcon,
              color: AppColors.ink,
            ),
          ),
        ],
        if (rest > 0) ...[
          const SizedBox(width: 8),
          _Mini(
            dashed: true,
            child: Text(
              '+$rest',
              style: AppText.monoSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.child, this.dashed = false});

  final Widget child;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final box = SizedBox.square(
      dimension: AppSizes.previewTile,
      child: Center(child: child),
    );
    if (dashed) {
      return DashedRRectBorder(
        color: AppColors.lineStrong,
        strokeWidth: AppSizes.border,
        radius: AppSizes.smallTileRadius,
        child: box,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.smallTileRadius),
        border: Border.all(color: AppColors.lineStrong, width: AppSizes.border),
      ),
      child: box,
    );
  }
}

class _NoActiveTrip extends StatelessWidget {
  const _NoActiveTrip();

  @override
  Widget build(BuildContext context) {
    return DashedRRectBorder(
      color: AppColors.lineStrong,
      strokeWidth: AppSizes.border,
      radius: AppSizes.cardRadius,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('진행 중인 트립이 없어요', style: AppText.cardTitle),
            const SizedBox(height: 4),
            Text('아래 [새 트립]으로 세트를 골라 시작하세요.', style: AppText.caption),
          ],
        ),
      ),
    );
  }
}

/// 완료 트립 한 줄. 행 탭 → S03(읽기 전용), 우측 [세트로 저장]/"저장됨".
class _DoneRow extends StatelessWidget {
  const _DoneRow({
    super.key,
    required this.detail,
    required this.onOpen,
    required this.onSaveAsSet,
  });

  final TripDetail detail;
  final VoidCallback onOpen;
  final VoidCallback onSaveAsSet;

  @override
  Widget build(BuildContext context) {
    final trip = detail.trip;
    final progress = detail.progress;
    return InkWell(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.line, width: AppSizes.hairline),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.cardTitle,
                  ),
                  const SizedBox(height: 3),
                  Text.rich(
                    withMonoDigits(
                      '${TripFormat.range(trip.startDate, trip.endDate)}'
                      ' · ${progress.packed}/${progress.total}',
                      AppText.caption,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (trip.isSavedAsSet)
              const PillButton(
                label: '저장됨',
                style: PillStyle.muted,
                onPressed: null,
              )
            else
              PillButton(label: '세트로 저장', onPressed: onSaveAsSet),
          ],
        ),
      ),
    );
  }
}
