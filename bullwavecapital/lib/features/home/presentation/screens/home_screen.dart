import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/loading_card.dart';
import '../../../../models/investment_model.dart';
import '../../../goals/presentation/provider/goal_plan_provider.dart';
import '../../../goals/presentation/widgets/home_goals_section.dart';
import '../../../investment/data/featured_plans_catalog.dart';
import '../../../notifications/presentation/provider/notification_provider.dart';
import '../../../stocks/presentation/provider/stock_features_provider.dart';
import '../../../stocks/presentation/provider/stock_market_provider.dart';
import '../provider/home_provider.dart';
import '../widgets/home_balance_cards.dart';
import '../widgets/home_clean_header.dart';
import '../widgets/home_ipo_section.dart';
import '../widgets/home_promo_banner.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_recent_activity.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_trending_strip.dart';
import '../widgets/market_overview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _dueDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGoalReminders();
      _loadEngagement();
    });
  }

  Future<void> _loadEngagement() async {
    if (!mounted) return;
    final features = context.read<StockFeaturesProvider>();
    await Future.wait([
      features.refreshIpoCalendar(limit: 6),
      context.read<StockMarketProvider>().ensureLoaded(),
    ]);
  }

  Future<void> _checkGoalReminders() async {
    if (_dueDialogShown || !mounted) return;
    final goals = context.read<GoalPlanProvider>();
    await goals.refreshReminders();
    if (!mounted || goals.dueGoals.isEmpty) return;
    _dueDialogShown = true;
    showGoalDueDialog(context, goals.dueGoals.first);
  }

  void _showQuickMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _MenuTile(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                onTap: () {
                  Navigator.pop(ctx);
                  context.go(AppRoutes.profile);
                },
              ),
              _MenuTile(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(AppRoutes.settings);
                },
              ),
              _MenuTile(
                icon: Icons.support_agent_outlined,
                label: 'Support',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(AppRoutes.support);
                },
              ),
              _MenuTile(
                icon: Icons.receipt_long_outlined,
                label: 'Transactions',
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(AppRoutes.transactions);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMd),
              child: LoadingList(itemCount: 6, itemHeight: 80),
            ),
          );
        }

        final portfolio = provider.portfolio;
        final notificationCount = context.watch<NotificationProvider>().unreadCount;
        final plans = _featuredPlansForHome(provider);
        final balance = portfolio.currentValue > 0
            ? portfolio.currentValue
            : portfolio.walletBalance;

        return SafeArea(
          child: RefreshIndicator(
            color: AppColors.brandCyan,
            onRefresh: provider.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeCleanHeader(
                    notificationCount: notificationCount,
                    onMenuTap: () => _showQuickMenu(context),
                    onNotificationTap: () => context.push(AppRoutes.notifications),
                  ),
                  const SizedBox(height: 16),
                  HomeSearchBar(
                    onTap: () => context.go(AppRoutes.invest),
                  ),
                  const SizedBox(height: 22),
                  HomePrimaryActionsRow(
                    actions: [
                      HomeQuickAction(
                        icon: Icons.candlestick_chart_rounded,
                        label: 'Markets',
                        color: const Color(0xFF60A5FA),
                        onTap: () => context.go(AppRoutes.invest),
                      ),
                      HomeQuickAction(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Wallet',
                        color: const Color(0xFF34D399),
                        onTap: () => context.go(AppRoutes.wallet),
                      ),
                      HomeQuickAction(
                        icon: Icons.flag_rounded,
                        label: 'Goals',
                        color: const Color(0xFFC084FC),
                        onTap: () => context.push(AppRoutes.goalPlans),
                      ),
                      HomeQuickAction(
                        icon: Icons.savings_outlined,
                        label: 'Plans',
                        color: const Color(0xFFF472B6),
                        onTap: () => context.push(AppRoutes.featuredPlansList),
                      ),
                      HomeQuickAction(
                        icon: Icons.bookmark_outline_rounded,
                        label: 'Saved',
                        color: const Color(0xFFFB923C),
                        onTap: () => context.push(AppRoutes.watchlist),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  HomePromoBanner(
                    title: 'AI Market Insights',
                    subtitle: 'Ask anything about stocks & portfolio',
                    onTap: () => context.push(AppRoutes.aiAssistant),
                  ),
                  const SizedBox(height: 16),
                  HomeBalanceCards(
                    portfolioValue: balance,
                    walletBalance: portfolio.walletBalance,
                    dayPnl: portfolio.dayPnl,
                    onPortfolioTap: () => context.go(AppRoutes.portfolio),
                    onWalletTap: () => context.go(AppRoutes.wallet),
                  ),
                  const SizedBox(height: 20),
                  HomeSecondaryActionsRow(
                    actions: [
                      HomeQuickAction(
                        icon: Icons.calendar_month_outlined,
                        label: 'IPO',
                        color: AppColors.brandCyan,
                        onTap: () => context.push(AppRoutes.ipoCalendar),
                      ),
                      HomeQuickAction(
                        icon: Icons.science_outlined,
                        label: 'Paper',
                        color: AppColors.brandOrange,
                        onTap: () => context.push(AppRoutes.paperTrading),
                      ),
                      HomeQuickAction(
                        icon: Icons.notifications_active_outlined,
                        label: 'Alerts',
                        color: AppColors.brandPink,
                        onTap: () => context.push(AppRoutes.priceAlerts),
                      ),
                      HomeQuickAction(
                        icon: Icons.repeat_rounded,
                        label: 'SIP',
                        color: AppColors.green,
                        onTap: () => context.push(AppRoutes.sipTracker),
                      ),
                      HomeQuickAction(
                        icon: Icons.newspaper_outlined,
                        label: 'News',
                        color: AppColors.blue,
                        onTap: () => context.push(AppRoutes.stockNews),
                      ),
                    ],
                  ),
                  if (provider.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(provider.error!, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  MarketOverview(indices: provider.marketIndices),
                  const SizedBox(height: 24),
                  Consumer<StockMarketProvider>(
                    builder: (context, market, _) {
                      if (market.trendingStocks.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return HomeTrendingStrip(
                        stocks: market.trendingStocks,
                        onSeeAll: () => context.go(AppRoutes.invest),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _SectionTitle(
                    title: 'Featured Plans',
                    actionLabel: 'See All',
                    onAction: () => context.push(AppRoutes.featuredPlansList),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: plans.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return _FeaturedPlanChip(
                          plan: plan,
                          risk: _riskFor(plan.id),
                          onTap: () => _openFeaturedPlan(context, plan),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const HomeIpoSection(),
                  const SizedBox(height: 24),
                  provider.goalPlans.isNotEmpty
                      ? HomeGoalsSection(
                          goals: provider.goalPlans,
                          onViewAll: () => context.push(AppRoutes.goalPlans),
                        )
                      : _GoalPlansPromo(onTap: () => context.push(AppRoutes.goalPlans)),
                  const SizedBox(height: 24),
                  HomeRecentActivity(transactions: provider.recentTransactions),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _riskFor(String id) {
    switch (id) {
      case 'PLAN003':
        return 'High';
      case 'PLAN002':
        return 'Medium';
      default:
        return 'Low';
    }
  }

  List<InvestmentPlanModel> _featuredPlansForHome(HomeProvider provider) {
    if (provider.featuredPlans.isNotEmpty) {
      return provider.featuredPlans.take(4).toList();
    }
    return FeaturedPlansCatalog.plans;
  }

  void _openFeaturedPlan(BuildContext context, InvestmentPlanModel plan) {
    context.push('${AppRoutes.featuredPlan}/${plan.id}', extra: plan);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: AppColors.brandCyan,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}

class _FeaturedPlanChip extends StatelessWidget {
  final InvestmentPlanModel plan;
  final String risk;
  final VoidCallback onTap;

  const _FeaturedPlanChip({
    required this.plan,
    required this.risk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.diamond_outlined, color: AppColors.brandCyan, size: 20),
            ),
            const Spacer(),
            Text(
              plan.name.split(' ').last,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${plan.annualReturnRate.toStringAsFixed(0)}% p.a.',
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              risk,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _GoalPlansPromo extends StatelessWidget {
  final VoidCallback onTap;
  const _GoalPlansPromo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.brandPink.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brandPink.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.flag_rounded, color: AppColors.brandPink, size: 26),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start a Goal Plan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  SizedBox(height: 4),
                  Text(
                    'Earn 8%–16% p.a. on your life goals',
                    style: TextStyle(fontSize: 12, color: AppColors.green),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
