import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/robinhood_line_chart.dart';
import '../../../../models/stock_model.dart';

/// Interval label shown in UI → backend candle interval.
const stockChartIntervals = <({String label, String apiInterval})>[
  (label: '1m', apiInterval: '1m'),
  (label: '5m', apiInterval: '5m'),
  (label: '30m', apiInterval: '30m'),
  (label: '1H', apiInterval: '1h'),
  (label: '1D', apiInterval: '1d'),
  (label: '1M', apiInterval: '90d'),
];

class StockDetailChart extends StatelessWidget {
  final List<CandleModel> candles;
  final bool isPositive;
  final bool isLoading;
  final String selectedLabel;
  final ValueChanged<String> onIntervalSelected;

  const StockDetailChart({
    super.key,
    required this.candles,
    required this.isPositive,
    required this.isLoading,
    required this.selectedLabel,
    required this.onIntervalSelected,
  });

  List<double> get _closeValues => candles.map((c) => c.close).toList();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: isLoading && candles.isEmpty
              ? Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.brandOrange.withValues(alpha: 0.8),
                    ),
                  ),
                )
              : candles.length < 2
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.show_chart_rounded, size: 40, color: colors.textMuted),
                          const SizedBox(height: 8),
                          Text(
                            'Chart loading…',
                            style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  : RobinhoodLineChart(
                      values: _closeValues,
                      height: 240,
                      isPositive: isPositive,
                    ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: stockChartIntervals.map((item) {
              final selected = item.label == selectedLabel;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: selected
                      ? AppColors.brandOrange.withValues(alpha: 0.15)
                      : colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: () => onIntervalSelected(item.label),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected
                              ? AppColors.brandOrange.withValues(alpha: 0.5)
                              : colors.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: selected ? AppColors.brandOrange : colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
