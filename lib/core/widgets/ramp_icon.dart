// lib/core/widgets/ramp_icon.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Standardized Icon Component rendering custom Flaticon SVG assets
/// with fallback to Material Icon if SVG asset loading fails.
class RampIcon extends StatelessWidget {
  final String assetName;
  final double size;
  final Color? color;
  final IconData? fallbackIcon;

  const RampIcon({
    super.key,
    required this.assetName,
    this.size = 24.0,
    this.color,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final String path = assetName.startsWith('assets/icons/')
        ? assetName
        : 'assets/icons/$assetName${assetName.endsWith('.svg') ? '' : '.svg'}';

    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          fallbackIcon ?? Icons.widgets_rounded,
          size: size,
          color: effectiveColor,
        );
      },
    );
  }
}
