import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/colors.dart';

/// Subtle gradient backdrop for a premium, depth-rich shell.
class AppScreenBackground extends StatelessWidget {
  final Widget child;
  final bool showTopGlow;

  const AppScreenBackground({
    super.key,
    required this.child,
    this.showTopGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.screenBackground
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, context.appColors.background],
              ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showTopGlow && isDark)
            Positioned(
              top: -80,
              left: -40,
              right: -40,
              height: 220,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brandPrimary.withValues(alpha: 0.14),
                      AppColors.brandPink.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
