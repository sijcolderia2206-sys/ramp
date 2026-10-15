// lib/widgets/ramp_empty_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Reusable Custom Empty State component for RAMP lists, search results, & feeds
class RampEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryActionPressed;
  final bool isCompact;

  const RampEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
    this.secondaryActionLabel,
    this.onSecondaryActionPressed,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16.0 : 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isCompact ? 16 : 24),
              decoration: BoxDecoration(
                color: RampTheme.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: RampTheme.primaryBlue.withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: isCompact ? 36 : 52,
                color: RampTheme.primaryBlue,
              ),
            ),
            SizedBox(height: isCompact ? 12 : 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isCompact ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: RampTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isCompact ? 12 : 14,
                  color: RampTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              SizedBox(height: isCompact ? 16 : 24),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RampTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            if (secondaryActionLabel != null && onSecondaryActionPressed != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onSecondaryActionPressed,
                child: Text(secondaryActionLabel!),
              ),
            ],
          ],
        )
            .animate()
            .scale(duration: 300.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 250.ms),
      ),
    );
  }
}
