import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../app/theme/typography.dart';

/// 주요 버튼: 높이 56, ink 배경 + 백색 16/600. [trailing]은 S03 "n개 남음" 같은
/// 보조 숫자(Mono)를 받는다.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailing,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return _ButtonFrame(
      onPressed: onPressed,
      decoration: BoxDecoration(
        color: enabled ? AppColors.ink : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppText.button.copyWith(
              color: enabled ? AppColors.bg : AppColors.inkMute,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            // 숫자만 Mono, 한글은 본문 글꼴("22개 남음").
            Text.rich(
              withMonoDigits(
                trailing!,
                AppText.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.cardDarkSub,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 보조 버튼: 높이 56, 백색 + 1.5px ink 테두리.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = onPressed != null ? AppColors.ink : AppColors.inkMute;
    return _ButtonFrame(
      onPressed: onPressed,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        border: Border.all(color: color, width: AppSizes.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
          ],
          Text(label, style: AppText.button.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ButtonFrame extends StatelessWidget {
  const _ButtonFrame({
    required this.onPressed,
    required this.decoration,
    required this.child,
  });

  final VoidCallback? onPressed;
  final BoxDecoration decoration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          height: AppSizes.buttonHeight,
          width: double.infinity,
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }
}

enum PillStyle {
  /// 1.5px lineStrong 테두리(S01 [세트로 저장]).
  outlined,

  /// ink 배경 백색 글자(S06 [저장]).
  filled,

  /// surface 배경 inkMute 글자, 비활성 표시(S01 "저장됨").
  muted,
}

/// 작은 pill 버튼: 높이 36, radius 18. 터치 영역은 44.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = PillStyle.outlined,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillStyle style;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (style) {
      PillStyle.outlined => (AppColors.bg, AppColors.ink, AppColors.lineStrong),
      PillStyle.filled => (AppColors.ink, AppColors.bg, null),
      PillStyle.muted => (AppColors.surface, AppColors.inkMute, null),
    };
    final textStyle = AppText.chipSelected.copyWith(
      color: fg,
      fontWeight: style == PillStyle.muted ? FontWeight.w500 : FontWeight.w600,
    );
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.minTouchTarget,
            minWidth: AppSizes.minTouchTarget,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Container(
              height: AppSizes.pillHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.chipPaddingX,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppSizes.pillRadius),
                border: border == null
                    ? null
                    : Border.all(color: border, width: AppSizes.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Text(label, style: textStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 삭제·초기화 전용 텍스트 버튼. danger 색은 여기서만 쓴다.
class DangerTextButton extends StatelessWidget {
  const DangerTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: AppText.categoryHeader.copyWith(
                color: onPressed != null ? AppColors.danger : AppColors.inkMute,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [기본]/[커스텀] 태그. 원본의 #E9E9E6은 토큰에 없어 surface로 대체.
class AppTag extends StatelessWidget {
  const AppTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppText.tabLabel.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.inkSub,
          letterSpacing: 11 * 0.02,
        ),
      ),
    );
  }
}
