import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/api/api_config.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_card.dart';
import '../../../../core/widgets/modern_screen_header.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/portfolio_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../models/investment_model.dart';
import '../../../../models/stock_model.dart';
import '../../../authentication/presentation/provider/auth_provider.dart';
import '../../../notifications/presentation/provider/notification_provider.dart';
import '../../../stocks/presentation/provider/stock_market_provider.dart';
import '../../../stocks/presentation/widgets/stock_list_tile.dart';
import '../provider/home_provider.dart';
import '../widgets/home_portfolio_section.dart';
import '../widgets/home_recent_activity.dart';
import '../widgets/market_overview.dart';
import '../widgets/news_banner.dart';
import '../widgets/quick_action_button.dart';
import '../../../goals/presentation/provider/goal_plan_provider.dart';
import '../../../goals/presentation/widgets/home_goals_section.dart';
import '../widgets/home_ipo_section.dart';
import '../../../investment/data/featured_plans_catalog.dart';
import '../../../stocks/presentation/provider/stock_features_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMd),
              child: LoadingList(itemCount: 5, itemHeight: 100),
            ),
          );
        }

        final portfolio = provider.portfolio;
        final auth = context.watch<AuthProvider>();
        final user = auth.user;
        final displayName = user?.displayName.split(' ').first ?? 'Investor';
        final avatarUrl = ApiConfig.resolveMediaUrl(user?.avatarUrl ?? '');
        final notificationCount = context.watch<NotificationProvider>().unreadCount;
        final plans = _featuredPlansForHome(provider);

        return SafeArea(
          child: RefreshIndicator(
            color: AppColors.brandOrange,
            onRefresh: provider.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StaggeredEntrance(
                    index: 0,
                    child: ModernScreenHeader(
                      subtitle: GreetingHelper.getGreeting(),
                      title: displayName,
                      avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
                      notificationCount: notificationCount,
                      onNotificationTap: () => context.push(AppRoutes.notifications),
                    ),
                  ),
                  if (provider.error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(provider.error!, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  StaggeredEntrance(
                    index: 1,
                    child: HomePortfolioSection(
                      portfolio: portfolio,
                      chartValues: provider.portfolioChartValues,
                      onTap: () => context.go(AppRoutes.portfolio),
                    ),
                  ),
                  const SizedBox(height: 24),
                  StaggeredEntrance(
                    index: 2,
                    child: MarketOverview(indices: provider.marketIndices),
                  ),
                  if (provider.marketNews.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    StaggeredEntrance(
                      index: 3,
                      child: NewsBanner(
                        news: provider.marketNews,
                        onTap: () => context.push(AppRoutes.stockNews),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  StaggeredEntrance(
                    index: 4,
                    child: const SectionHeader(title: 'Quick Actions'),
                  ),
                  const SizedBox(height: 12),
                  StaggeredEntrance(
                    index: 5,
                    child: QuickActionsRow(
                      actions: [
                        QuickActionButton(
                          icon: Icons.candlestick_chart_outlined,
                          label: 'Markets',
                          color: AppColors.brandOrange,
                          onTap: () => context.go(AppRoutes.invest),
                        ),
                        QuickActionButton(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Wallet',
                          color: AppColors.green,
                          onTap: () => context.go(AppRoutes.wallet),
                        ),
                        QuickActionButton(
                          icon: Icons.flag_rounded,
                          label: 'Goals',
                          color: AppColors.brandPink,
                          onTap: () => context.push(AppRoutes.goalPlans),
                        ),
                        QuickActionButton(
                          icon: Icons.savings_outlined,
                          label: 'Plans',
                          color: const Color(0xFF6366F1),
                          onTap: () => context.push(AppRoutes.featuredPlansList),
                        ),
                        QuickActionButton(
                          icon: Icons.newspaper_outlined,
                          label: 'News',
                          color: AppColors.blue,
                          onTap: () => context.push(AppRoutes.stockNews),
                        ),
                        QuickActionButton(
                          icon: Icons.calendar_month_outlined,
                          label: 'IPO',
                          color: const Color(0xFF0EA5E9),
                          onTap: () => context.push(AppRoutes.ipoCalendar),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  StaggeredEntrance(
                    index: 6,
                    child: const HomeIpoSection(),
                  ),
                  const SizedBox(height: 24),
                  StaggeredEntrance(
                    index: 7,
                    child: provider.goalPlans.isNotEmpty
                        ? HomeGoalsSection(
                            goals: provider.goalPlans,
                            onViewAll: () => context.push(AppRoutes.goalPlans),
                          )
                        : _GoalPlansPromo(onTap: () => context.push(AppRoutes.goalPlans)),
                  ),
                  const SizedBox(height: 24),
                  StaggeredEntrance(
                    index: 8,
                    child: Consumer<StockMarketProvider>(
                      builder: (context, market, _) {
                        if (market.trendingStocks.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'Trending NSE Stocks',
                              actionLabel: 'View All',
                              onAction: () => context.go(AppRoutes.invest),
                            ),
                            const SizedBox(height: 8),
                            ...market.trendingStocks.take(4).map((StockModel s) => StockListTile(stock: s)),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                  ),
                  StaggeredEntrance(
                    index: 9,
                    child: SectionHeader(
                      title: 'Featured Plans',
                      actionLabel: 'View All',
                      onAction: () => context.push(AppRoutes.featuredPlansList),
                    ),
                  ),
                  const SizedBox(height: 12),
                  StaggeredEntrance(
                    index: 10,
                    child: SizedBox(
                      height: 196,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: plans.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          return SizedBox(
                            width: 260,
                            child: InvestmentCard(
                              compact: true,
                              name: plan.name,
                              minimumInvestment: plan.minimumInvestment,
                              annualReturn: plan.annualReturnRate,
                              monthlyReturnMin: plan.monthlyReturnMin,
                              monthlyReturnMax: plan.monthlyReturnMax,
                              risk: _riskFor(plan.id),
                              onTap: () => _openFeaturedPlan(context, plan),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  StaggeredEntrance(
                    index: 11,
                    child: HomeRecentActivity(transactions: provider.recentTransactions),
                  ),
                  const SizedBox(height: 88),
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
      return provider.featuredPlans.take(3).toList();
    }
    return FeaturedPlansCatalog.plans;
  }

  void _openFeaturedPlan(BuildContext context, InvestmentPlanModel plan) {
    context.push('${AppRoutes.featuredPlan}/${plan.id}', extra: plan);
  }
}

class _GoalPlansPromo extends StatelessWidget {
  final VoidCallback onTap;
  const _GoalPlansPromo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.brandPrimary.withValues(alpha: 0.12), AppColors.brandPink.withValues(alpha: 0.08)],
            ),
            borderRadius: BorderRadius.circular(18),
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
                child: const Icon(Icons.flag_rounded, color: AppColors.brandPink, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start a Goal Plan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    SizedBox(height: 4),
                    Text(
                      'Earn 8%–16% p.a. • House • Education • Marriage • Vehicle • Retirement',
                      style: TextStyle(fontSize: 12, height: 1.3, color: AppColors.green),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.brandPink),
            ],
          ),
        ),
      ),
    );
  }
}
