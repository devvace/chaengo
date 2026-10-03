import 'package:drift/drift.dart';

import '../../domain/models/app_settings.dart';
import '../database.dart';
import '../tables.dart';

part 'settings_dao.g.dart';

/// 설정 한 행(id = 1)을 읽고 쓴다. 행이 없으면 [AppSettings.defaults].
@DriftAccessor(tables: [AppSettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  static const _rowId = 1;

  Stream<AppSettings> watchSettings() => (select(
    appSettingsTable,
  )..where((t) => t.id.equals(_rowId))).watchSingleOrNull().map(_toModel);

  Future<AppSettings> getSettings() async => _toModel(
    await (select(
      appSettingsTable,
    )..where((t) => t.id.equals(_rowId))).getSingleOrNull(),
  );

  Future<void> saveSettings(AppSettings settings) async {
    await into(appSettingsTable).insertOnConflictUpdate(
      AppSettingsTableCompanion.insert(
        id: const Value(_rowId),
        keepScreenOn: Value(settings.keepScreenOn),
        haptics: Value(settings.haptics),
      ),
    );
  }

  static AppSettings _toModel(AppSettingsRow? row) => row == null
      ? AppSettings.defaults
      : AppSettings(keepScreenOn: row.keepScreenOn, haptics: row.haptics);
}
