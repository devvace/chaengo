/// 고정 카테고리 9개. 사용자가 추가·삭제할 수 없다.
///
/// 선언 순서가 곧 표시 순서이며, assets/seed_items.json의 `categories`와
/// 1:1로 일치해야 한다. 불일치는 [SeedLoader]가 로딩 시점에 걸러낸다.
enum ItemCategory {
  tent('tent', '텐트·타프', 'cat_tent'),
  bedding('bedding', '침구', 'cat_bedding'),
  cooking('cooking', '조리', 'cat_cooking'),
  fire('fire', '화기', 'cat_fire'),
  light('light', '조명', 'cat_light'),
  power('power', '전력', 'cat_power'),
  hygiene('hygiene', '위생', 'cat_hygiene'),
  clothing('clothing', '의류', 'cat_clothing'),
  misc('misc', '기타', 'cat_misc');

  const ItemCategory(this.id, this.label, this.iconKey);

  /// DB·백업 JSON·시드에 저장되는 안정적인 식별자.
  final String id;

  /// 화면에 그대로 노출되는 한글 이름.
  final String label;

  /// 아이템에 아이콘이 없을 때 쓰는 폴백 아이콘.
  final String iconKey;

  /// seed_items.json의 `order`와 같은 1-base 순번.
  int get order => index + 1;

  static ItemCategory? tryFromId(String id) {
    for (final category in values) {
      if (category.id == id) return category;
    }
    return null;
  }

  static ItemCategory fromId(String id) {
    final category = tryFromId(id);
    if (category == null) {
      throw ArgumentError.value(id, 'id', '알 수 없는 카테고리');
    }
    return category;
  }
}
