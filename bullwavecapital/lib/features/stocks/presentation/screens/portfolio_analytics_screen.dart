import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/robinhood_card.dart';
import '../provider/stock_portfolio_provider.dart';
import '../../../portfolio/presentation/widgets/portfolio_holding_tile.dart';

class PortfolioAnalyticsScreen extends StatelessWidget {
  const PortfolioAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Portfolio Analytics'),
      body: Consumer<StockPortfolioProvider>(
        builder: (context, portfolio, _) {
          if (portfolio.isLoading && portfolio.holdings.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.brandOrange));
          }

          final summary = portfolio.summary;
          final sectors = portfolio.sectorAllocation;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RobinhoodCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Portfolio Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    _Row('Invested', CurrencyFormatter.format(summary.totalInvested)),
                    _Row('Current Value', CurrencyFormatter.format(summary.currentValue)),
                    _Row(
                      'Total P&L',
                      CurrencyFormatter.format(summary.totalPnl),
                      color: summary.totalPnl >= 0 ? AppColors.green : AppColors.red,
                    ),
                    _Row('Return', '${summary.totalPnlPercent.toStringAsFixed(2)}%'),
                    _Row(
                      'Today',
                      CurrencyFormatter.format(summary.dayPnl),
                      color: summary.dayPnl >= 0 ? AppColors.green : AppColors.red,
                    ),
                    _Row('Holdings', '${summary.holdingsCount}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (sectors.isNotEmpty) ...[
                Text('Sector Allocation', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                ...sectors.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RobinhoodCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text('${item.percentage.toStringAsFixed(1)}%'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(item.value),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: item.percentage / 100,
                            color: Color(item.colorValue),
                            backgroundColor: AppColors.border,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
              Text('All Holdings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (portfolio.holdings.isEmpty)
                const RobinhoodCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No holdings to analyze yet.'),
                  ),
                )
              else
                ...portfolio.holdings.map(
                  (h) => PortfolioHoldingTile(
                    holding: h,
                    onTap: () => context.push('${AppRoutes.stockDetail}?symbol=${h.symbol}'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Row(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
