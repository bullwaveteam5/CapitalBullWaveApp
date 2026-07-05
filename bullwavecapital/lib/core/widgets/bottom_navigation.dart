import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/assets.dart';
import '../theme/colors.dart';
import '../theme/app_theme_extension.dart';
import 'app_brand_logo.dart';

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

  static const _items = [
    (AppAssets.navHome, 'Home'),
    (AppAssets.navMarkets, 'Markets'),
    (AppAssets.navPortfolio, 'Portfolio'),
    (AppAssets.navWallet, 'Wallet'),
    (AppAssets.navProfile, 'Profile'),
  ];

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
              color: colors.surface.withValues(alpha: isDark ? 0.88 : 0.94),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.brandPrimary.withValues(alpha: isDark ? 0.25 : 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: isDark ? 0.2 : 0.08),
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
              indicatorColor: AppColors.brandPrimary.withValues(alpha: 0.18),
              surfaceTintColor: Colors.transparent,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 250),
              destinations: List.generate(_items.length, (i) {
                final (asset, label) = _items[i];
                final locked = marketsLocked && i < 4;

                Widget buildIcon({required bool active}) {
                  final icon = AppSvgIcon(
                    asset: asset,
                    size: active ? 24 : 22,
                    color: locked
                        ? colors.textMuted.withValues(alpha: 0.45)
                        : (active ? null : colors.textMuted),
                    gradient: !locked && active ? AppColors.accentGradient : null,
                  );
                  if (!locked) return icon;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      icon,
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Icon(Icons.lock_rounded, size: 10, color: colors.textMuted),
                      ),
                    ],
                  );
                }

                return NavigationDestination(
                  icon: buildIcon(active: false),
                  selectedIcon: buildIcon(active: true),
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
