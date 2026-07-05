import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/stock_model.dart';
import '../../../../core/widgets/modern_icon_badge.dart';
import '../provider/stock_market_provider.dart';

class StockListTile extends StatelessWidget {
  final StockModel stock;
  final VoidCallback? onTap;
  final bool showWatchlistButton;

  const StockListTile({
    super.key,
    required this.stock,
    this.onTap,
    this.showWatchlistButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final changeColor = stock.isPositive ? AppColors.green : AppColors.red;
    final market = context.watch<StockMarketProvider>();
    final inWatchlist = market.isInWatchlist(stock.symbol);

    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: onTap ?? () => context.push('${AppRoutes.stockDetail}?symbol=${stock.symbol}'),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border.withValues(alpha: 0.6))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              ModernStockAvatar(symbol: stock.symbol),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                    ),
                    Text(
                      stock.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    IndexFormatter.format(stock.ltp),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                  ),
                  Text(
                    '${IndexFormatter.formatChange(stock.change)} (${IndexFormatter.formatPercent(stock.changePercent)})',
                    style: TextStyle(color: changeColor, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
              if (showWatchlistButton) ...[
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    inWatchlist ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: inWatchlist ? AppColors.brandPink : colors.textMuted,
                    size: 22,
                  ),
                  onPressed: () async {
                    final err = await market.toggleWatchlist(stock.symbol);
                    if (context.mounted && err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LivePriceBadge extends StatelessWidget {
  const LivePriceBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            'Live',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.greenDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
