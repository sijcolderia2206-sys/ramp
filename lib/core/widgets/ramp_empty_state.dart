import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/ramp_theme.dart';
import 'bouncing_interactive.dart';

/// Reusable, Polished Empty State Component for RAMP
/// Features smooth scale-and-fade entrance animations, custom tinted icon badges,
/// dark mode support, and contextual primary/secondary call-to-action buttons.
class RampEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryActionPressed;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const RampEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_rounded,
    this.iconColor,
    this.iconBackgroundColor,
    this.actionLabel,
    this.onActionPressed,
    this.secondaryActionLabel,
    this.onSecondaryActionPressed,
    this.iconSize = 42.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
  });

  /// Factory helper for search/filter empty state
  factory RampEmptyState.noSearchResults({
    required String query,
    VoidCallback? onResetFilter,
  }) {
    return RampEmptyState(
      icon: Icons.search_off_rounded,
      iconColor: RampColors.primary,
      iconBackgroundColor: RampColors.softBlueTint,
      title: 'No Matching Results',
      description: query.isNotEmpty
          ? 'No items matched "$query". Try searching for something else or clear filters.'
          : 'No items match the active filters selected.',
      actionLabel: onResetFilter != null ? 'Clear Search & Filters' : null,
      onActionPressed: onResetFilter,
    );
  }

  /// Factory helper for empty lists
  factory RampEmptyState.emptyList({
    required String title,
    required String description,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return RampEmptyState(
      title: title,
      description: description,
      icon: icon,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = iconColor ?? RampColors.primary;
    final bgTint = iconBackgroundColor ??
        (isDark
            ? primaryColor.withValues(alpha: 0.2)
            : primaryColor.withValues(alpha: 0.12));

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.92 + (0.08 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: padding,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing circular icon badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: bgTint,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.25),
                  width: 2.0,
                ),
                boxShadow: null,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : RampColors.slate,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color:
                      isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 20),
              BouncePillButton(
                text: actionLabel!,
                onPressed: onActionPressed,
                height: 46,
                backgroundColor: primaryColor,
              ),
            ],

            if (secondaryActionLabel != null &&
                onSecondaryActionPressed != null) ...[
              const SizedBox(height: 10),
              BouncingInteractive(
                onTap: onSecondaryActionPressed,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    secondaryActionLabel!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
