import 'package:flutter/material.dart';

class ThemeConfig {
  static bool isDark = true;
}

/// Solar-phase adaptive color palette for An-Noor.
/// Each phase maps to a gradient representing the sky at that prayer time.
class AppColors {
  AppColors._();

  // ─── Brand ────────────────────────────────────────────────────────────────
  static Color get primary => const Color(0xFF1A6B4A);
  static Color get primaryLight => const Color(0xFF2D9E70);
  static Color get primaryDark => const Color(0xFF0E4A33);
  static Color get accent =>
      ThemeConfig.isDark ? const Color(0xFFFFD166) : const Color(0xFFD69A00);
  static Color get accentDark => const Color(0xFFF5A623);

  // ─── Neutral ──────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0A0A0A);

  static Color get surface =>
      ThemeConfig.isDark ? const Color(0xFF1C1C2E) : const Color(0xFFF8F9FA);
  static Color get surfaceLight =>
      ThemeConfig.isDark ? const Color(0xFF2A2A3E) : const Color(0xFFFFFFFF);
  static Color get cardDark =>
      ThemeConfig.isDark ? const Color(0xFF16213E) : const Color(0xFFFFFFFF);
  static Color get cardLight =>
      ThemeConfig.isDark ? const Color(0xFFF5F5F5) : const Color(0xFF16213E);

  static Color get textPrimary =>
      ThemeConfig.isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111827);
  static Color get textSecondary =>
      ThemeConfig.isDark ? const Color(0xFFB0B8D1) : const Color(0xFF4B5563);
  static Color get textMuted =>
      ThemeConfig.isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

  static Color get divider =>
      ThemeConfig.isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB);

  // ─── Solar Phase Gradients ────────────────────────────────────────────────

  /// Fajr / Subuh — Deep Indigo night fading to pre-dawn purple
  static List<Color> get fajrGradient => const [
        Color(0xFF0D0D2B),
        Color(0xFF1A1A3E),
        Color(0xFF2D2B55),
      ];

  /// Sunrise / Syuruq — Warm sunrise orange to golden amber
  static List<Color> get sunriseGradient => const [
        Color(0xFF1A0A00),
        Color(0xFFFF6B35),
        Color(0xFFFFD166),
      ];

  /// Dhuhr / Zuhur — Cosmic deep ocean blue
  static List<Color> get dhuhrGradient => const [
        Color(0xFF0F2027),
        Color(0xFF203A43),
        Color(0xFF2C5364),
      ];

  /// Asr — Warm amber afternoon
  static List<Color> get asrGradient => const [
        Color(0xFF1A0F00),
        Color(0xFFF7971E),
        Color(0xFFFFD200),
      ];

  /// Maghrib — Crimson dusk
  static List<Color> get maghribGradient => const [
        Color(0xFF1A0000),
        Color(0xFF8B0000),
        Color(0xFFC0392B),
        Color(0xFFE74C3C),
      ];

  /// Isha — Midnight deep space
  static List<Color> get ishaGradient => const [
        Color(0xFF020214),
        Color(0xFF0C0C1E),
        Color(0xFF1A1A3E),
      ];

  // ─── Status Colors ────────────────────────────────────────────────────────
  static Color get success => const Color(0xFF22C55E);
  static Color get warning => const Color(0xFFF59E0B);
  static Color get error => const Color(0xFFEF4444);
  static Color get info => const Color(0xFF3B82F6);

  // ─── Glass Effect ─────────────────────────────────────────────────────────
  static Color get glassWhite =>
      ThemeConfig.isDark ? const Color(0x1AFFFFFF) : const Color(0x0A000000);
  static Color get glassBorder =>
      ThemeConfig.isDark ? const Color(0x33FFFFFF) : const Color(0x1A000000);
  static Color get glassOverlay =>
      ThemeConfig.isDark ? const Color(0x0AFFFFFF) : const Color(0x05000000);
}
