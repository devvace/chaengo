import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// assets/icons/{key}.svg를 tint해서 그린다. 아이콘 파일 자체는 #111111 단색이며
/// 색은 항상 colorFilter로만 바꾼다.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.iconKey, {
    super.key,
    required this.size,
    required this.color,
  });

  final String iconKey;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$iconKey.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
