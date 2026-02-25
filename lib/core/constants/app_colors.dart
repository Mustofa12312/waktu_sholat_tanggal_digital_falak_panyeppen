import 'package:flutter/material.dart';

/// Solar-phase adaptive color palette for An-Noor.
/// Each phase maps to a gradient representing the sky at that prayer time.
class AppColors {
  AppColors._();

  // ─── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A6B4A);
  static const Color primaryLight = Color(0xFF2D9E70);
  static const Color primaryDark = Color(0xFF0E4A33);
  static const Color accent = Color(0xFFFFD166);
  static const Color accentDark = Color(0xFFF5A623);

  // ─── Neutral ──────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1C1C2E);
  static const Color surfaceLight = Color(0xFF2A2A3E);
  static const Color cardDark = Color(0xFF16213E);
  static const Color cardLight = Color(0xFFF5F5F5);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D1);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color divider = Color(0xFF2D3748);

  // ─── Solar Phase Gradients ────────────────────────────────────────────────

  /// Fajr / Subuh — Deep Indigo night fading to pre-dawn purple
  static const List<Color> fajrGradient = [
    Color(0xFF0D0D2B),
    Color(0xFF1A1A3E),
    Color(0xFF2D2B55),
  ];

  /// Sunrise / Syuruq — Warm sunrise orange to golden amber
  static const List<Color> sunriseGradient = [
    Color(0xFF1A0A00),
    Color(0xFFFF6B35),
    Color(0xFFFFD166),
  ];

  /// Dhuhr / Zuhur — Cosmic deep ocean blue
  static const List<Color> dhuhrGradient = [
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ];

  /// Asr — Warm amber afternoon
  static const List<Color> asrGradient = [
    Color(0xFF1A0F00),
    Color(0xFFF7971E),
    Color(0xFFFFD200),
  ];

  /// Maghrib — Crimson dusk
  static const List<Color> maghribGradient = [
    Color(0xFF1A0000),
    Color(0xFF8B0000),
    Color(0xFFC0392B),
    Color(0xFFE74C3C),
  ];

  /// Isha — Midnight deep space
  static const List<Color> ishaGradient = [
    Color(0xFF020214),
    Color(0xFF0C0C1E),
    Color(0xFF1A1A3E),
  ];

  // ─── Status Colors ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Glass Effect ─────────────────────────────────────────────────────────
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassOverlay = Color(0x0AFFFFFF);
}
