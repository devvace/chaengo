import 'package:flutter/foundation.dart';

import 'item_category.dart';

/// 창고에 있는 장비 한 종류. 세트·트립은 이 아이템을 참조한다.
@immutable
class Item {
  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.iconKey,
    required this.defaultQty,
    required this.isBuiltIn,
    required this.isHidden,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final ItemCategory category;

  /// 직접 지정한 아이콘. null이면 카테고리 아이콘으로 폴백한다.
  /// 기본 아이콘은 에셋 이름('ic_tent'), 이모지는 [emojiPrefix]를 붙여
  /// 저장한다('emoji:🏕️'). 만들 때는 [emojiIconKey]를 쓴다.
  final String? iconKey;
  final int defaultQty;

  /// 앱 내장 아이템. 삭제할 수 없고 이름·카테고리를 바꿀 수 없다.
  final bool isBuiltIn;

  /// 내장 아이템의 '삭제' 대체 수단. 목록·세트 편집에서 빠진다.
  final bool isHidden;

  /// 같은 카테고리 안에서의 표시 순서. 시드는 파일 순서, 커스텀은 뒤에 붙는다.
  final int sortOrder;

  static const emojiPrefix = 'emoji:';

  /// 이모지를 [iconKey]로 저장할 형태로 바꾼다.
  static String emojiIconKey(String emoji) => '$emojiPrefix$emoji';

  /// 화면에 그릴 아이콘. 지정이 없으면 카테고리 아이콘.
  ItemGlyph get glyph {
    final key = iconKey;
    if (key == null || key.isEmpty) return SvgGlyph(category.iconKey);
    if (key.startsWith(emojiPrefix)) {
      final emoji = key.substring(emojiPrefix.length);
      return emoji.isEmpty ? SvgGlyph(category.iconKey) : EmojiGlyph(emoji);
    }
    return SvgGlyph(key);
  }

  Item copyWith({
    String? name,
    ItemCategory? category,
    String? Function()? iconKey,
    int? defaultQty,
    bool? isHidden,
    int? sortOrder,
  }) {
    return Item(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      iconKey: iconKey == null ? this.iconKey : iconKey(),
      defaultQty: defaultQty ?? this.defaultQty,
      isBuiltIn: isBuiltIn,
      isHidden: isHidden ?? this.isHidden,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          other.id == id &&
          other.name == name &&
          other.category == category &&
          other.iconKey == iconKey &&
          other.defaultQty == defaultQty &&
          other.isBuiltIn == isBuiltIn &&
          other.isHidden == isHidden &&
          other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    iconKey,
    defaultQty,
    isBuiltIn,
    isHidden,
    sortOrder,
  );
}

/// 아이템 아이콘의 두 종류. 기본 아이콘(SVG 에셋)은 tint되고 이모지는 그대로 그린다.
@immutable
sealed class ItemGlyph {
  const ItemGlyph();
}

/// assets/icons/{assetKey}.svg.
final class SvgGlyph extends ItemGlyph {
  const SvgGlyph(this.assetKey);

  final String assetKey;

  @override
  bool operator ==(Object other) =>
      other is SvgGlyph && other.assetKey == assetKey;

  @override
  int get hashCode => assetKey.hashCode;
}

final class EmojiGlyph extends ItemGlyph {
  const EmojiGlyph(this.emoji);

  final String emoji;

  @override
  bool operator ==(Object other) => other is EmojiGlyph && other.emoji == emoji;

  @override
  int get hashCode => emoji.hashCode;
}
