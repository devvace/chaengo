import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// design/tokens.md "글자" 표. 숫자는 예외 없이 [AppText.mono] 계열을 쓴다.
abstract final class AppFonts {
  static const sans = 'IBMPlexSansKR';
  static const mono = 'IBMPlexMono';
}

abstract final class AppText {
  static const _sans = TextStyle(
    fontFamily: AppFonts.sans,
    color: AppColors.ink,
    height: 1.4,
  );
  static const _mono = TextStyle(
    fontFamily: AppFonts.mono,
    color: AppColors.ink,
    height: 1.2,
  );

  /// 워드마크 "챙고".
  static final wordmark = _sans.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: 26 * -0.02,
    height: 1.2,
  );
  static final wordmarkSub = _mono.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.inkMute,
  );

  static final screenTitle = _sans.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 22 * -0.02,
    height: 1.3,
  );
  static final appBarTitle = _sans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static final cardTitle = _sans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static final body = _sans.copyWith(fontSize: 15, fontWeight: FontWeight.w400);
  static final categoryHeader = _sans.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static final tileLabel = _sans.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  static final tileLabelStrong = tileLabel.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final caption = _sans.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.inkSub,
  );
  static final sectionLabel = _sans.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.inkSub,
    letterSpacing: 13 * 0.02,
  );
  static final button = _sans.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  static final chip = _sans.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
  static final chipSelected = chip.copyWith(fontWeight: FontWeight.w600);
  static final tabLabel = _sans.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
  static final tabLabelSelected = tabLabel.copyWith(
    fontWeight: FontWeight.w600,
  );

  // ── 숫자(Mono) ──

  /// 홈 카드 큰 숫자와 분모.
  static final bigNumber = _mono.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    letterSpacing: 40 * -0.03,
    height: 1.0,
  );
  static final bigNumberDenominator = _mono.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.inkMute,
    letterSpacing: 22 * -0.03,
    height: 1.0,
  );

  /// 체크 화면 진행 숫자와 분모.
  static final progressNumber = _mono.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.w600,
    letterSpacing: 34 * -0.03,
    height: 1.0,
  );
  static final progressDenominator = _mono.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.inkMute,
    height: 1.0,
  );

  /// S06 "n개 담김"의 n.
  static final countNumber = _mono.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  static final qtyBadge = _mono.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  /// 카테고리 헤더·리스트 행 등 본문 크기에 섞이는 숫자.
  static final monoSmall = _mono.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.inkSub,
  );
  static final monoLabel = _mono.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.inkMute,
  );
}

/// 문장 속 숫자만 Mono로 바꾼다("기본 수량 12 · 세트 4곳").
/// tokens.md: 숫자는 예외 없이 Mono.
TextSpan withMonoDigits(String text, TextStyle style) {
  final mono = style.copyWith(fontFamily: AppFonts.mono);
  final spans = <TextSpan>[];
  text.splitMapJoin(
    RegExp(r'[0-9]+'),
    onMatch: (m) {
      spans.add(TextSpan(text: m[0], style: mono));
      return '';
    },
    onNonMatch: (s) {
      if (s.isNotEmpty) spans.add(TextSpan(text: s, style: style));
      return '';
    },
  );
  return TextSpan(children: spans);
}
