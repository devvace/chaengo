import 'package:flutter/widgets.dart';

import '../app/theme/tokens.dart';
import '../domain/models/item.dart';
import 'item_glyph_view.dart';

/// 리스트 행·미리보기용 작은 아이콘 타일(테두리 lineStrong, radius 12).
class SmallIconTile extends StatelessWidget {
  const SmallIconTile({
    super.key,
    required this.glyph,
    required this.tileSize,
    required this.iconSize,
    this.muted = false,
  });

  final ItemGlyph glyph;
  final double tileSize;
  final double iconSize;

  /// 숨김 아이템 등 회색으로 보일 때.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppSizes.smallTileRadius),
        border: Border.all(color: AppColors.lineStrong, width: AppSizes.border),
      ),
      alignment: Alignment.center,
      child: ItemGlyphView(
        glyph,
        size: iconSize,
        color: muted ? AppColors.inkMute : AppColors.ink,
      ),
    );
  }
}
