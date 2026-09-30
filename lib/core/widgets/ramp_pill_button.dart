// lib/core/widgets/ramp_pill_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/ramp_theme.dart';
import 'clay_container.dart';

enum RampButtonStyle { primary, secondary, outline, danger }

/// Minimalist Pill Button
class RampPillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final RampButtonStyle style;
  final IconData? icon;
  final double height;
  final double? width;
  final bool isFullWidth;

  const RampPillButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style = RampButtonStyle.primary,
    this.icon,
    this.height = 52.0,
    this.width,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    if (style == RampButtonStyle.primary && isFullWidth && width == null) {
      return PrimaryPillButton(
        text: text,
        onPressed: onPressed,
        isLoading: isLoading,
        icon: icon,
        height: height,
      );
    }

    final colors = _getStyleColors();
    final bool isInteractable = !isLoading && onPressed != null;

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(colors.contentColor),
        ),
      );
    } else {
      buttonChild = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: colors.contentColor, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: colors.contentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ClayContainer(
      height: height,
      width: isFullWidth ? (width ?? double.infinity) : width,
      color: colors.backgroundColor,
      borderRadius: 50,
      depth: isInteractable ? 6.0 : 2.0,
      onTap: isInteractable ? onPressed : null,
      alignment: Alignment.center,
      child: buttonChild,
    );
  }

  _ButtonStyleColors _getStyleColors() {
    if (onPressed == null) {
      return _ButtonStyleColors(
        backgroundColor: RampColors.border,
        contentColor: RampColors.mutedText,
      );
    }

    switch (style) {
      case RampButtonStyle.primary:
        return _ButtonStyleColors(
          backgroundColor: RampColors.primary,
          contentColor: Colors.white,
        );
      case RampButtonStyle.secondary:
        return _ButtonStyleColors(
          backgroundColor: RampColors.softBlueTint,
          contentColor: RampColors.primary,
        );
      case RampButtonStyle.outline:
        return _ButtonStyleColors(
          backgroundColor: Colors.transparent,
          contentColor: RampColors.slate,
          borderColor: RampColors.border,
        );
      case RampButtonStyle.danger:
        return _ButtonStyleColors(
          backgroundColor: RampColors.danger,
          contentColor: Colors.white,
        );
    }
  }
}

class _ButtonStyleColors {
  final Color backgroundColor;
  final Color contentColor;
  final Color? borderColor;

  _ButtonStyleColors({
    required this.backgroundColor,
    required this.contentColor,
    this.borderColor,
  });
}
