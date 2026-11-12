import 'package:drift/drift.dart';

import '../database.dart';

/// 2026-11 확정 아이콘. 기존 기본값을 유지한 내장 아이템만 갱신한다.
/// 로프는 제외한다. 새 시드는 seed_items.json에서 같은 키를 사용한다.
const builtInIconUpdates = <String, ({String? previous, String current})>{
  'peg_hammer': (previous: 'ic_peg', current: 'ic_peg_hammer'),
  'poles': (previous: null, current: 'ic_poles'),
  'air_pump': (previous: null, current: 'ic_air_pump'),
  'kitchen_table': (previous: null, current: 'ic_kitchen_table'),
  'dish_rack': (previous: null, current: 'ic_dish_rack'),
  'butane': (previous: 'ic_gas_canister', current: 'ic_butane'),
  'heater': (previous: null, current: 'ic_heater'),
  'fire_extinguisher': (previous: null, current: 'ic_fire_extinguisher'),
  'lantern_stand': (previous: null, current: 'ic_lantern_stand'),
  'wet_wipes': (previous: null, current: 'ic_wet_wipes'),
  'tissue': (previous: null, current: 'ic_tissue'),
  'jacket': (previous: null, current: 'ic_jacket'),
  'beanie': (previous: null, current: 'ic_beanie'),
  'speaker': (previous: null, current: 'ic_speaker'),
  'games': (previous: null, current: 'ic_games'),
  'tarp_poles': (previous: null, current: 'ic_poles'),
};

/// 기본 아이콘(null 포함)을 새 기본값으로 맞춘다.
/// 사용자가 선택한 다른 SVG·이모지, 수량·숨김·세트·트립은 유지한다.
/// 동일 키가 된 행은 다음 실행에서 수정하지 않는다.
Future<void> refreshBuiltInIcons(AppDatabase db) async {
  await db.transaction(() async {
    for (final entry in builtInIconUpdates.entries) {
      final previous = entry.value.previous;
      await (db.update(db.items)..where(
            (t) =>
                t.id.equals(entry.key) &
                t.isBuiltIn.equals(true) &
                (previous == null
                    ? t.iconKey.isNull()
                    : t.iconKey.equals(previous)),
          ))
          .write(ItemsCompanion(iconKey: Value(entry.value.current)));
    }
  });
}
