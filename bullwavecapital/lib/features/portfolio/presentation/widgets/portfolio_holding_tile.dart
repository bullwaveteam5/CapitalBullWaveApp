import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/robinhood_card.dart';
import '../../../../models/stock_model.dart';

class PortfolioHoldingTile extends StatelessWidget {
  final StockHoldingModel holding;
  final VoidCallback? onTap;
  final VoidCallback? onBuy;
  final VoidCallback? onSell;

  const PortfolioHoldingTile({
    super.key,
    required this.holding,
    this.onTap,
    this.onBuy,
    this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final pnlColor = holding.isPositive ? AppColors.green : AppColors.red;
    final dayColor = holding.isDayPositive ? AppColors.green : AppColors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RobinhoodCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holding.symbol,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        holding.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(holding.currentValue),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${holding.pnl >= 0 ? '+' : ''}${CurrencyFormatter.formatCompact(holding.pnl)} (${holding.pnlPercent.toStringAsFixed(2)}%)',
                      style: TextStyle(color: pnlColor, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Metric(label: 'Qty', value: '${holding.quantity}'),
                _Metric(label: 'Avg', value: CurrencyFormatter.format(holding.avgPrice)),
                _Metric(label: 'LTP', value: CurrencyFormatter.format(holding.ltp)),
                _Metric(
                  label: 'Today',
                  value: '${holding.dayPnl >= 0 ? '+' : ''}${CurrencyFormatter.formatCompact(holding.dayPnl)}',
                  valueColor: dayColor,
                ),
              ],
            ),
            if (onBuy != null || onSell != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onBuy != null)
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilledButton(
                          onPressed: onBuy,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Buy', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  if (onBuy != null && onSell != null) const SizedBox(width: 10),
                  if (onSell != null)
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: onSell,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.red,
                            side: const BorderSide(color: AppColors.red, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Sell', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Metric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
