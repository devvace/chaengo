import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/app_settings.dart';
import '../../domain/models/item_category.dart';
import '../../domain/models/trip.dart';
import '../database.dart';
import '../mappers.dart';
import '../seed/built_in_icon_updates.dart';

/// 백업 파일이 깨졌거나 이 앱이 만든 형식이 아닐 때.
class BackupFormatException implements Exception {
  BackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

/// 다른 schemaVersion으로 만든 백업. 가져오기를 막는다(S09).
class BackupVersionException implements Exception {
  BackupVersionException(this.fileVersion);

  final Object? fileVersion;

  @override
  String toString() =>
      'BackupVersionException: 파일 $fileVersion, 앱 $kSchemaVersion';
}

/// 가져오기 전에 확인 다이얼로그에 보여줄 요약과, 실제로 넣을 행들.
class BackupData {
  BackupData._({
    required this.exportedAt,
    required this.items,
    required this.sets,
    required this.setItems,
    required this.trips,
    required this.tripItems,
    required this.settings,
  });

  final DateTime? exportedAt;
  final List<ItemsCompanion> items;
  final List<GearSetsCompanion> sets;
  final List<GearSetItemsCompanion> setItems;
  final List<TripsCompanion> trips;
  final List<TripItemsCompanion> tripItems;
  final AppSettings settings;

  int get itemCount => items.length;
  int get setCount => sets.length;
  int get tripCount => trips.length;
}

/// 전체 데이터 JSON 백업(S09). 형식:
/// `{ schemaVersion, exportedAt, items[], sets[{…, items[]}],
///    trips[{…, items[]}], settings{} }`.
/// 날짜는 ISO-8601 문자열, enum은 안정 id 문자열로 쓴다.
class BackupCodec {
  BackupCodec(this._db);

  final AppDatabase _db;

  Future<String> exportJson({DateTime? now}) async {
    final items = await _db.select(_db.items).get();
    final sets = await _db.select(_db.gearSets).get();
    final setItems = await _db.select(_db.gearSetItems).get();
    final trips = await _db.select(_db.trips).get();
    final tripItems = await _db.select(_db.tripItems).get();
    final settings = await _db.settingsDao.getSettings();

    final json = {
      'schemaVersion': kSchemaVersion,
      'exportedAt': (now ?? DateTime.now()).toIso8601String(),
      'items': [
        for (final row in items)
          {
            'id': row.id,
            'name': row.name,
            'category': row.category.id,
            'iconKey': row.iconKey,
            'defaultQty': row.defaultQty,
            'isBuiltIn': row.isBuiltIn,
            'isHidden': row.isHidden,
            'sortOrder': row.sortOrder,
          },
      ],
      'sets': [
        for (final row in sets)
          {
            'id': row.id,
            'name': row.name,
            'isBuiltIn': row.isBuiltIn,
            'lastUsedAt': row.lastUsedAt?.toIso8601String(),
            'createdAt': row.createdAt.toIso8601String(),
            'items': [
              for (final e in setItems.where((e) => e.setId == row.id))
                {'item': e.itemId, 'qty': e.qty},
            ],
          },
      ],
      'trips': [
        for (final row in trips)
          {
            'id': row.id,
            'name': row.name,
            'startDate': row.startDate.toIso8601String(),
            'endDate': row.endDate.toIso8601String(),
            'sourceSetId': row.sourceSetId,
            'savedAsSetId': row.savedAsSetId,
            'status': row.status.id,
            'createdAt': row.createdAt.toIso8601String(),
            'completedAt': row.completedAt?.toIso8601String(),
            'items': [
              for (final e in tripItems.where((e) => e.tripId == row.id))
                {'item': e.itemId, 'qty': e.qty, 'state': e.state.id},
            ],
          },
      ],
      'settings': {
        'keepScreenOn': settings.keepScreenOn,
        'haptics': settings.haptics,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  /// 파일을 읽어 검증만 한다. DB는 건드리지 않는다.
  BackupData parse(String raw) {
    final Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      throw BackupFormatException('JSON이 아니다');
    }
    final root = _map(json, '최상위');
    final version = root['schemaVersion'];
    if (version != kSchemaVersion) throw BackupVersionException(version);

    final itemIds = <String>{};
    final items = <ItemsCompanion>[];
    for (final e in _list(root['items'], 'items')) {
      final m = _map(e, 'items 원소');
      final id = _str(m, 'id');
      if (!itemIds.add(id)) throw BackupFormatException('아이템 id 중복: $id');
      final category = ItemCategory.tryFromId(_str(m, 'category'));
      if (category == null) {
        throw BackupFormatException('아이템 $id 카테고리가 잘못됨');
      }
      final name = _str(m, 'name');
      if (name.length > 20) throw BackupFormatException('아이템 $id 이름이 20자 초과');
      items.add(
        ItemsCompanion.insert(
          id: id,
          name: name,
          category: category,
          iconKey: Value(_strOrNull(m, 'iconKey')),
          defaultQty: Value(_qty(m['defaultQty'], '아이템 $id')),
          isBuiltIn: Value(_bool(m, 'isBuiltIn')),
          isHidden: Value(_bool(m, 'isHidden')),
          sortOrder: Value(_int(m, 'sortOrder')),
        ),
      );
    }

    final setIds = <String>{};
    final sets = <GearSetsCompanion>[];
    final setItems = <GearSetItemsCompanion>[];
    for (final e in _list(root['sets'], 'sets')) {
      final m = _map(e, 'sets 원소');
      final id = _str(m, 'id');
      if (!setIds.add(id)) throw BackupFormatException('세트 id 중복: $id');
      sets.add(
        GearSetsCompanion.insert(
          id: id,
          name: _str(m, 'name'),
          isBuiltIn: Value(_bool(m, 'isBuiltIn')),
          lastUsedAt: Value(_dateOrNull(m, 'lastUsedAt')),
          createdAt: _date(m, 'createdAt'),
        ),
      );
      for (final entry in _list(m['items'], '세트 $id items')) {
        final em = _map(entry, '세트 $id 아이템');
        final itemId = _ref(_str(em, 'item'), itemIds, '세트 $id');
        setItems.add(
          GearSetItemsCompanion.insert(
            setId: id,
            itemId: itemId,
            qty: Value(_qty(em['qty'], '세트 $id/$itemId')),
          ),
        );
      }
    }

    final trips = <TripsCompanion>[];
    final tripItems = <TripItemsCompanion>[];
    final tripIds = <String>{};
    var activeCount = 0;
    for (final e in _list(root['trips'], 'trips')) {
      final m = _map(e, 'trips 원소');
      final id = _str(m, 'id');
      if (!tripIds.add(id)) throw BackupFormatException('트립 id 중복: $id');
      final statusId = _str(m, 'status');
      final status = TripStatus.values.where((s) => s.id == statusId);
      if (status.isEmpty) throw BackupFormatException('트립 $id 상태가 잘못됨');
      if (status.single == TripStatus.active) activeCount++;
      String? setRef(String key) {
        final v = _strOrNull(m, key);
        return v == null ? null : _ref(v, setIds, '트립 $id $key');
      }

      trips.add(
        TripsCompanion.insert(
          id: id,
          name: _str(m, 'name'),
          startDate: _date(m, 'startDate'),
          endDate: _date(m, 'endDate'),
          sourceSetId: Value(setRef('sourceSetId')),
          savedAsSetId: Value(setRef('savedAsSetId')),
          status: status.single,
          createdAt: _date(m, 'createdAt'),
          completedAt: Value(_dateOrNull(m, 'completedAt')),
        ),
      );
      for (final entry in _list(m['items'], '트립 $id items')) {
        final em = _map(entry, '트립 $id 아이템');
        final itemId = _ref(_str(em, 'item'), itemIds, '트립 $id');
        final stateId = _str(em, 'state');
        final state = PackState.values.where((s) => s.id == stateId);
        if (state.isEmpty) {
          throw BackupFormatException('트립 $id/$itemId 상태가 잘못됨');
        }
        tripItems.add(
          TripItemsCompanion.insert(
            tripId: id,
            itemId: itemId,
            qty: Value(_qty(em['qty'], '트립 $id/$itemId')),
            state: state.single,
          ),
        );
      }
    }
    if (activeCount > 1) {
      throw BackupFormatException('진행 중 트립이 $activeCount개');
    }

    final s = _map(root['settings'] ?? const <String, Object?>{}, 'settings');
    final settings = AppSettings(
      keepScreenOn: s['keepScreenOn'] is bool
          ? s['keepScreenOn']! as bool
          : AppSettings.defaults.keepScreenOn,
      haptics: s['haptics'] is bool
          ? s['haptics']! as bool
          : AppSettings.defaults.haptics,
    );

    final exportedAt = root['exportedAt'];
    return BackupData._(
      exportedAt: exportedAt is String ? DateTime.tryParse(exportedAt) : null,
      items: items,
      sets: sets,
      setItems: setItems,
      trips: trips,
      tripItems: tripItems,
      settings: settings,
    );
  }

  /// 현재 데이터를 모두 지우고 백업으로 바꾼다. 실패하면 아무것도 바뀌지 않는다.
  Future<void> restore(BackupData data) async {
    await _db.transaction(() async {
      await _db.clearAll();
      await _db.batch((b) {
        b.insertAll(_db.items, data.items);
        b.insertAll(_db.gearSets, data.sets);
        b.insertAll(_db.gearSetItems, data.setItems);
        b.insertAll(_db.trips, data.trips);
        b.insertAll(_db.tripItems, data.tripItems);
      });
      await _db.settingsDao.saveSettings(data.settings);
      await refreshBuiltInIcons(_db);
    });
  }

  // ── 검증 헬퍼 ──

  static Map<String, Object?> _map(Object? v, String where) {
    if (v is Map<String, Object?>) return v;
    throw BackupFormatException('$where이(가) 객체가 아니다');
  }

  static List<Object?> _list(Object? v, String where) {
    if (v is List<Object?>) return v;
    throw BackupFormatException('$where이(가) 배열이 아니다');
  }

  static String _str(Map<String, Object?> m, String key) {
    final v = m[key];
    if (v is String && v.isNotEmpty) return v;
    throw BackupFormatException('$key가 비었거나 문자열이 아니다');
  }

  static String? _strOrNull(Map<String, Object?> m, String key) {
    final v = m[key];
    if (v == null || v is String) return v as String?;
    throw BackupFormatException('$key가 문자열이 아니다');
  }

  static bool _bool(Map<String, Object?> m, String key) {
    final v = m[key];
    if (v is bool) return v;
    throw BackupFormatException('$key가 bool이 아니다');
  }

  static int _int(Map<String, Object?> m, String key) {
    final v = m[key];
    if (v is int) return v;
    throw BackupFormatException('$key가 정수가 아니다');
  }

  static int _qty(Object? v, String where) {
    if (v is int) {
      try {
        return requireValidQty(v);
      } on ArgumentError {
        // 아래에서 형식 오류로 통일한다.
      }
    }
    throw BackupFormatException('$where 수량이 1–99가 아니다: $v');
  }

  static DateTime _date(Map<String, Object?> m, String key) {
    final v = _dateOrNull(m, key);
    if (v != null) return v;
    throw BackupFormatException('$key 날짜가 없다');
  }

  static DateTime? _dateOrNull(Map<String, Object?> m, String key) {
    final v = m[key];
    if (v == null) return null;
    final parsed = v is String ? DateTime.tryParse(v) : null;
    if (parsed == null) throw BackupFormatException('$key 날짜 형식이 잘못됨');
    return parsed;
  }

  static String _ref(String id, Set<String> known, String where) {
    if (known.contains(id)) return id;
    throw BackupFormatException('$where가 없는 id를 참조한다: $id');
  }
}
