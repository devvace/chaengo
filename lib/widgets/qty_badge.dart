import 'package:flutter/widgets.dart';

import '../app/theme/tokens.dart';
import '../app/theme/typography.dart';

/// 수량 2+ 뱃지. 높이 22, 두 자리면 가로로 늘어나는 pill.
/// - [QtyBadge.outlined]: S03. 백색 원 + 1.5px ink 테두리.
/// - [QtyBadge.filled]: S06. ink 원 + 백색 숫자.
class QtyBadge extends StatelessWidget {
  const QtyBadge.outlined(this.qty, {super.key}) : _filled = false;
  const QtyBadge.filled(this.qty, {super.key}) : _filled = true;

  final int qty;
  final bool _filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: AppSizes.badge,
        minHeight: AppSizes.badge,
        maxHeight: AppSizes.badge,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: _filled ? AppColors.ink : AppColors.bg,
        borderRadius: BorderRadius.circular(AppSizes.badge / 2),
        border: _filled
            ? null
            : Border.all(color: AppColors.ink, width: AppSizes.border),
      ),
      alignment: Alignment.center,
      child: Text(
        '$qty',
        style: AppText.qtyBadge.copyWith(
          color: _filled ? AppColors.bg : AppColors.ink,
        ),
      ),
    );
  }
}
