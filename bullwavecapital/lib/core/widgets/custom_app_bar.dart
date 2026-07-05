import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack = true,
    this.onBack,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 64 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: showBack
          ? IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border.withValues(alpha: 0.6)),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: colors.textPrimary),
              ),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: colors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(fontSize: 11, color: colors.textMuted, fontWeight: FontWeight.w600),
            ),
        ],
      ),
      centerTitle: true,
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.surface.withValues(alpha: 0.95),
                    colors.background.withValues(alpha: 0),
                  ],
                )
              : null,
          color: isDark ? null : colors.surface,
          border: Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.5))),
        ),
      ),
    );
  }
}
