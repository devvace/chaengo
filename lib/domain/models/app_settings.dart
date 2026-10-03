import 'package:flutter/foundation.dart';

/// S09 "체크 화면 옵션". 기기 내 DB에 저장된다.
@immutable
class AppSettings {
  const AppSettings({required this.keepScreenOn, required this.haptics});

  /// 저장된 값이 없을 때. 둘 다 기본 ON(02_screens.md S09).
  static const defaults = AppSettings(keepScreenOn: true, haptics: true);

  final bool keepScreenOn;
  final bool haptics;

  AppSettings copyWith({bool? keepScreenOn, bool? haptics}) => AppSettings(
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    haptics: haptics ?? this.haptics,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.keepScreenOn == keepScreenOn &&
          other.haptics == haptics;

  @override
  int get hashCode => Object.hash(keepScreenOn, haptics);
}
