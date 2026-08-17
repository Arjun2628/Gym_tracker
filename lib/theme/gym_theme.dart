import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GymColors {
  static const Color background = Color(0xFF0D0F12);
  static const Color surface = Color(0xFF14181F);
  static const Color surfaceLight = Color(0xFF1C222B);
  static const Color surfaceBorder = Color(0xFF28313E);
  static const Color cardBg = Color(0xFF14181F);
  static const Color cardBorder = Color(0xFF28313E);

  // Neon Accents
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonRed = Color(0xFFFF1744);
  static const Color neonAmber = Color(0xFFFFB300);
  static const Color neonPurple = Color(0xFFD500F9);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

class GymTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GymColors.background,
      primaryColor: GymColors.neonGreen,
      colorScheme: const ColorScheme.dark(
        primary: GymColors.neonGreen,
        secondary: GymColors.neonCyan,
        surface: GymColors.surface,
        error: GymColors.neonRed,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: GymColors.textPrimary,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.0,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: GymColors.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: GymColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: GymColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: GymColors.textPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: GymColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: GymColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: GymColors.surfaceBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GymColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GymColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GymColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GymColors.neonCyan, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GymColors.neonGreen,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
