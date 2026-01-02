import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/warmup.dart';

class AppTheme {
  // Colors from the HTML design
  static const Color primaryColor = Color(0xFF00E5FF); // Neon Cyan
  static const Color backgroundDark = Color(0xFF1E1E2C); // Deep Dark Blue/Black
  static const Color backgroundLight = Color(0xFFF5F8F8); // Light background
  static const Color cardDark = Color(0xFF2D2D44); // Card background in dark mode
  static const Color cardDarkHover = Color(0xFF363652); // Card hover in dark mode

  // Difficulty colors
  static const Color beginnerColor = Color(0xFF34D399); // emerald-400
  static const Color intermediateColor = Color(0xFFFB923C); // orange-400
  static const Color advancedColor = Color(0xFFF43F5E); // rose-500

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        background: backgroundDark,
        surface: cardDark,
        onPrimary: backgroundDark,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark.withOpacity(0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.lexendTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        background: backgroundLight,
        surface: Colors.white,
        onPrimary: backgroundDark,
        onBackground: const Color(0xFF1F2937),
        onSurface: const Color(0xFF1F2937),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight.withOpacity(0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static Color getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return beginnerColor;
      case Difficulty.intermediate:
        return intermediateColor;
      case Difficulty.advanced:
        return advancedColor;
    }
  }

  static BoxShadow getDifficultyShadow(Difficulty difficulty) {
    final color = getDifficultyColor(difficulty);
    return BoxShadow(
      color: color.withOpacity(0.6),
      blurRadius: 8,
      spreadRadius: 0,
    );
  }

  static BoxShadow getNeonShadow() {
    return BoxShadow(
      color: primaryColor.withOpacity(0.4),
      blurRadius: 12,
      spreadRadius: 0,
    );
  }
}

