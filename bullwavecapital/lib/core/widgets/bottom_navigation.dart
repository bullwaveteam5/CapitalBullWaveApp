import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/app_theme_extension.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool marketsLocked;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.marketsLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: isDark ? 0.88 : 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: colors.border.withValues(alpha: isDark ? 0.6 : 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: NavigationBar(
              height: 68,
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppColors.brandOrange.withValues(alpha: 0.14),
              surfaceTintColor: Colors.transparent,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 250),
              destinations: List.generate(5, (i) {
                final items = [
                  (Icons.home_outlined, Icons.home_rounded, 'Home'),
                  (Icons.candlestick_chart_outlined, Icons.candlestick_chart_rounded, 'Markets'),
                  (Icons.pie_chart_outline, Icons.pie_chart_rounded, 'Portfolio'),
                  (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Wallet'),
                  (Icons.person_outline, Icons.person_rounded, 'Profile'),
                ];
                final (icon, selectedIcon, label) = items[i];
                final locked = marketsLocked && i < 4;
                Widget buildIcon(IconData data, {bool selected = false}) {
                  final child = Icon(
                    data,
                    color: locked
                        ? colors.textMuted.withValues(alpha: 0.45)
                        : (selected ? AppColors.brandOrange : colors.textMuted),
                    size: selected ? 24 : 22,
                  );
                  if (!locked) return child;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      child,
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Icon(Icons.lock_rounded, size: 10, color: colors.textMuted),
                      ),
                    ],
                  );
                }

                return NavigationDestination(
                  icon: buildIcon(icon),
                  selectedIcon: buildIcon(selectedIcon, selected: true),
                  label: label,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
