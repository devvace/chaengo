# 챙고 (CHAENGO) — Claude Code 작업 지침

오토캠퍼용 캠핑 짐 체크리스트 앱. Flutter, 1차 파일럿 Android·iOS 동시. 서버·로그인 없음, 전부 기기 내 저장.

## 먼저 읽을 것 (순서대로)
1. docs/00_brand.md — 이름·세계관. 카피에 반영 (아이템 탭 = "창고").
2. docs/01_requirements.md — 기능 범위. Out of Scope에 있는 건 만들지 않는다.
3. docs/02_screens.md — 화면 9개 사양 + 도메인 모델 3층(Item / Set / Trip).
4. design/tokens.md — 색·글자·형태·타일 상태. **여기 없는 색·크기를 새로 만들지 않는다.**
5. design/icons/INDEX.md — 아이콘 파일과 라이선스.

design/screens/의 HTML은 참고용 원본. 구현 기준은 위 md 파일.

## 기술 결정 (변경 시 먼저 물어볼 것)
- Flutter stable, Dart 3, Material 3 커스텀 ThemeData(tokens.md 그대로). Android minSdk 26, iOS 15+.
- 양쪽 동일 UI(Material). Cupertino 위젯 혼용 금지. 단, 스크롤 물리·뒤로가기 제스처는 플랫폼 기본을 따른다.
- 상태 관리: flutter_riverpod (+ riverpod_generator). 화면 단위 UiState 하나.
- 로컬 DB: drift (SQLite). 마이그레이션은 schemaVersion으로 관리 — 백업 JSON도 같은 버전 사용.
- 라우팅: go_router. 하단 탭 4개는 StatefulShellRoute.
- 아이콘: design/icons/*.svg → assets/icons/ 로 복사, flutter_svg + colorFilter로 tint. 아이콘 파일을 수정하지 않는다.
- 폰트: IBM Plex Sans KR / IBM Plex Mono를 assets/fonts에 번들(pubspec fonts 등록). google_fonts 패키지 사용 금지(네트워크). 숫자는 예외 없이 Mono.
- 백업 내보내기: path_provider로 임시 파일 생성 → share_plus. iOS는 sharePositionOrigin 필수(iPad 크래시 방지). Android는 FileProvider 자동 처리.
- 백업 가져오기: file_picker, 확장자 필터 json. iOS는 UTType 등록 없이 '파일' 앱에서 선택 가능하면 충분.
- 화면 켜짐 유지: wakelock_plus, S03 진입 시 enable·이탈 시 disable. 양쪽 동일 동작.
- 햅틱: HapticFeedback.lightImpact, 설정으로 on/off. Android는 기기별 진동 유무 차이가 있으니 실패해도 무시.
- 네트워크 패키지(http, dio 등)·분석 SDK 추가 금지(요구사항 미결 항목).

## 폴더 구조
```
lib/
  app/          router, theme(tokens.dart, typography.dart), app.dart
  data/         drift db, tables, daos, seed loader(assets/seed_items.json), backup(json)
  domain/       models(Item, GearSet, Trip, TripItem), repositories
  features/
    trips/      S01 목록, S02 생성, S03 체크, S04 추가 시트
    sets/       S05 목록, S06 편집
    inventory/  S07 창고, S08 아이템 편집
    settings/   S09
  widgets/      ItemTile(check/edit 두 문법), CategoryHeader, Chip, PrimaryButton, QtyBadge
```
Set은 Dart 예약어와 겹치므로 모델명은 `GearSet`.

## 플랫폼 체크리스트 (첫 빌드 전)
- ios/Runner/Info.plist: 파일 공유 관련 키 불필요(share_plus는 시스템 시트). 사진·위치 권한 키 추가 금지(2차 기능).
- android/app/build.gradle: minSdk 26, 백업 파일 공유용 FileProvider는 share_plus가 제공.
- 폰트 pubspec 등록 후 양쪽에서 한글·Mono 렌더링 확인.
- 아이콘 SVG 23개 `flutter_svg`로 양쪽 렌더링 확인(iOS에서 opacity 속성 렌더링 동일한지).

## 도메인 불변 규칙
- Trip 생성 시 GearSet의 아이템을 **복사**한다. 이후 GearSet 수정은 Trip에 영향 없음.
- active Trip은 1개만.
- TripItem 상태 3종: unpacked / packed / excluded. 진행률 분모에서 excluded는 제외.
- 카테고리 9개 고정 enum, 사용자 추가 불가.
- built-in 아이템·세트는 삭제 불가(숨김만).

## UI 불변 규칙
- S03 타일 탭 = 즉시 토글 + 즉시 DB 저장. 저장 버튼 없음.
- S03(챔김: 그린 채움 / 점선 제외)과 S06(포함: 굵은 ink 테두리 / 점선 회색)의 타일 문법을 섞지 않는다. ItemTile은 mode 파라미터로 두 문법을 분리.
- 터치 타겟 최소 44, 타일 76.
- 하드코딩 색·크기 금지. 전부 theme/tokens.dart에서 가져온다.

## 작업 방식
- 구현 순서: data(테이블·DAO·seed) → theme·공통 위젯(타일 3상태 데모 페이지 포함) → inventory(S07/S08) → sets(S05/S06) → trips(S01/S02/S03/S04) → settings(S09).
- 화면 하나 끝낼 때마다 docs/02_screens.md의 해당 표와 대조하고 빠진 항목을 보고한다.
- 사양에 없는 기능이 필요해 보이면 만들지 말고 질문한다.
- 아이콘 라이선스 표기(설정 > 정보)는 필수. design/icons/LICENSE-game-icons.txt 참고.
- `flutter analyze` 경고 0 유지. 기존 analysis_options.yaml 존중.
- 플랫폼 분기(Platform.isIOS 등)는 백업 공유·파일 피커 두 곳 외에는 만들지 않는다. 필요하면 먼저 질문.
- 기능 하나 끝나면 Android 에뮬레이터와 iOS 시뮬레이터 양쪽에서 실행 확인 후 보고.
