import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/robinhood_card.dart';
import '../../../../models/transaction_model.dart';

class HomeRecentActivity extends StatelessWidget {
  final List<TransactionModel> transactions;

  const HomeRecentActivity({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Activity',
          actionLabel: transactions.isNotEmpty ? 'View All' : null,
          onAction: transactions.isNotEmpty ? () => context.push(AppRoutes.transactions) : null,
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          RobinhoodCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No activity yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Invest in a featured plan or trade stocks to see transactions here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => context.push(AppRoutes.featuredPlansList),
                  child: const Text('Explore Featured Plans'),
                ),
              ],
            ),
          )
        else
          ...transactions.map(
            (txn) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityTile(transaction: txn),
            ),
          ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final TransactionModel transaction;

  const _ActivityTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final txn = transaction;
    final isProfit = txn.type == TransactionType.profit;
    final isInvestment = txn.type == TransactionType.investment;
    final color = isProfit
        ? AppColors.green
        : isInvestment
            ? AppColors.brandOrange
            : AppColors.blue;

    return RobinhoodCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: AppDecorations.iconBadge(color),
            child: Icon(
              isProfit
                  ? Icons.trending_up_rounded
                  : isInvestment
                      ? Icons.savings_outlined
                      : Icons.swap_horiz_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description.isNotEmpty ? txn.description : _labelFor(txn.type),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.display(txn.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isProfit ? '+' : ''}${CurrencyFormatter.format(txn.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isProfit ? AppColors.green : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                txn.status.name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: txn.status == TransactionStatus.completed
                          ? AppColors.green
                          : Colors.grey,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelFor(TransactionType type) {
    switch (type) {
      case TransactionType.profit:
        return 'Profit credit';
      case TransactionType.investment:
        return 'Investment';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      default:
        return 'Transaction';
    }
  }
}