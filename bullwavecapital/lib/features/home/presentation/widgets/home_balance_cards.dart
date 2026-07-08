import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/scale_tap.dart';

class HomeBalanceCards extends StatelessWidget {
  final double portfolioValue;
  final double walletBalance;
  final double dayPnl;
  final VoidCallback? onPortfolioTap;
  final VoidCallback? onWalletTap;

  const HomeBalanceCards({
    super.key,
    required this.portfolioValue,
    required this.walletBalance,
    this.dayPnl = 0,
    this.onPortfolioTap,
    this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BalanceCard(
            icon: Icons.rocket_launch_rounded,
            iconColor: AppColors.brandCyan,
            amount: portfolioValue,
            label: 'Portfolio',
            sublabel: dayPnl != 0
                ? '${dayPnl >= 0 ? '+' : ''}${CurrencyFormatter.formatCompact(dayPnl)} today'
                : 'Total holdings',
            onTap: onPortfolioTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BalanceCard(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.brandOrange,
            amount: walletBalance,
            label: 'Wallet',
            sublabel: walletBalance > 0 ? 'Available balance' : 'Add funds',
            onTap: onWalletTap,
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double amount;
  final String label;
  final String sublabel;
  final VoidCallback? onTap;

  const _BalanceCard({
    required this.icon,
    required this.iconColor,
    required this.amount,
    required this.label,
    required this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 12),
            Text(
              CurrencyFormatter.formatCompact(amount),
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: colors.textMuted,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
