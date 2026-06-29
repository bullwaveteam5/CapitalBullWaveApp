import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/robinhood_card.dart';
import '../../../../models/market_index_model.dart';

class MarketOverview extends StatelessWidget {
  final List<MarketIndexModel> indices;

  const MarketOverview({super.key, required this.indices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Market Overview',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.green,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: indices.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => SizedBox(
              width: 148,
              child: _MarketIndexCard(index: indices[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _MarketIndexCard extends StatelessWidget {
  final MarketIndexModel index;

  const _MarketIndexCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final changeColor = index.isPositive ? AppColors.green : AppColors.red;

    return RobinhoodCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            index.shortName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            IndexFormatter.format(index.value),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${IndexFormatter.formatChange(index.change)} (${IndexFormatter.formatPercent(index.changePercent)})',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
