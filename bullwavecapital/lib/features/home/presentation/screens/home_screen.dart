import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/bank_verification_guard.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_card.dart';
import '../../../../core/widgets/modern_hero_card.dart';
import '../../../../core/widgets/modern_screen_header.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../../core/widgets/portfolio_card.dart';
import '../../../../core/widgets/robinhood_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../models/transaction_model.dart';
import '../../../../models/stock_model.dart';
import '../../../authentication/presentation/provider/auth_provider.dart';
import '../../../notifications/presentation/provider/notification_provider.dart';
import '../provider/home_provider.dart';
import '../../../stocks/presentation/provider/stock_market_provider.dart';
import '../../../stocks/presentation/widgets/stock_list_tile.dart';
import '../widgets/market_overview.dart';
import '../widgets/news_banner.dart';
import '../widgets/quick_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMd),
              child: LoadingList(itemCount: 4, itemHeight: 100),
            ),
          );
        }

        final portfolio = provider.portfolio;
        final chartValues = provider.monthlyEarnings.map((e) => e.amount).toList();
        final auth = context.watch<AuthProvider>();
        final user = auth.user;
        final displayName = user?.displayName.split(' ').first ?? 'Investor';
        final avatarUrl = user?.avatarUrl ?? '';
        final notificationCount = context.watch<NotificationProvider>().unreadCount;

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
                      avatarUrl: avatarUrl,
                      notificationCount: notificationCount,
                      onNotificationTap: () => context.push(AppRoutes.notifications),
                    ),
                  ),
                  const SizedBox(height: 20),
                  StaggeredEntrance(
                    index: 1,
                    child: ModernHeroCard(
                      label: 'Portfolio Balance',
                      amount: portfolio.holdingsCount > 0 ? portfolio.stocksValue : portfolio.currentValue,
                      changeAmount: portfolio.dayPnl,
                      changePrefix: 'Today',
                      chartValues: chartValues,
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
                      index: 2,
                      child: NewsBanner(
                        news: provider.marketNews,
                        onTap: () => context.push(AppRoutes.stockNews),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  StaggeredEntrance(
                    index: 3,
                    child: const SectionHeader(title: 'Quick Actions'),
                  ),
                  const SizedBox(height: 12),
                  StaggeredEntrance(
                    index: 4,
                    child: QuickActionsRow(
                      actions: [
                        QuickActionButton(
                          icon: Icons.candlestick_chart_outlined,
                          label: 'Markets',
                          color: AppColors.brandOrange,
                          onTap: () => context.go(AppRoutes.invest),
                        ),
                        QuickActionButton(
                          icon: Icons.star_rounded,
                          label: 'Watchlist',
                          color: AppColors.yellow,
                          onTap: () => context.push(AppRoutes.watchlist),
                        ),
                        QuickActionButton(
                          icon: Icons.smart_toy_outlined,
                          label: 'AI Assist',
                          color: const Color(0xFF8B5CF6),
                          onTap: () => context.push(AppRoutes.aiAssistant),
                        ),
                        QuickActionButton(
                          icon: Icons.newspaper_outlined,
                          label: 'News',
                          color: AppColors.blue,
                          onTap: () => context.push(AppRoutes.stockNews),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  StaggeredEntrance(
                    index: 5,
                    child: Consumer<StockMarketProvider>(
                      builder: (context, market, _) {
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
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  StaggeredEntrance(
                    index: 6,
                    child: SectionHeader(
                      title: 'Featured Plans',
                      actionLabel: 'View All',
                      onAction: () => context.go(AppRoutes.invest),
                    ),
                  ),
                  const SizedBox(height: 12),
                  StaggeredEntrance(
                    index: 7,
                    child: SizedBox(
                      height: 196,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.featuredPlans.take(3).length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final plan = provider.featuredPlans[index];
                          return SizedBox(
                            width: 260,
                            child: InvestmentCard(
                              compact: true,
                              name: plan.name,
                              minimumInvestment: plan.minimumInvestment,
                              annualReturn: plan.annualReturnRate,
                              risk: plan.id == 'PLAN003'
                                  ? 'High'
                                  : plan.id == 'PLAN002'
                                      ? 'Medium'
                                      : 'Low',
                              onTap: () async {
                                if (!await ensureBankVerified(context)) return;
                                if (context.mounted) context.go(AppRoutes.invest);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  StaggeredEntrance(
                    index: 8,
                    child: const SectionHeader(title: 'Recent Activity'),
                  ),
                  const SizedBox(height: 12),
                  StaggeredEntrance(
                    index: 9,
                    child: Column(
                      children: provider.recentTransactions.map(
                        (txn) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: RobinhoodCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: AppDecorations.iconBadge(
                                    txn.type == TransactionType.profit
                                        ? AppColors.green
                                        : AppColors.brandOrange,
                                  ),
                                  child: Icon(
                                    txn.type == TransactionType.profit
                                        ? Icons.trending_up_rounded
                                        : Icons.swap_horiz_rounded,
                                    color: txn.type == TransactionType.profit
                                        ? AppColors.green
                                        : AppColors.brandOrange,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        txn.description,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Text(
                                        DateFormatter.display(txn.date),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(txn.amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: txn.type == TransactionType.profit
                                        ? AppColors.green
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
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
}
