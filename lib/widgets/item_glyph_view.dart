import 'package:flutter/widgets.dart';

import '../domain/models/item.dart';
import 'app_icon.dart';

/// 아이템 아이콘 한 개. SVG는 [color]로 tint하고, 이모지는 원래 색으로 그린다
/// (이모지는 tint가 불가능하므로 상태 표현은 타일 테두리·배경이 맡는다).
class ItemGlyphView extends StatelessWidget {
  const ItemGlyphView(
    this.glyph, {
    super.key,
    required this.size,
    required this.color,
  });

  final ItemGlyph glyph;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return switch (glyph) {
      SvgGlyph(:final assetKey) => AppIcon(assetKey, size: size, color: color),
      EmojiGlyph(:final emoji) => SizedBox.square(
        dimension: size,
        child: FittedBox(
          child: Text(
            emoji,
            textScaler: TextScaler.noScaling,
            style: const TextStyle(height: 1),
          ),
        ),
      ),
    };
  }
}
