import 'package:flutter/widgets.dart';

import '../app/theme/tokens.dart';

/// 높이 6, radius 3 진행바.
/// - 기본: S03 헤더(트랙 line, 채움 done).
/// - [ProgressBar.onDark]: S01 검은 카드(트랙 cardDarkLine, 채움 doneOnDark).
///
/// 원본의 밝은 트랙 #EDEDEA는 토큰에 없어 line으로 대체.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value})
    : _track = AppColors.line,
      _fill = AppColors.done;

  const ProgressBar.onDark({super.key, required this.value})
    : _track = AppColors.cardDarkLine,
      _fill = AppColors.doneOnDark;

  /// 0.0 ~ 1.0.
  final double value;
  final Color _track;
  final Color _fill;

  static const _height = 6.0;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_height / 2);
    return Container(
      height: _height,
      decoration: BoxDecoration(color: _track, borderRadius: radius),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(color: _fill, borderRadius: radius),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
