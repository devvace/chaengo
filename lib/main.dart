import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  _registerAssetLicenses();
  runApp(const ProviderScope(child: ChaengoApp()));
}

/// 설정 > 오픈소스 라이선스에 패키지 외 에셋(아이콘·폰트) 라이선스도 싣는다.
void _registerAssetLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      const ['game-icons.net (icons)'],
      await rootBundle.loadString('assets/icons/LICENSE-game-icons.txt'),
    );
    yield LicenseEntryWithLineBreaks(
      const ['IBM Plex Sans KR / IBM Plex Mono'],
      await rootBundle.loadString('assets/fonts/LICENSE-IBM-Plex-OFL.txt'),
    );
  });
}
