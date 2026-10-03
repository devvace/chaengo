import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../app/theme/typography.dart';

/// 카테고리 이름 + Mono "n/m". S03은 탭으로 접기, S06은 탭 없음.
class CategoryHeader extends StatelessWidget {
  const CategoryHeader({
    super.key,
    required this.title,
    required this.count,
    required this.total,
    this.onTap,
  });

  final String title;
  final int count;
  final int total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: Text(title, style: AppText.categoryHeader)),
        Text('$count/$total', style: AppText.monoSmall.copyWith(fontSize: 12)),
      ],
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          child: Align(alignment: Alignment.centerLeft, child: row),
        ),
      ),
    );
  }
}
