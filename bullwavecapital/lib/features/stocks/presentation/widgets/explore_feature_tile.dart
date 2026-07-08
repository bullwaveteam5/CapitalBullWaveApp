import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/modern_icon_badge.dart';
import '../../../../core/widgets/scale_tap.dart';

/// Compact explore shortcuts — small icon tile + label (premium light style).
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
        crossAxisCount: 5,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _ExploreTile(item: items[index]),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  final ExploreFeatureItem item;

  const _ExploreTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTap(
      onTap: item.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                decoration: isDark
                    ? null
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: item.gradient.first.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                child: ModernIconBadge(
                  asset: item.iconAsset,
                  gradient: item.gradient,
                  size: 42,
                ),
              ),
              if (item.badge != null)
                Positioned(
                  top: -4,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandPink.withValues(alpha: 0.25),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      item.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 6.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 9.5,
              height: 1.15,
              letterSpacing: -0.1,
              color: colors.textPrimary,
            ),
          ),
        ],
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
        label: 'Paper',
        gradient: const [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
        onTap: paperTrade,
      ),
      ExploreFeatureItem(
        iconAsset: AppAssets.featFno,
        label: 'F&O',
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
