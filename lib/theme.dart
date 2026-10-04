// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// RAMP (Rental Administration and Maintenance Platform) Theme
/// Premium Fintech Aesthetic
class RampTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF0052CC); // Primary brand blue for active states
  static const Color scaffoldBackground = Color(0xFFF8F9FA); // Off-white scaffold background
  static const Color cardBackground = Colors.white; // Pure white cards
  
  // Neutral Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color dividerColor = Color(0xFFE5E7EB);
  
  // Status Colors (for SLA Maintenance Engine / Billing)
  static const Color errorRed = Color(0xFFDC2626); // Emergency severity / Overdue
  static const Color warningYellow = Color(0xFFD97706); // Medium severity / Late
  static const Color successGreen = Color(0xFF16A34A); // Low severity / Paid

  // Spacing & Grid (8-point grid system)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // Standardized Card Shadow
  static List<BoxShadow> get standardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  // Global Material 3 ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: scaffoldBackground,
        error: errorRed,
      ),
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.normal),
        bodyMedium: GoogleFonts.inter(color: textSecondary, fontWeight: FontWeight.normal),
        bodySmall: GoogleFonts.inter(color: textSecondary, fontWeight: FontWeight.normal),
        labelLarge: GoogleFonts.inter(color: primaryBlue, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Removing harsh borders as per guidelines
          side: BorderSide.none, 
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryBlue,
        unselectedLabelColor: textSecondary,
        indicatorColor: primaryBlue,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
        dividerColor: dividerColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed),
        ),
        hintStyle: GoogleFonts.inter(color: textSecondary),
      ),
      iconTheme: const IconThemeData(
        color: primaryBlue,
        size: 24,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: const Color(0xFF121212),
        error: errorRed,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }
}

