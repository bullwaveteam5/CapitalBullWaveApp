import 'package:flutter/material.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/modern_icon_badge.dart';

/// Symmetric explore grid with centered icons and labels.
class ExploreFeatureItem {
  final String iconAsset;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  final String? badge;

  const ExploreFeatureItem({
    required this.iconAsset,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.badge,
  });
}

class ExploreFeatureGrid extends StatelessWidget {
  final List<ExploreFeatureItem> items;

  const ExploreFeatureGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _ExploreTile(item: items[index], colors: context.appColors),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  final ExploreFeatureItem item;
  final AppThemeExtension colors;

  const _ExploreTile({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colors.surface,
            border: Border.all(color: item.gradient.first.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: item.gradient.last.withValues(alpha: 0.1),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ModernIconBadge(
                      asset: item.iconAsset,
                      gradient: item.gradient,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                        height: 1.2,
                        letterSpacing: -0.1,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (item.badge != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pre-built explore shortcuts for the Markets screen.
class MarketsExploreShortcuts {
  MarketsExploreShortcuts._();

  static List<ExploreFeatureItem> all({
    required VoidCallback watchlist,
    required VoidCallback screener,
    required VoidCallback news,
    required VoidCallback commodities,
    required VoidCallback alerts,
    required VoidCallback sip,
    required VoidCallback paperTrade,
    required VoidCallback fnoChain,
    required VoidCallback ipoCalendar,
  }) {
    return [
      ExploreFeatureItem(
        iconAsset: AppAssets.featWatchlist,
        label: 'Watchlist',
        gradient: const [Color(0xFF9333EA), Color(0xFFEC4899)],
        onTap: watchlist,
      ),
      ExploreFeatureItem(
        iconAsset: AppAssets.featScreener,
        label: 'Screener',
        gradient: const [Color(0xFF3B82F6), Color(0xFF22D3EE)],
        onTap: screener,
      ),
      ExploreFeatureItem(
        iconAsset: AppAssets.featNews,
        label: 'News',
        gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
        onTap: news,
      ),
      ExploreFeatureItem(
        iconAsset: AppAssets.featCommodities,
        label: 'Commodities',
        gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        onTap: commodities,
      ),
      ExploreFeatureItem(
        iconAsset: AppAssets.featAlerts,
        label: 'Alerts',
        gradient: const [Color(0xFFEF4444), Color(0xFFF97316)],
        onTap: alerts,
      ),
      ExploreFeatureItem(
        iconAsset: AppAssets.featSip,
        label: 'SIP',
        gradient: const [Color(0xFF6366F1), Color(0xFF818CF8)],
        onTap: sip,
      ),
      ExploreFeatureItem(
        iconAsset: AppAssets.featPaperTrade,
        label: 'Paper Trade',
        gradient: const [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
        onTap: paperTrade,
      ),
      ExploreFeatureItem(
        iconAsset: AppAssets.featFno,
        label: 'F&O Chain',
        gradient: const [Color(0xFF7C3AED), Color(0xFFA855F7)],
        onTap: fnoChain,
        badge: 'F&O',
      ),
      ExploreFeatureItem(
        iconAsset: AppAssets.featIpo,
        label: 'IPO',
        gradient: const [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
        onTap: ipoCalendar,
        badge: 'NEW',
      ),
    ];
  }
}
