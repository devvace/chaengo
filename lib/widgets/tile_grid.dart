import 'package:flutter/widgets.dart';

import '../app/theme/tokens.dart';

/// 타일 4열 그리드. 가로 gap 8, 세로 gap 12. 각 칸 가운데에 타일을 둔다.
/// 스크롤은 바깥(ListView/CustomScrollView)이 맡으므로 자체 스크롤이 없다.
class TileGrid extends StatelessWidget {
  const TileGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = AppSizes.tileGridColumns;
        final cellWidth =
            (constraints.maxWidth - AppSizes.tileGapX * (columns - 1)) /
            columns;
        return Wrap(
          spacing: AppSizes.tileGapX,
          runSpacing: AppSizes.tileGapY,
          children: [
            for (final child in children)
              SizedBox(
                width: cellWidth,
                child: Align(alignment: Alignment.topCenter, child: child),
              ),
          ],
        );
      },
    );
  }
}
