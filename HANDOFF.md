# 챙고 (CHAENGO) 개발 핸드오프 v0.1

Android·iOS 동시 파일럿. 이 폴더의 내용을 Flutter 프로젝트 루트(pubspec.yaml이 있는 곳)에 복사한다. 기존 README.md는 건드리지 않는다.

```
chaengo/  (pubspec.yaml 위치)
├── CLAUDE.md                 ← Claude Code가 자동으로 읽는 지침. 루트에 둔다
├── HANDOFF.md                이 파일
├── docs/
│   ├── 00_brand.md           브랜드·세계관
│   ├── 01_requirements.md    요구사항 정의서
│   └── 02_screens.md         화면 9개 사양 + 도메인 모델
└── design/
    ├── tokens.md             색·글자·형태·타일 상태 (구현 기준)
    ├── icons/                아이템 아이콘 SVG 23개 + INDEX.md + 라이선스
    └── screens/
        ├── wireframe/        S01~S09 와이어프레임 원본 (HTML)
        └── hifi/             S01·S03·S06 하이파이 + 스타일 타일 + 아이콘 시트 (HTML)
```

## Claude Code 첫 명령 예시

```
docs/와 design/tokens.md를 읽고, 도메인 모델(Item/Set/Trip)의 drift 테이블·DAO와
seed_items.json 로더부터 만들어줘. 화면은 아직 만들지 마.
```

그다음:
```
design/tokens.md 기준으로 ThemeData와 공통 위젯(ItemTile 3상태, Chip, PrimaryButton)을 만들고
widgetbook 없이 간단한 데모 페이지(lib/dev/tile_gallery.dart)로 S03 타일 상태 4종을 보여줘.
```

## 주의
- design/screens/*.dc.html은 Claude 디자인 캔버스 포맷이라 브라우저에서 단독으로 열리지 않는다. 마크업·inline style을 사양으로 읽는 용도.
- 원본 캔버스는 claude.ai 아티팩트에 계속 있으니, 디자인 수정은 거기서 하고 바뀐 부분만 tokens.md/02_screens.md에 반영한다.
