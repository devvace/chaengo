import 'package:flutter/widgets.dart';

/// design/tokens.md를 그대로 옮긴 값. 여기 없는 색·크기를 새로 만들지 않는다.
abstract final class AppColors {
  static const bg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF4F4F2);
  static const line = Color(0xFFE4E4E0);
  static const lineStrong = Color(0xFFD6D6D2);
  static const ink = Color(0xFF111111);
  static const inkSub = Color(0xFF5C5C5C);
  static const inkMute = Color(0xFF8A8A85);

  /// 챙김 상태에만 쓴다.
  static const done = Color(0xFF157A48);
  static const doneOnDark = Color(0xFF4FBF84);

  /// 삭제·초기화 텍스트에만 쓴다.
  static const danger = Color(0xFFB42318);

  /// S06 안 담김 타일의 점선.
  static const dashed = Color(0xFFC9C9C4);

  // 홈 진행 중 카드.
  static const cardDark = Color(0xFF111111);
  static const cardDarkText = Color(0xFFFFFFFF);
  static const cardDarkSub = Color(0xFFB5B5B0);
  static const cardDarkLine = Color(0xFF2C2C2A);
}

abstract final class AppSizes {
  // 아이템 타일
  static const tile = 76.0;
  static const tileRadius = 16.0;
  static const tileIcon = 44.0;
  static const tileGridColumns = 4;
  static const tileGapX = 8.0;
  static const tileGapY = 12.0;
  static const screenPadding = 20.0;

  // 다른 크기의 아이콘 타일
  /// 44·40·60 작은 타일의 radius. tokens.md에는 없고 hifi S01 미니 타일(.mini)값.
  static const smallTileRadius = 12.0;
  static const previewTile = 44.0;
  static const previewIcon = 26.0;
  static const rowTile = 40.0;
  static const rowIcon = 24.0;

  /// S08 아이콘 선택 그리드: 5열 60px.
  static const pickerTile = 60.0;
  static const pickerIcon = 34.0;
  static const pickerColumns = 5;

  static const cardRadius = 16.0;

  // 버튼
  static const buttonHeight = 56.0;
  static const buttonRadius = 14.0;
  static const pillHeight = 36.0;
  static const pillRadius = 18.0;

  // 칩
  static const chipHeight = 34.0;
  static const chipRadius = 17.0;
  static const chipPaddingX = 14.0;

  // 입력
  static const inputHeight = 52.0;
  static const inputRadius = 14.0;

  // 뱃지(수량·체크)
  static const badge = 22.0;
  static const badgeOffset = -6.0;

  // 하단 탭
  static const tabBarHeight = 72.0;
  static const tabIcon = 24.0;

  static const minTouchTarget = 44.0;

  // 선 두께
  static const hairline = 1.0;
  static const border = 1.5;
  static const borderStrong = 2.0;

  /// S03 제외 타일 전체 투명도.
  static const excludedOpacity = 0.4;
}
