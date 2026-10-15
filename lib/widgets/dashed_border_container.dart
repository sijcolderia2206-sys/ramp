// lib/widgets/dashed_border_container.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'neumorphic_widgets.dart';

/// Inset Neumorphic Container with Dashed Border for Upload Areas
class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double height;

  const DashedBorderContainer({
    super.key,
    required this.child,
    required this.onTap,
    this.height = 140.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        isInset: true,
        borderRadius: 16.0,
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: RampTheme.primaryBlue.withValues(alpha: 0.5),
            strokeWidth: 1.5,
            dashWidth: 6.0,
            dashSpace: 4.0,
            borderRadius: 16.0,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
