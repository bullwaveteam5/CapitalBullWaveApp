import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/routes.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../models/stock_model.dart';
import '../../../stocks/presentation/provider/stock_features_provider.dart';

class HomeIpoSection extends StatelessWidget {
  const HomeIpoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StockFeaturesProvider>(
      builder: (context, features, _) {
        final ipos = features.featuredIpos;
        final holdings = features.ipoHoldings;

        if (ipos.isEmpty && holdings.isEmpty) {
          return const SizedBox.shrink();
        }

        final colors = context.appColors;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'IPO Calendar',
              actionLabel: 'View All',
              onAction: () => context.push(AppRoutes.ipoCalendar),
            ),
            const SizedBox(height: 10),
            if (holdings.isNotEmpty) ...[
              ...holdings.take(2).map(
                    (h) => _HoldingPreview(holding: h, colors: colors),
                  ),
              const SizedBox(height: 10),
            ],
            if (ipos.isNotEmpty)
              SizedBox(
                height: 132,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ipos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) =>
                      _IpoTeaserCard(event: ipos[index], colors: colors),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HoldingPreview extends StatelessWidget {
  final IpoHoldingModel holding;
  final AppThemeExtension colors;

  const _HoldingPreview({required this.holding, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.companyName,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${holding.lots} lot(s) • ${holding.canSell ? 'Listed' : 'Applied'}',
                  style: TextStyle(color: colors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(holding.currentValueInr),
            style: const TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IpoTeaserCard extends StatelessWidget {
  final IpoEventModel event;
  final AppThemeExtension colors;

  const _IpoTeaserCard({required this.event, required this.colors});

  @override
  Widget build(BuildContext context) {
    final isOpen = event.isOpen;
    final accent = isOpen ? AppColors.green : AppColors.blue;

    return InkWell(
      onTap: () => context.push(AppRoutes.ipoCalendar),
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withValues(alpha: 0.14), colors.surface],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isOpen ? 'OPEN — APPLY NOW' : 'UPCOMING',
                style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.companyName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                height: 1.2,
              ),
            ),
            const Spacer(),
            Text(event.priceBandLabel, style: TextStyle(color: colors.textSecondary, fontSize: 11)),
            if (event.gmpPercent != null)
              Text(
                'GMP +${event.gmpPercent!.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
