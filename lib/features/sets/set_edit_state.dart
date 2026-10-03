import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/async_combine.dart';
import '../../data/providers.dart';
import '../../domain/models/gear_set.dart';
import '../../domain/models/item.dart';
import '../../domain/models/item_category.dart';
import '../../domain/models/trip.dart';

part 'set_edit_state.g.dart';

/// S06으로 들어오는 경로. [setId]가 있으면 기존 세트 편집(복제는 S05가 먼저
/// 복사본을 만든 뒤 그 id로 연다), [fromTripId]가 있으면 S01 [세트로 저장],
/// 둘 다 없으면 새 세트.
@immutable
class SetEditArgs {
  const SetEditArgs({this.setId, this.fromTripId});

  final String? setId;
  final String? fromTripId;

  @override
  bool operator ==(Object other) =>
      other is SetEditArgs &&
      other.setId == setId &&
      other.fromTripId == fromTripId;

  @override
  int get hashCode => Object.hash(setId, fromTripId);
}

/// 저장 전까지 메모리에만 있는 편집본.
@immutable
class SetDraft {
  const SetDraft({
    required this.original,
    required this.initialName,
    required this.initialEntries,
    required this.name,
    required this.entries,
  });

  /// 새 세트·트립에서 저장이면 null.
  final GearSet? original;
  final String initialName;
  final Map<String, int> initialEntries;
  final String name;

  /// 아이템 id → 수량.
  final Map<String, int> entries;

  bool get isDirty =>
      name != initialName || !mapEquals(entries, initialEntries);

  SetDraft copyWith({String? name, Map<String, int>? entries}) => SetDraft(
    original: original,
    initialName: initialName,
    initialEntries: initialEntries,
    name: name ?? this.name,
    entries: entries ?? this.entries,
  );
}

/// S06 한 화면이 그리는 전부.
@immutable
class SetEditUiState {
  const SetEditUiState({
    required this.draft,
    required this.groups,
    required this.inUse,
  });

  final SetDraft draft;

  /// 숨김을 뺀 전체 아이템을 카테고리별로. 빈 카테고리는 빠진다.
  final List<({ItemCategory category, List<Item> items})> groups;

  /// 진행 중 트립의 원본 세트면 삭제할 수 없다.
  final bool inUse;

  GearSet? get original => draft.original;
  String get name => draft.name;

  bool isIncluded(String itemId) => draft.entries.containsKey(itemId);
  int qtyOf(String itemId) => draft.entries[itemId] ?? 1;

  /// 화면에 보이는(숨김 아닌) 아이템 중 담긴 수.
  int get includedCount => groups.fold(
    0,
    (sum, g) => sum + g.items.where((i) => isIncluded(i.id)).length,
  );

  int includedIn(List<Item> items) =>
      items.where((i) => isIncluded(i.id)).length;

  bool get canSave =>
      draft.name.trim().isNotEmpty && (draft.isDirty || original == null);

  bool get canDelete => original != null && !original!.isBuiltIn && !inUse;
}

@riverpod
class SetEditController extends _$SetEditController {
  @override
  Future<SetDraft> build(SetEditArgs args) async {
    await ref.watch(seedBootstrapProvider.future);
    final setDao = ref.read(setDaoProvider);
    final tripDao = ref.read(tripDaoProvider);

    if (args.setId case final setId?) {
      final set = await setDao.findById(setId);
      final entries = await setDao.getEntries(setId);
      return SetDraft(
        original: set,
        initialName: set?.name ?? '',
        initialEntries: entries,
        name: set?.name ?? '',
        entries: entries,
      );
    }
    if (args.fromTripId case final tripId?) {
      final trip = await tripDao.findById(tripId);
      final entries = await tripDao.tripEntries(tripId);
      final name = trip?.name ?? '';
      // 새 세트이므로 처음부터 저장 가능해야 한다. initial은 비교용일 뿐.
      return SetDraft(
        original: null,
        initialName: name,
        initialEntries: entries,
        name: name,
        entries: entries,
      );
    }
    return const SetDraft(
      original: null,
      initialName: '',
      initialEntries: {},
      name: '',
      entries: {},
    );
  }

  SetDraft? get _draft => state.value;

  void _set(SetDraft next) => state = AsyncData(next);

  void setName(String name) {
    final draft = _draft;
    if (draft != null) _set(draft.copyWith(name: name));
  }

  /// 타일 탭 = 담기·빼기. 담을 때 수량은 아이템의 기본 수량.
  void toggle(Item item) {
    final draft = _draft;
    if (draft == null) return;
    final next = {...draft.entries};
    if (next.remove(item.id) == null) next[item.id] = item.defaultQty;
    _set(draft.copyWith(entries: next));
  }

  /// 롱프레스 수량. 안 담긴 아이템이면 담으면서 수량을 정한다.
  void setQty(String itemId, int qty) {
    final draft = _draft;
    if (draft == null) return;
    _set(draft.copyWith(entries: {...draft.entries, itemId: qty.clamp(1, 99)}));
  }

  /// S08에서 새로 만든 아이템을 자동으로 담는다.
  Future<void> includeNewItem(String itemId) async {
    final item = await ref.read(itemDaoProvider).findById(itemId);
    final draft = _draft;
    if (item == null || draft == null) return;
    _set(draft.copyWith(entries: {...draft.entries, itemId: item.defaultQty}));
  }

  /// 저장 후 세트 id.
  Future<String?> save() async {
    final draft = _draft;
    if (draft == null || draft.name.trim().isEmpty) return null;
    final name = draft.name.trim();
    final original = draft.original;
    if (original != null) {
      await ref
          .read(setDaoProvider)
          .updateSet(original.id, name: name, entries: draft.entries);
      return original.id;
    }
    if (args.fromTripId case final tripId?) {
      return ref
          .read(tripDaoProvider)
          .saveTripAsSet(tripId, name: name, entries: draft.entries);
    }
    return ref
        .read(setDaoProvider)
        .createSet(name: name, entries: draft.entries);
  }

  Future<void> delete() async {
    final original = _draft?.original;
    if (original == null) return;
    await ref.read(setDaoProvider).deleteSet(original.id);
  }
}

@riverpod
Stream<List<Item>> _setEditItems(Ref ref) =>
    ref.watch(itemDaoProvider).watchVisibleItems();

@riverpod
Stream<TripDetail?> _setEditActiveTrip(Ref ref) =>
    ref.watch(tripDaoProvider).watchActiveTrip();

@riverpod
AsyncValue<SetEditUiState> setEditUiState(Ref ref, SetEditArgs args) {
  final draftAsync = ref.watch(setEditControllerProvider(args));
  final itemsAsync = ref.watch(_setEditItemsProvider);
  final activeAsync = ref.watch(_setEditActiveTripProvider);

  return combineAsync([draftAsync, itemsAsync, activeAsync], () {
    final draft = draftAsync.requireValue;
    final items = itemsAsync.requireValue;
    final active = activeAsync.requireValue;
    return SetEditUiState(
      draft: draft,
      groups: [
        for (final category in ItemCategory.values)
          if (items.where((i) => i.category == category).toList()
              case final inCategory when inCategory.isNotEmpty)
            (category: category, items: inCategory),
      ],
      inUse:
          draft.original != null &&
          active?.trip.sourceSetId == draft.original!.id,
    );
  });
}
