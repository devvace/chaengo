import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers.dart';
import '../../domain/models/item.dart';
import '../../domain/models/item_category.dart';

part 'item_edit_state.g.dart';

/// 이름 최대 길이(02_screens.md S08, DB 컬럼과 같다).
const kItemNameMaxLength = 20;

enum IconTab { builtIn, emoji }

/// S08 한 화면의 상태. [original]이 null이면 추가 모드.
@immutable
class ItemEditUiState {
  const ItemEditUiState({
    required this.original,
    required this.name,
    required this.category,
    required this.iconKey,
    required this.qty,
    required this.iconTab,
    required this.iconCatalog,
    this.duplicate,
  });

  final Item? original;
  final String name;
  final ItemCategory category;

  /// null = 카테고리 아이콘 폴백.
  final String? iconKey;
  final int qty;
  final IconTab iconTab;

  /// 카테고리별 기본 아이콘 에셋 키(내장 아이템이 쓰는 것).
  final Map<ItemCategory, List<String>> iconCatalog;

  /// 같은 이름의 내장 아이템(있으면 "이미 있는 아이템 → 열기").
  final Item? duplicate;

  bool get isNew => original == null;
  bool get isBuiltIn => original?.isBuiltIn ?? false;

  /// 이름·카테고리를 고칠 수 있는지. 내장 아이템은 아이콘·수량만.
  bool get canEditIdentity => !isBuiltIn;
  bool get canDelete => original != null && !original!.isBuiltIn;

  String get trimmedName => name.trim();

  bool get canSave =>
      trimmedName.isNotEmpty &&
      trimmedName.length <= kItemNameMaxLength &&
      duplicate == null;

  /// 미리보기·선택 표시용.
  ItemGlyph get glyph => Item(
    id: '',
    name: trimmedName,
    category: category,
    iconKey: iconKey,
    defaultQty: qty,
    isBuiltIn: false,
    isHidden: false,
    sortOrder: 0,
  ).glyph;

  String? get emoji => switch (glyph) {
    EmojiGlyph(:final emoji) when iconKey != null => emoji,
    _ => null,
  };

  /// 선택 카테고리 아이콘을 먼저, 나머지 카테고리를 순서대로.
  List<String> get orderedIcons {
    final seen = <String>{};
    return [
      for (final key in iconCatalog[category] ?? const <String>[])
        if (seen.add(key)) key,
      for (final c in ItemCategory.values)
        if (c != category)
          for (final key in iconCatalog[c] ?? const <String>[])
            if (seen.add(key)) key,
    ];
  }

  ItemEditUiState copyWith({
    String? name,
    ItemCategory? category,
    String? Function()? iconKey,
    int? qty,
    IconTab? iconTab,
    Item? Function()? duplicate,
  }) => ItemEditUiState(
    original: original,
    name: name ?? this.name,
    category: category ?? this.category,
    iconKey: iconKey == null ? this.iconKey : iconKey(),
    qty: qty ?? this.qty,
    iconTab: iconTab ?? this.iconTab,
    iconCatalog: iconCatalog,
    duplicate: duplicate == null ? this.duplicate : duplicate(),
  );
}

/// 내장 아이템들이 쓰는 아이콘을 카테고리별로 모은다. 별도 목록을 두지 않고
/// 시드 데이터에서 파생시켜 아이콘이 추가되면 자동으로 따라온다.
@riverpod
Future<Map<ItemCategory, List<String>>> iconCatalog(Ref ref) async {
  await ref.watch(seedBootstrapProvider.future);
  final items = await ref
      .watch(itemDaoProvider)
      .watchItems(includeHidden: true)
      .first;
  return {
    for (final category in ItemCategory.values)
      category: [
        // 카테고리 아이콘은 넣지 않는다. 아무것도 고르지 않으면 그게 쓰이고,
        // 같은 그림의 아이템 아이콘(cat_tent ≈ ic_tent)과 겹쳐 보이기 때문.
        for (final item in items)
          if (item.isBuiltIn &&
              item.category == category &&
              item.iconKey != null &&
              !item.iconKey!.startsWith(Item.emojiPrefix))
            item.iconKey!,
      ],
  };
}

@riverpod
class ItemEditController extends _$ItemEditController {
  @override
  Future<ItemEditUiState> build(
    String? itemId, {
    ItemCategory? initialCategory,
  }) async {
    final catalog = await ref.watch(iconCatalogProvider.future);
    final original = itemId == null
        ? null
        : await ref.read(itemDaoProvider).findById(itemId);
    final iconKey = original?.iconKey;
    return ItemEditUiState(
      original: original,
      name: original?.name ?? '',
      category:
          original?.category ?? initialCategory ?? ItemCategory.values.first,
      iconKey: iconKey,
      qty: original?.defaultQty ?? 1,
      iconTab: iconKey != null && iconKey.startsWith(Item.emojiPrefix)
          ? IconTab.emoji
          : IconTab.builtIn,
      iconCatalog: catalog,
    );
  }

  ItemEditUiState? get _current => state.value;

  void _set(ItemEditUiState next) => state = AsyncData(next);

  Future<void> setName(String name) async {
    final current = _current;
    if (current == null || !current.canEditIdentity) return;
    _set(current.copyWith(name: name, duplicate: () => null));
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final duplicate = await ref
        .read(itemDaoProvider)
        .findByName(
          trimmed,
          excludeId: current.original?.id,
          builtInOnly: true,
        );
    // 그 사이 이름이 또 바뀌었으면 버린다.
    final latest = _current;
    if (latest == null || latest.trimmedName != trimmed) return;
    _set(latest.copyWith(duplicate: () => duplicate));
  }

  void setCategory(ItemCategory category) {
    final current = _current;
    if (current == null || !current.canEditIdentity) return;
    _set(current.copyWith(category: category));
  }

  void setIconTab(IconTab tab) {
    final current = _current;
    if (current == null) return;
    _set(current.copyWith(iconTab: tab));
  }

  /// 같은 아이콘을 다시 누르면 선택 해제(카테고리 아이콘 폴백).
  void toggleIcon(String assetKey) {
    final current = _current;
    if (current == null) return;
    final next = current.iconKey == assetKey ? null : assetKey;
    _set(current.copyWith(iconKey: () => next));
  }

  /// 빈 문자열이면 이모지 선택 해제.
  void setEmoji(String emoji) {
    final current = _current;
    if (current == null) return;
    _set(
      current.copyWith(
        iconKey: () => emoji.isEmpty ? null : Item.emojiIconKey(emoji),
      ),
    );
  }

  void setQty(int qty) {
    final current = _current;
    if (current == null) return;
    _set(current.copyWith(qty: qty.clamp(1, 99)));
  }

  /// 저장 후 아이템 id. 저장할 수 없는 상태면 null.
  Future<String?> save() async {
    final current = _current;
    if (current == null || !current.canSave) return null;
    final dao = ref.read(itemDaoProvider);
    final original = current.original;
    if (original == null) {
      return dao.createCustomItem(
        name: current.trimmedName,
        category: current.category,
        iconKey: current.iconKey,
        defaultQty: current.qty,
      );
    }
    await dao.updateItem(
      original.copyWith(
        name: current.trimmedName,
        category: current.category,
        iconKey: () => current.iconKey,
        defaultQty: current.qty,
      ),
    );
    return original.id;
  }
}
