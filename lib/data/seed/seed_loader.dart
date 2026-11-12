import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../domain/models/item_category.dart';
import '../database.dart';
import 'built_in_icon_updates.dart';

/// 시드 파일이 코드와 어긋났을 때 던진다. 조용히 넘어가면 아이콘 폴백이나
/// 카테고리가 말없이 깨지므로, 개발 중에 바로 터지게 둔다.
class SeedFormatException implements Exception {
  SeedFormatException(this.message);

  final String message;

  @override
  String toString() => 'SeedFormatException: $message';
}

/// assets/seed_items.json을 읽어 내장 아이템·내장 세트를 넣는다.
///
/// 스키마: `{ schemaVersion, categories[], items[], sets[] }`.
/// 아이템의 `icon`이 null이면 카테고리 아이콘으로 폴백한다(여기서 채우지
/// 않고 null 그대로 저장한 뒤 [Item.glyph]가 처리한다).
class SeedLoader {
  SeedLoader(this._db, {AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String assetPath = 'assets/seed_items.json';

  final AppDatabase _db;
  final AssetBundle _bundle;

  /// 앱 시작 시 새 DB는 시드하고, 기존 DB는 기본 아이콘 연결만 갱신한다.
  Future<void> ensureSeeded() async {
    final total = _db.items.id.count();
    final row = await (_db.selectOnly(
      _db.items,
    )..addColumns([total])).getSingle();
    if ((row.read(total) ?? 0) > 0) {
      await refreshBuiltInIcons(_db);
      return;
    }
    await seed();
  }

  /// S09 전체 초기화. 사용자 데이터를 모두 지우고 내장 데이터만 남긴다.
  Future<void> resetToSeed() async {
    await _db.clearAll();
    await seed();
  }

  /// 시드를 실제로 적재한다. 이미 데이터가 있으면 중복이 생기므로
  /// 보통 [ensureSeeded]나 [resetToSeed]를 쓴다.
  Future<void> seed() async {
    final data = await _readSeed();
    await _db.transaction(() async {
      await _db.batch((b) {
        b.insertAll(_db.items, data.items);
        b.insertAll(_db.gearSets, data.sets);
        b.insertAll(_db.gearSetItems, data.setItems);
      });
    });
  }

  Future<_SeedData> _readSeed() async {
    final raw = await _bundle.loadString(assetPath);
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      throw SeedFormatException('최상위가 객체가 아니다');
    }

    final version = json['schemaVersion'];
    if (version != kSchemaVersion) {
      throw SeedFormatException(
        '시드 schemaVersion $version != 앱 $kSchemaVersion',
      );
    }

    _verifyCategories(json['categories']);

    final itemsJson = json['items'];
    if (itemsJson is! List) throw SeedFormatException('items가 배열이 아니다');

    final now = DateTime.now();
    final itemRows = <ItemsCompanion>[];
    final seenItemIds = <String>{};
    final orderByCategory = <ItemCategory, int>{};

    for (final entry in itemsJson) {
      if (entry is! Map<String, dynamic>) {
        throw SeedFormatException('items 원소가 객체가 아니다: $entry');
      }
      final id = _requireString(entry, 'id');
      if (!seenItemIds.add(id)) {
        throw SeedFormatException('아이템 id 중복: $id');
      }
      final categoryId = _requireString(entry, 'category');
      final category = ItemCategory.tryFromId(categoryId);
      if (category == null) {
        throw SeedFormatException('아이템 $id의 카테고리가 enum에 없다: $categoryId');
      }
      final qty = entry['defaultQty'];
      if (qty is! int || qty < 1 || qty > 99) {
        throw SeedFormatException('아이템 $id의 defaultQty가 1–99가 아니다: $qty');
      }
      final icon = entry['icon'];
      if (icon != null && icon is! String) {
        throw SeedFormatException('아이템 $id의 icon이 문자열도 null도 아니다');
      }
      final order = (orderByCategory[category] ?? 0) + 1;
      orderByCategory[category] = order;

      itemRows.add(
        ItemsCompanion.insert(
          id: id,
          name: _requireString(entry, 'name'),
          category: category,
          iconKey: Value(icon as String?),
          defaultQty: Value(qty),
          isBuiltIn: const Value(true),
          sortOrder: Value(order),
        ),
      );
    }

    final setsJson = json['sets'];
    if (setsJson is! List) throw SeedFormatException('sets가 배열이 아니다');

    final setRows = <GearSetsCompanion>[];
    final setItemRows = <GearSetItemsCompanion>[];

    for (final entry in setsJson) {
      if (entry is! Map<String, dynamic>) {
        throw SeedFormatException('sets 원소가 객체가 아니다: $entry');
      }
      final setId = _requireString(entry, 'id');
      setRows.add(
        GearSetsCompanion.insert(
          id: setId,
          name: _requireString(entry, 'name'),
          isBuiltIn: Value(entry['isBuiltIn'] == true),
          createdAt: now,
        ),
      );

      final entryItems = entry['items'];
      if (entryItems is! List) {
        throw SeedFormatException('세트 $setId의 items가 배열이 아니다');
      }
      for (final member in entryItems) {
        if (member is! Map<String, dynamic>) {
          throw SeedFormatException('세트 $setId의 items 원소가 객체가 아니다');
        }
        final itemId = _requireString(member, 'item');
        if (!seenItemIds.contains(itemId)) {
          throw SeedFormatException('세트 $setId가 없는 아이템을 참조한다: $itemId');
        }
        final qty = member['qty'];
        if (qty is! int || qty < 1 || qty > 99) {
          throw SeedFormatException('세트 $setId의 $itemId 수량이 1–99가 아니다: $qty');
        }
        setItemRows.add(
          GearSetItemsCompanion.insert(
            setId: setId,
            itemId: itemId,
            qty: Value(qty),
          ),
        );
      }
    }

    return _SeedData(items: itemRows, sets: setRows, setItems: setItemRows);
  }

  /// 시드의 카테고리 9개가 [ItemCategory]와 id·순서까지 같은지 확인한다.
  /// 라벨·아이콘의 단일 출처는 enum이므로 여기선 대조만 한다.
  void _verifyCategories(Object? raw) {
    if (raw is! List) throw SeedFormatException('categories가 배열이 아니다');
    if (raw.length != ItemCategory.values.length) {
      throw SeedFormatException(
        '카테고리 개수 ${raw.length} != enum ${ItemCategory.values.length}',
      );
    }
    final sorted = [...raw]
      ..sort((a, b) {
        final ao = (a as Map<String, dynamic>)['order'] as int? ?? 0;
        final bo = (b as Map<String, dynamic>)['order'] as int? ?? 0;
        return ao.compareTo(bo);
      });
    for (var i = 0; i < sorted.length; i++) {
      final entry = sorted[i] as Map<String, dynamic>;
      final expected = ItemCategory.values[i];
      if (entry['id'] != expected.id) {
        throw SeedFormatException(
          '카테고리 ${i + 1}번이 ${entry['id']}, enum은 ${expected.id}',
        );
      }
      if (entry['icon'] != expected.iconKey) {
        throw SeedFormatException(
          '카테고리 ${expected.id}의 아이콘이 ${entry['icon']}, enum은 ${expected.iconKey}',
        );
      }
    }
  }

  static String _requireString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw SeedFormatException('$key가 비어 있거나 문자열이 아니다: $value');
    }
    return value;
  }
}

class _SeedData {
  _SeedData({required this.items, required this.sets, required this.setItems});

  final List<ItemsCompanion> items;
  final List<GearSetsCompanion> sets;
  final List<GearSetItemsCompanion> setItems;
}
