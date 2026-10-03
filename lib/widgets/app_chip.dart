import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../app/theme/typography.dart';

/// 정렬·카테고리 칩. 높이 34지만 터치 영역은 44를 확보한다.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// 선택됐을 때만 보이는 작은 아이콘(14).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.bg : AppColors.ink;
    return _TouchTarget(
      onTap: onTap,
      selected: selected,
      child: Container(
        height: AppSizes.chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.chipPaddingX),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.bg,
          borderRadius: BorderRadius.circular(AppSizes.chipRadius),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.lineStrong,
            width: AppSizes.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected && leading != null) ...[
              IconTheme(
                data: IconThemeData(color: fg, size: 14),
                child: leading!,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: (selected ? AppText.chipSelected : AppText.chip).copyWith(
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// S03 정렬 줄 우측의 원형 [+](34 원, 터치 44).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: _TouchTarget(
        onTap: onTap,
        child: Container(
          width: AppSizes.chipHeight,
          height: AppSizes.chipHeight,
          decoration: BoxDecoration(
            color: AppColors.bg,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.lineStrong,
              width: AppSizes.border,
            ),
          ),
          child: Icon(icon, size: 16, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// 보이는 크기는 그대로 두고 탭 영역만 최소 44로 넓힌다.
class _TouchTarget extends StatelessWidget {
  const _TouchTarget({required this.onTap, required this.child, this.selected});

  final VoidCallback? onTap;
  final Widget child;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppSizes.minTouchTarget,
            minHeight: AppSizes.minTouchTarget,
          ),
          child: Center(widthFactor: 1, heightFactor: 1, child: child),
        ),
      ),
    );
  }
}
