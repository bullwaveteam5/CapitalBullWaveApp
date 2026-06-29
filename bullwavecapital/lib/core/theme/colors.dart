import 'package:flutter/material.dart';

/// WaveGo-style bold orange brand palette.
class AppColors {
  AppColors._();

  // ── Brand ──
  static const Color brandOrange = Color(0xFFE8971E);
  static const Color brandOrangeDark = Color(0xFFD17A0A);
  static const Color brandOrangeLight = Color(0xFFF2A033);
  static const Color brandPurple = Color(0xFF6B46C1);

  // ── Backgrounds ──
  static const Color background = Color(0xFF0B0F14);
  static const Color surface = Color(0xFF121826);
  static const Color surfaceSecondary = Color(0xFF1A2232);
  static const Color border = Color(0xFF263041);

  // ── Semantic ──
  static const Color green = Color(0xFF16A34A);
  static const Color greenSoft = Color(0xFF22C55E);
  static const Color greenDark = Color(0xFF15803D);
  static const Color red = Color(0xFFEF4444);
  static const Color blue = Color(0xFF3B82F6);
  static const Color yellow = Color(0xFFFACC15);
  static const Color secondary = Color(0xFF5F259F);

  // ── Text ──
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0AAB8);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF3B4252);

  // ── Aliases ──
  static const Color primary = brandOrange;
  static const Color accent = brandOrange;
  static const Color accentLight = brandOrangeLight;
  static const Color primaryLight = surfaceSecondary;
  static const Color primaryDark = background;
  static const Color card = surface;
  static const Color profit = green;
  static const Color loss = red;
  static const Color success = green;
  static const Color error = red;
  static const Color warning = yellow;
  static const Color textHint = textMuted;
  static const Color shimmerBase = surfaceSecondary;
  static const Color shimmerHighlight = border;

  static const LinearGradient heroGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8971E), Color(0xFFF2A033)],
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF141B2B), Color(0xFF0F1520)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8971E), Color(0xFFF2A033)],
  );

  static const LinearGradient chartFillGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x40E8971E), Color(0x00E8971E)],
  );

  static const LinearGradient greenGlowGradient = LinearGradient(
    colors: [Color(0x33E8971E), Color(0x00E8971E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient paytmHeaderGradient = LinearGradient(
    colors: [brandOrange, brandOrangeDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brandOrange, brandOrangeLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8971E), Color(0xFFD17A0A)],
  );
}
