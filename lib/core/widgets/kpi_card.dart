// lib/core/widgets/kpi_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clay_container.dart';

/// Modern flat minimal KPI Card component for RAMP Dashboard.
/// Features 20px rounded corners, subtle flat aesthetics, Poppins typography,
/// and a flat icon badge.
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;
  final Color backgroundColor;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor = const Color(0xFF0D6EFD),
    this.iconBackgroundColor = const Color(0xFFE8F1FF),
    this.onTap,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBackground =
        isDark ? _darkTint(iconBackgroundColor) : iconBackgroundColor;
    final iconForeground = isDark ? _darkAccent(iconColor) : iconColor;
    final effectiveBg = backgroundColor == Colors.white
        ? Theme.of(context).colorScheme.surface
        : backgroundColor;

    return ClayContainer(
      color: effectiveBg,
      borderRadius: 20,
      depth: 6.0,
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      child: Column( crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon with minimalist circular badge
              ClayContainer(
                width: 44,
                height: 44,
                color: iconBackground,
                borderRadius: 22,
                depth: 4.0,
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: iconForeground,
                  size: 22,
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                softWrap: true,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
                softWrap: true,
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _darkTint(Color color) {
    if (color == const Color(0xFFE6F4EA)) return const Color(0xFF1E3028);
    if (color == const Color(0xFFE8F1FF)) return const Color(0xFF202B3D);
    if (color == const Color(0xFFF3E8FF)) return const Color(0xFF2D2638);
    if (color == const Color(0xFFFEF3C7)) return const Color(0xFF342B1D);
    return const Color(0xFF25292D);
  }

  Color _darkAccent(Color color) {
    if (color == const Color(0xFF10B981)) return const Color(0xFF8CC9A8);
    if (color == const Color(0xFF0D6EFD)) return const Color(0xFF9AB4E8);
    if (color == const Color(0xFF8B5CF6)) return const Color(0xFFB6A1D8);
    if (color == const Color(0xFFF59E0B)) return const Color(0xFFD5B477);
    return const Color(0xFF9AB4E8);
  }
}
