import 'package:flutter/material.dart';
import 'colors.dart';

/// Theme-aware palette — use via `context.appColors` instead of static [AppColors]
/// for surfaces and text that must adapt in light/dark mode.
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppThemeExtension({
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  static const dark = AppThemeExtension(
    background: Color(0xFF0A0C10),
    surface: Color(0xFF131820),
    surfaceSecondary: Color(0xFF1C2330),
    border: Color(0xFF2A3344),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    shimmerBase: Color(0xFF1C2330),
    shimmerHighlight: Color(0xFF2A3344),
  );

  static const light = AppThemeExtension(
    background: Color(0xFFF5F5F7),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFEFEFF4),
    border: Color(0xFFD1D1D6),
    textPrimary: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF3A3A3C),
    textMuted: Color(0xFF636366),
    shimmerBase: Color(0xFFE5E5EA),
    shimmerHighlight: Color(0xFFF5F5F7),
  );

  @override
  AppThemeExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSecondary,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppThemeExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeExtension get appColors =>
      Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.dark;
}

extension AppThemeState on ThemeData {
  AppThemeExtension get appColors =>
      extension<AppThemeExtension>() ?? AppThemeExtension.dark;
}
