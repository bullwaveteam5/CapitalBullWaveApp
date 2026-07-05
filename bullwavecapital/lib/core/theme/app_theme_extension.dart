import 'package:flutter/material.dart';

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
    background: Color(0xFF0A0612),
    surface: Color(0xFF16102A),
    surfaceSecondary: Color(0xFF1F1638),
    border: Color(0xFF3D2E5C),
    textPrimary: Color(0xFFFAF5FF),
    textSecondary: Color(0xFFC4B5FD),
    textMuted: Color(0xFF8B7DA8),
    shimmerBase: Color(0xFF1F1638),
    shimmerHighlight: Color(0xFF2A1F45),
  );

  static const light = AppThemeExtension(
    background: Color(0xFFFDF4FF),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF3E8FF),
    border: Color(0xFFE9D5FF),
    textPrimary: Color(0xFF1E1033),
    textSecondary: Color(0xFF5B21B6),
    textMuted: Color(0xFF7C3AED),
    shimmerBase: Color(0xFFF3E8FF),
    shimmerHighlight: Color(0xFFFDF4FF),
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
