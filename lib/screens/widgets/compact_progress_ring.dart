// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/screens/widgets/compact_progress_ring.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/ramp_theme.dart';

/// Standardized data visualization component for RAMP Dashboards.
/// Strict dimensions: 80 pixels diameter, stroke width 8.
class CompactProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String centerText;
  final String label;

  const CompactProgressRing({
    super.key,
    required this.progress,
    required this.centerText,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                color: RampTheme.dividerColor,
              ),
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                color: RampTheme.primaryBlue,
                backgroundColor: Colors.transparent,
              ),
              Center(
                child: Text(
                  centerText,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: RampTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RampTheme.spacing8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: RampTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
