import 'package:flutter/material.dart';
import 'ramp_theme.dart';

export 'ramp_theme.dart';

abstract class AppColors {
  static const Color primary = RampColors.primary;
  static const Color white = Colors.white;
  static const Color darkSlate = RampColors.slate;
  static const Color cardBorder = RampColors.border;
  static const Color neutralTint = Color(0xFFF8FAFC);
  static const Color textMuted = RampColors.mutedText;
  static const Color lightGrayCanvas = Color(0xFFF8FAFC);
  static const Color dangerRed = RampColors.danger;
  static const Color background = RampColors.background;
  static const Color surface = RampColors.surface;
}
