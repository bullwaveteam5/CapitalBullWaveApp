import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/routes.dart';
import '../../../../core/theme/app_decorations.dart';
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => context.push('${AppRoutes.stockDetail}?symbol=${stock.symbol}'),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: AppDecorations.glassCard(context),
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
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: colors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        stock.name,
                        style: GoogleFonts.inter(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
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
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${IndexFormatter.formatChange(stock.change)} (${IndexFormatter.formatPercent(stock.changePercent)})',
                      style: GoogleFonts.inter(
                        color: changeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
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
      ),
    );
  }
}

class LivePriceBadge extends StatelessWidget {
  const LivePriceBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            'Live',
            style: GoogleFonts.inter(
              color: AppColors.green,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
