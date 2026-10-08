// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/screens/widgets/empty_state_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/ramp_theme.dart';

/// Beautiful empty/error states to ensure a screen is never left blank.
class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final String? iconAssetName; // e.g., 'assets/icons/empty_state.svg'
  final VoidCallback? onAction;
  final String actionLabel;

  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    this.iconAssetName,
    this.onAction,
    this.actionLabel = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RampTheme.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconAssetName != null) ...[
              SvgPicture.asset(
                iconAssetName!,
                width: 120,
                height: 120,
                colorFilter: const ColorFilter.mode(RampTheme.dividerColor, BlendMode.srcIn),
              ),
              const SizedBox(height: RampTheme.spacing24),
            ],
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: RampTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RampTheme.spacing8),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: RampTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: RampTheme.spacing24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
