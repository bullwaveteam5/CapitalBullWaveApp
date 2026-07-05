import 'package:flutter/material.dart';

/// BullWave — rich purple & pink fintech palette with teal complementary accents.
class AppColors {
  AppColors._();

  // ── Brand (purple → pink spectrum) ──
  static const Color brandPrimary = Color(0xFF9333EA);
  static const Color brandPrimaryDark = Color(0xFF7E22CE);
  static const Color brandPrimaryLight = Color(0xFFA855F7);
  static const Color brandPink = Color(0xFFEC4899);
  static const Color brandPinkLight = Color(0xFFF472B6);
  static const Color brandMagenta = Color(0xFFD946EF);

  // Aliases — existing code references these across the app
  static const Color brandOrange = brandPrimary;
  static const Color brandOrangeDark = brandPrimaryDark;
  static const Color brandOrangeLight = brandPink;
  static const Color brandPurple = brandPrimaryLight;
  static const Color brandGold = Color(0xFFFBBF24);

  // Complementary accent (teal — contrasts beautifully with purple/pink)
  static const Color brandTeal = Color(0xFF2DD4BF);
  static const Color brandCyan = Color(0xFF22D3EE);

  // ── Surfaces (deep violet-tinted darks) ──
  static const Color background = Color(0xFF0A0612);
  static const Color backgroundElevated = Color(0xFF100818);
  static const Color surface = Color(0xFF16102A);
  static const Color surfaceSecondary = Color(0xFF1F1638);
  static const Color surfaceHighlight = Color(0xFF2A1F45);
  static const Color border = Color(0xFF3D2E5C);
  static const Color borderSubtle = Color(0xFF251A3D);

  // ── Semantic ──
  static const Color green = Color(0xFF34D399);
  static const Color greenSoft = Color(0xFF6EE7B7);
  static const Color greenDark = Color(0xFF10B981);
  static const Color red = Color(0xFFFB7185);
  static const Color blue = Color(0xFF38BDF8);
  static const Color yellow = Color(0xFFFACC15);
  static const Color secondary = Color(0xFF818CF8);

  // ── Commodity categories ──
  static const Color commodityGold = Color(0xFFFBBF24);
  static const Color commoditySilver = Color(0xFFCBD5E1);
  static const Color commodityEnergy = Color(0xFFFB923C);
  static const Color commodityMetal = Color(0xFF2DD4BF);

  // ── Text ──
  static const Color textPrimary = Color(0xFFFAF5FF);
  static const Color textSecondary = Color(0xFFC4B5FD);
  static const Color textMuted = Color(0xFF8B7DA8);
  static const Color textDisabled = Color(0xFF5B4D78);

  // ── Aliases ──
  static const Color primary = brandPrimary;
  static const Color accent = brandPink;
  static const Color accentLight = brandPinkLight;
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
  static const Color shimmerHighlight = surfaceHighlight;

  static const LinearGradient heroGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F1638), Color(0xFF0A0612)],
  );

  static const LinearGradient screenBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF120A1E), Color(0xFF0A0612), Color(0xFF0D0818)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandPrimary, brandPink],
  );

  static const LinearGradient pinkPurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFDB2777), Color(0xFFEC4899)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient onboardingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4C1D95), Color(0xFF9333EA), Color(0xFFDB2777)],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient commodityHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F1638), Color(0xFF16102A)],
  );

  static const LinearGradient chartFillGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x409333EA), Color(0x009333EA)],
  );

  static const LinearGradient greenGlowGradient = LinearGradient(
    colors: [Color(0x332DD4BF), Color(0x002DD4BF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient paytmHeaderGradient = accentGradient;

  static const LinearGradient primaryGradient = accentGradient;

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E0A3C), Color(0xFF581C87), Color(0xFF9D174D)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient navGlow = LinearGradient(
    colors: [Color(0x339333EA), Color(0x00EC4899)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
