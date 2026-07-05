import 'package:flutter/material.dart';
import 'colors.dart';
import 'app_theme_extension.dart';

class AppDecorations {
  AppDecorations._();

  static BoxDecoration heroCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.appColors;

    return BoxDecoration(
      color: isDark ? null : c.surface,
      gradient: isDark
          ? AppColors.heroGradientDark
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.brandPrimary.withValues(alpha: 0.12),
                c.surface,
              ],
            ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? c.border : AppColors.brandPrimary.withValues(alpha: 0.18),
        width: 1,
      ),
      boxShadow: isDark
          ? []
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  static BoxDecoration iconBadge(Color color) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
    );
  }

  static BoxDecoration card(
    BuildContext context, {
    Color? color,
    bool glow = false,
    Color? glowColor,
    bool premium = false,
  }) {
    final c = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: color ?? c.surface,
      borderRadius: BorderRadius.circular(premium ? 18 : 14),
      border: Border.all(
        color: premium
            ? (glowColor ?? AppColors.brandPrimary).withValues(alpha: isDark ? 0.28 : 0.18)
            : c.border.withValues(alpha: isDark ? 0.85 : 0.7),
      ),
      boxShadow: glow
          ? [
              BoxShadow(
                color: (glowColor ?? AppColors.brandPink).withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ]
          : isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
    );
  }

  static BoxDecoration premiumTile(BuildContext context, {required Color accent}) {
    final c = context.appColors;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: 0.14),
          c.surface,
        ],
      ),
      border: Border.all(color: accent.withValues(alpha: 0.25)),
    );
  }

  static BoxDecoration glassCard(BuildContext context) {
    final c = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: c.surface.withValues(alpha: isDark ? 0.95 : 0.98),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: c.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static InputDecoration pillSearch(BuildContext context, {String? hint}) {
    final c = context.appColors;
    return InputDecoration(
      hintText: hint ?? 'Search',
      hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIcon: Icon(Icons.search_rounded, color: c.textMuted, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
      ),
    );
  }
}
