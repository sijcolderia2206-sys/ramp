import 'package:flutter/material.dart';
import 'ramp_theme.dart';

export 'ramp_theme.dart';

abstract class AppColors {
  static const Color primary = RampColors.primary;
  static const LinearGradient primaryGradient = RampColors.primaryGradient;
  static const Color white = Colors.white;
  static const Color darkSlate = RampColors.slate;
  static const Color cardBorder = RampColors.border;
  static const Color neutralTint = Color(0xFFF0F4F8);
  static const Color textMuted = RampColors.mutedText;
  static const Color lightGrayCanvas = Color(0xFFF0F4F8);
  static const Color dangerRed = RampColors.danger;
  static const Color background = RampColors.background;
  static const Color surface = RampColors.surface;
  static const Color darkBackground = RampColors.darkBackground;
  static const Color darkSurface = RampColors.darkSurface;
}
