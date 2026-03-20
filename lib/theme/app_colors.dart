import 'package:flutter/material.dart';

class AppColors {
  // ─── Brand ─────────────────────────────────────────────────────
  static const Color primaryPurple   = Color(0xFFA855F7);
  static const Color secondaryPurple = Color(0xFF7C3AED);

  // ─── Dark Mode (cool dark blue-gray) ───────────────────────────
  static const Color darkBg      = Color(0xFF0D0F14);
  static const Color darkSurface = Color(0xFF161B26);
  static const Color darkBorder  = Color(0xFF1E2535);
  static const Color darkText    = Color(0xFFFFFFFF);

  // ─── Light Mode (Figma exact) ──────────────────────────────────
  static const Color lightBg      = Color(0xFFF1F3F5); // page background
  static const Color lightSurface = Color(0xFFFFFFFF); // card / tile
  static const Color lightBorder  = Color(0xFFE5E7EB); // border
  static const Color lightText    = Color(0xFF141414); // primary text
  static const Color lightSubtext = Color(0xFF9AA3AD); // secondary text

  // ─── Icon tint backgrounds ──────────────────────────────────────
  static const Color iconBgDark  = Color(0xFF2A1A3E);
  static const Color iconBgLight = Color(0xFFF3E8FF);

  // ─── Neutral ───────────────────────────────────────────────────
  static const Color gray7B = Color(0xFF7B7B85);
  static const Color grayE6 = Color(0xFFE6E6EA);

  // ─── Status ────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error   = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);

  // ─── Gradients ─────────────────────────────────────────────────
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [primaryPurple, secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient glowGradient = LinearGradient(
    colors: const [
      Color(0x99B12CFF),
      Color(0x4D8D21B7),
      Color(0x00000000),
    ],
    begin: Alignment.center,
    end: Alignment.bottomCenter,
  );

  // ─── Theme-aware helpers ────────────────────────────────────────

  /// Page / scaffold background
  static Color bg(BuildContext context) =>
      _isDark(context) ? darkBg : lightBg;

  /// Card / tile surface
  static Color surface(BuildContext context) =>
      _isDark(context) ? darkSurface : lightSurface;

  /// Divider / border
  static Color border(BuildContext context) =>
      _isDark(context) ? darkBorder : lightBorder;

  /// Primary text
  static Color text(BuildContext context) =>
      _isDark(context) ? darkText : lightText;

  /// Secondary / muted text
  static Color subtext(BuildContext context) =>
      _isDark(context) ? gray7B : lightSubtext;

  /// Icon container background
  static Color iconBg(BuildContext context) =>
      _isDark(context) ? iconBgDark : iconBgLight;

  // ─── Internal ──────────────────────────────────────────────────
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}