import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../app/theme/typography.dart';

/// 확인 다이얼로그. [destructive]면 확인 버튼이 danger 색.
/// 확인하면 true, 취소·바깥 탭이면 false.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      // 숫자는 예외 없이 Mono(tokens.md).
      title: Text.rich(withMonoDigits(title, AppText.cardTitle)),
      content: message == null
          ? null
          : Text.rich(withMonoDigits(message, AppText.body)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.inkSub,
            textStyle: AppText.button,
            minimumSize: const Size(
              AppSizes.minTouchTarget,
              AppSizes.minTouchTarget,
            ),
          ),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: destructive ? AppColors.danger : AppColors.ink,
            textStyle: AppText.button,
            minimumSize: const Size(
              AppSizes.minTouchTarget,
              AppSizes.minTouchTarget,
            ),
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
