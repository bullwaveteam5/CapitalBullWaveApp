import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/routes.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/scale_tap.dart';
import '../../../../models/stock_model.dart';
import '../../../stocks/presentation/widgets/stock_list_tile.dart';

class HomeTrendingStrip extends StatelessWidget {
  final List<StockModel> stocks;
  final VoidCallback? onSeeAll;

  const HomeTrendingStrip({
    super.key,
    required this.stocks,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) return const SizedBox.shrink();

    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Trending Stocks',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            if (onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandCyan,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stocks.length.clamp(0, 8),
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return _TrendingStockChip(stock: stock);
            },
          ),
        ),
        const SizedBox(height: 20),
        ...stocks.take(3).map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: StockListTile(stock: s, showWatchlistButton: false),
              ),
            ),
      ],
    );
  }
}

class _TrendingStockChip extends StatelessWidget {
  final StockModel stock;

  const _TrendingStockChip({required this.stock});

  @override
  Widget build(BuildContext context) {
    final changeColor = stock.isPositive ? AppColors.green : AppColors.red;
    final initials = stock.symbol.length >= 2
        ? stock.symbol.substring(0, 2)
        : stock.symbol;

    return ScaleTap(
      onTap: () => context.push('${AppRoutes.stockDetail}?symbol=${stock.symbol}'),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                initials,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: changeColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stock.symbol,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              IndexFormatter.formatPercent(stock.changePercent),
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: changeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
