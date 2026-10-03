import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';

/// 둥근 사각형 점선 테두리. S03 제외 타일과 S06 안 담김 타일이 쓴다.
class DashedRRectBorder extends StatelessWidget {
  const DashedRRectBorder({
    super.key,
    required this.color,
    required this.strokeWidth,
    required this.radius,
    this.dash = 4,
    this.gap = 3,
    this.child,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dash;
  final double gap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(
        color: color,
        strokeWidth: strokeWidth,
        radius: radius,
        dash: dash,
        gap: gap,
      ),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    // 선이 박스 안쪽에 오도록 반 두께만큼 들인다(실선 테두리와 같은 위치).
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius - inset)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius ||
      old.dash != dash ||
      old.gap != gap;
}
