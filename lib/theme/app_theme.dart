import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPurple   = Color(0xFFA855F7);
  static const Color secondaryPurple = Color(0xFF7C3AED);

  // ─── Dark (cool dark blue-gray) ─────────────────────────────────
  static const Color darkBg      = Color(0xFF0D0F14);
  static const Color darkSurface = Color(0xFF161B26);
  static const Color darkBorder  = Color(0xFF1E2535);

  // ─── Light (Figma exact) ────────────────────────────────────────
  static const Color lightBg      = Color(0xFFF1F3F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder  = Color(0xFFE5E7EB);

  // ─── Shared ─────────────────────────────────────────────────────
  static const double _cardRadius   = 24;
  static const double _inputRadius  = 12;
  static const double _buttonRadius = 12;

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: secondaryPurple,
      surface: darkSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 1,
    ),
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: primaryPurple,
      secondary: secondaryPurple,
      surface: lightSurface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      foregroundColor: Color(0xFF141414),
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        side: BorderSide(
          color: Colors.black.withOpacity(0.08), // matches Figma #000000 at 8%
          width: 1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_inputRadius),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
    ),
  );
}