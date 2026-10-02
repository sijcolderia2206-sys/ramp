// lib/core/theme/ramp_theme.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/clay_container.dart';

/// Palette & Design Tokens for RAMP (Rental Administration Management Platform)
class RampColors {
  /// Soft neutral background canvas (#F8F9FA)
  static const Color background = Color(0xFFF8F9FA);

  /// Electric Blue Primary (#0D6EFD)
  static const Color primary = Color(0xFF0D6EFD);

  /// Slate Typography (#1A1D1E)
  static const Color slate = Color(0xFF1A1D1E);

  /// Muted Secondary Text (#73787B)
  static const Color mutedText = Color(0xFF73787B);

  /// Soft peach-coral active pill tint (#FFE8E0)
  static const Color peachPillTint = Color(0xFFFFE8E0);

  /// Soft blue tint (#E8F1FF)
  static const Color softBlueTint = Color(0xFFE8F1FF);

  /// Success (#28A745)
  static const Color success = Color(0xFF28A745);

  /// Success Tint
  static const Color successTint = Color(0xFFE8F5E9);

  /// Danger (#DC3545)
  static const Color danger = Color(0xFFDC3545);

  /// Danger Tint
  static const Color dangerTint = Color(0xFFFFEBEE);

  /// Warning / Pending Tint
  static const Color warning = Color(0xFFFFC107);
  static const Color warningTint = Color(0xFFFFF3E0);

  /// White Surface
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle Border
  static const Color border = Color(0xFFE2E8F0);
  
  /// Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  /// Primary Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D6EFD), Color(0xFF0056B3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass / Frosted Overlay
  static const Color glassBackground = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}

/// Theme configuration using Google Fonts Poppins with flat minimalist defaults
class RampTheme {
  /// Flat shadowless configuration for cards
  static const List<BoxShadow> flatShadows = [];

  static const BoxShadow softShadow = BoxShadow(
    color: Colors.transparent,
    blurRadius: 0,
    offset: Offset.zero,
  );

  /// Standard 20px card border radius
  static final BorderRadius borderRadius20 = BorderRadius.circular(20);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: RampColors.background,
      colorScheme: const ColorScheme.light(
        primary: RampColors.primary,
        onPrimary: Colors.white,
        secondary: RampColors.softBlueTint,
        onSecondary: RampColors.primary,
        surface: RampColors.surface,
        onSurface: RampColors.slate,
        error: RampColors.danger,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: RampColors.slate,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: RampColors.slate,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.poppins(
          color: RampColors.slate,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.poppins(
          color: RampColors.slate,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: RampColors.slate,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: RampColors.mutedText,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.poppins(
          color: RampColors.slate,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: RampColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: RampColors.slate),
        titleTextStyle: GoogleFonts.poppins(
          color: RampColors.slate,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RampColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: RampColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RampColors.primary,
          side: const BorderSide(color: RampColors.border, width: 1.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: RampColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: RampColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RampColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, 40),
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const background = Color(0xFF101112);
    const surface = Color(0xFF181A1C);
    const elevated = Color(0xFF222527);
    const text = Color(0xFFF5F5F5);
    const muted = Color(0xFFADB5BD);
    const outline = Color(0xFF34383C);
    const primary = Color(0xFF7896CC);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Color(0xFF111518),
        secondary: elevated,
        onSecondary: text,
        surface: surface,
        onSurface: text,
        surfaceContainerHighest: elevated,
        onSurfaceVariant: muted,
        outline: outline,
        outlineVariant: Color(0xFF292D31),
        error: Color(0xFFE58A8A),
        onError: Color(0xFF211516),
      ),
      textTheme:
          GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          color: text,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: text,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.poppins(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.poppins(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: text,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: const Color(0xFF94A3B8),
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.poppins(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: muted),
        titleTextStyle: GoogleFonts.poppins(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF111518),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: outline, width: 1.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF111518),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, 40),
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: outline),
    );
  }
}

/// 1. RampCard: Flat minimalist card container with tactile touch
class RampCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;

  const RampCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.onTap,
    this.backgroundColor = RampColors.surface,
    this.borderColor = RampColors.border,
    this.borderRadius = 20.0,
    this.width,
    this.height,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = isDark
        ? _darkSurfaceColor(backgroundColor)
        : (backgroundColor != RampColors.surface
            ? backgroundColor
            : RampColors.surface);

    return ClayContainer(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      color: effectiveBg,
      borderRadius: borderRadius,
      depth: 6.0,
      onTap: onTap,
      child: child,
    );
  }

  Color _darkSurfaceColor(Color color) {
    if (color == RampColors.surface) return const Color(0xFF181A1C);
    if (color == RampColors.softBlueTint) return const Color(0xFF202B3D);
    if (color == RampColors.successTint) return const Color(0xFF1E3028);
    if (color == RampColors.warningTint || color == RampColors.peachPillTint) {
      return const Color(0xFF342B1D);
    }
    if (color == RampColors.dangerTint) return const Color(0xFF351F22);
    if (color == RampColors.background) return const Color(0xFF101112);
    return color;
  }
}

/// 2. StatusPill: Minimalist pill badge displaying status strings
class StatusPill extends StatelessWidget {
  final String status;
  final Color? customTextColor;
  final Color? customBackgroundColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusPill({
    super.key,
    required this.status,
    this.customTextColor,
    this.customBackgroundColor,
    this.fontSize = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final styleConfig = _resolveStyleConfig(status, isDark);
    final textColor = customTextColor ?? styleConfig.textColor;
    final backgroundColor =
        customBackgroundColor ?? styleConfig.backgroundColor;

    return ClayContainer(
      padding: padding,
      color: backgroundColor,
      borderRadius: 50,
      depth: 4.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _PillConfig _resolveStyleConfig(String label, bool isDark) {
    final lower = label.trim().toLowerCase();

    if (lower == 'occupied') {
      return _PillConfig(
        textColor: isDark ? const Color(0xFF9AB4E8) : RampColors.primary,
        backgroundColor:
            isDark ? const Color(0xFF202B3D) : RampColors.softBlueTint,
      );
    } else if (lower == 'vacant') {
      return _PillConfig(
        textColor: isDark ? const Color(0xFF8CC9A8) : RampColors.success,
        backgroundColor:
            isDark ? const Color(0xFF1E3028) : RampColors.successTint,
      );
    } else if (lower == 'paid' || lower == 'verified' || lower == 'resolved') {
      return _PillConfig(
        textColor: isDark ? const Color(0xFF8CC9A8) : RampColors.success,
        backgroundColor:
            isDark ? const Color(0xFF1E3028) : RampColors.successTint,
      );
    } else if (lower == 'pending' ||
        lower == 'pending review' ||
        lower == 'in progress' ||
        lower == 'upcoming') {
      return _PillConfig(
        textColor: isDark ? const Color(0xFFD5B477) : const Color(0xFFD97706),
        backgroundColor:
            isDark ? const Color(0xFF342B1D) : RampColors.peachPillTint,
      );
    } else if (lower == 'declined' ||
        lower == 'high' ||
        lower == 'emergency' ||
        lower == 'overdue') {
      return _PillConfig(
        textColor: isDark ? const Color(0xFFE59A9D) : RampColors.danger,
        backgroundColor:
            isDark ? const Color(0xFF351F22) : RampColors.dangerTint,
      );
    }

    return _PillConfig(
      textColor: isDark ? const Color(0xFF9AB4E8) : RampColors.slate,
      backgroundColor:
          isDark ? const Color(0xFF202B3D) : RampColors.softBlueTint,
    );
  }
}

class _PillConfig {
  final Color textColor;
  final Color backgroundColor;

  const _PillConfig({
    required this.textColor,
    required this.backgroundColor,
  });
}

/// 3. PrimaryPillButton: 52px tall rounded flat button with active squishy tap feedback
class PrimaryPillButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final bool enabled;

  const PrimaryPillButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 52.0,
    this.backgroundColor,
    this.textColor,
    this.enabled = true,
  });

  @override
  State<PrimaryPillButton> createState() => _PrimaryPillButtonState();
}

class _PrimaryPillButtonState extends State<PrimaryPillButton> {
  @override
  Widget build(BuildContext context) {
    final bool isInteractable =
        widget.enabled && !widget.isLoading && widget.onPressed != null;
    final bg = isInteractable
        ? (widget.backgroundColor ?? RampColors.primary)
        : RampColors.border;
    final fg = isInteractable
        ? (widget.textColor ?? Colors.white)
        : RampColors.mutedText;

    Widget childWidget;
    if (widget.isLoading) {
      childWidget = SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else {
      childWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: fg, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: fg,
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
      height: widget.height,
      width: double.infinity,
      color: bg,
      borderRadius: widget.height / 2,
      depth: isInteractable ? 8.0 : 2.0,
      onTap: isInteractable
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            }
          : null,
      alignment: Alignment.center,
      child: childWidget,
    );
  }
}

/// 4. RampIconButton: Flat minimalist circular action button with built-in HapticFeedback
class RampIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;
  final Border? border;
  final bool isFrosted;

  const RampIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44.0,
    this.iconSize = 20.0,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
    this.border,
    this.isFrosted = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBg =
        isFrosted ? RampColors.glassBackground : RampColors.surface;
    final defaultColor = iconColor ?? RampColors.slate;

    Widget button = ClayContainer(
      width: size,
      height: size,
      color: backgroundColor ?? defaultBg,
      borderRadius: size / 2,
      depth: 5.0,
      onTap: onPressed != null
          ? () {
              HapticFeedback.lightImpact();
              onPressed!();
            }
          : null,
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: onPressed != null ? defaultColor : RampColors.mutedText,
      ),
    );

    if (isFrosted) {
      button = ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: button,
        ),
      );
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// 5. CircleActionButton: Flat quick action button with tinted icon background and Poppins label
class CircleActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color? backgroundColor;
  final double size;

  const CircleActionButton({
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
    final bg = backgroundColor ?? color.withValues(alpha: 0.12);
    final effectiveColor = isDark ? const Color(0xFF9AB4E8) : color;
    final effectiveBackground = isDark ? const Color(0xFF202B3D) : bg;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClayContainer(
            width: size,
            height: size,
            color: effectiveBackground,
            borderRadius: size / 2,
            depth: 6.0,
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: effectiveColor,
              size: size * 0.46,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
