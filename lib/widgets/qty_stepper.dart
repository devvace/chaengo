import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../app/theme/typography.dart';

/// 수량 스테퍼 1–99. 버튼은 44 터치 영역.
class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove,
          label: '줄이기',
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 56,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppText.countNumber,
          ),
        ),
        _StepButton(
          icon: Icons.add,
          label: '늘리기',
          onTap: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = onTap != null ? AppColors.ink : AppColors.lineStrong;
    return Semantics(
      button: true,
      label: label,
      enabled: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: AppSizes.minTouchTarget,
          height: AppSizes.minTouchTarget,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: AppSizes.border),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
