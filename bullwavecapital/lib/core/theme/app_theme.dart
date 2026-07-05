import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'typography.dart';
import 'app_theme_extension.dart';
import '../constants/dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => _buildTheme(AppThemeExtension.dark);

  static ThemeData get lightTheme => _buildTheme(AppThemeExtension.light);

  static ThemeData _buildTheme(AppThemeExtension colors) {
    final isDark = colors == AppThemeExtension.dark;

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: AppColors.brandPrimary,
      onPrimary: Colors.white,
      secondary: AppColors.brandPink,
      onSecondary: Colors.white,
      error: AppColors.red,
      onError: Colors.white,
      surface: colors.surface,
      onSurface: colors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: AppTypography.forBrightness(colors),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      extensions: [colors],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.sectionTitle(colors),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: isDark ? BorderSide(color: colors.border) : BorderSide.none,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.brandPrimary,
        textColor: colors.textPrimary,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: colors.textSecondary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: AppColors.brandPrimary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: AppColors.brandPink,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            );
          }
          return TextStyle(color: colors.textMuted, fontSize: 12);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? colors.surfaceSecondary : Colors.white,
          foregroundColor: colors.textPrimary,
          minimumSize: const Size(0, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          side: BorderSide(
            color: isDark ? colors.border : colors.textPrimary.withValues(alpha: 0.2),
            width: 1,
          ),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        hintStyle: TextStyle(color: colors.textMuted),
        labelStyle: TextStyle(color: colors.textSecondary),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.brandPrimary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceSecondary,
        selectedColor: AppColors.brandPink.withValues(alpha: 0.18),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: colors.textPrimary),
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surfaceSecondary,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: colors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      splashFactory: InkRipple.splashFactory,
      highlightColor: AppColors.brandPink.withValues(alpha: 0.08),
    );
  }
}
