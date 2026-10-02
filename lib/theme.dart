import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
export 'core/theme/ramp_theme.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF0284C7);
  static const Color background = Color(0xFFF0F4F8); // Off-white canvas
  static const Color card = Color(0xFFFFFFFF); // Pure white cards
  static const Color text = Color(0xFF1E293B);

  // Soft Blue to Cyan Linear Gradient for Active Accents & Active Icons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF38BDF8), // Soft Cyan
      Color(0xFF2563EB), // Soft Blue
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Minimalist Flat Card Shadow (Disabled for Shadowless Design)
  static const List<BoxShadow> softFloatingShadow = [];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      chipTheme: ChipThemeData(
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        selectedColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        surface: card,
        onSurface: text,
        onSurfaceVariant: Color(0xFF64748B),
        outline: Color(0xFFCBD5E1),
        outlineVariant: Color(0xFFE2E8F0),
        error: Color(0xFFB4232F),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: text,
        displayColor: text,
      ),
      // Cards in light mode: 22px border radius + flat border (no drop shadow)
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: text, size: 24),
        titleTextStyle: GoogleFonts.poppins(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: text, size: 24),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      // All Buttons: Border Radius 22px
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE2E8F0)),
    );
  }

  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF141619); // Charcoal (#141619)
    const darkSurface = Color(0xFF23272E); // Dark Grey (#23272E)
    const darkElevated = Color(0xFF2D323A);
    const darkPrimary = Color(0xFF38BDF8);
    const darkText = Color(0xFFF8FAFC);
    const darkMutedText = Color(0xFF94A3B8);
    const darkOutline = Color(0xFF334155);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      chipTheme: ChipThemeData(
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        selectedColor: darkPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        side: const BorderSide(color: darkOutline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: const Color(0xFF111518),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      primaryColor: primary,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: Color(0xFF111518),
        surface: darkSurface,
        onSurface: darkText,
        surfaceContainerHighest: darkElevated,
        outline: darkOutline,
        outlineVariant: Color(0xFF292D31),
        onSurfaceVariant: darkMutedText,
        error: Color(0xFFE58A8A),
        onError: Color(0xFF211516),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),
      // Cards in dark mode: No drop shadow (elevation: 0), faint border instead
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(
              color: darkOutline, width: 1.0), // Faint border in dark mode
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: darkText, size: 24),
        titleTextStyle: GoogleFonts.poppins(
          color: darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: darkMutedText, size: 24),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      // All Buttons in Dark Mode: Border Radius 22px
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: const Color(0xFF111518),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkOutline, width: 1.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: const Color(0xFF111518),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, 40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.center,
          textStyle: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(color: darkOutline),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: darkOutline, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: darkOutline, width: 1.0),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: darkElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkOutline, width: 1.0),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkOutline, width: 1.0),
        ),
        contentTextStyle: const TextStyle(color: darkText),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: darkMutedText,
        textColor: darkText,
        tileColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : darkMutedText,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? darkPrimary : darkOutline,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? darkPrimary : darkOutline,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? primary : darkMutedText,
        ),
      ),
    );
  }
}

/// Helper Widget to render Active Outlined Icons using the Primary Blue Gradient
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient gradient;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.gradient = AppTheme.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => gradient.createShader(bounds),
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );
  }
}
