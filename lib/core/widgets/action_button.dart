import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color? backgroundColor;
  final double size;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF0D6EFD),
    this.backgroundColor,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = isDark ? const Color(0xFF9AB4E8) : color;
    final effectiveBackground = isDark
        ? const Color(0xFF202B3D)
        : (backgroundColor ?? color.withValues(alpha: 0.1));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(size / 2),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: effectiveBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: effectiveColor,
                size: size * 0.45,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: size + 24,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
