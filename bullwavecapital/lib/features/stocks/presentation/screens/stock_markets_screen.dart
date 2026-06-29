import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../features/home/presentation/widgets/market_overview.dart';
import '../provider/stock_market_provider.dart';
import '../widgets/stock_list_tile.dart';
import '../widgets/technical_indicators_panel.dart';

class StockMarketsScreen extends StatefulWidget {
  const StockMarketsScreen({super.key});

  @override
  State<StockMarketsScreen> createState() => _StockMarketsScreenState();
}

class _StockMarketsScreenState extends State<StockMarketsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockMarketProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockMarketProvider>(
      builder: (context, market, _) {
        final stocks = market.searchQuery.isEmpty ? market.trendingStocks : market.searchResults;
        return SafeArea(
          child: RefreshIndicator(
            color: AppColors.green,
            onRefresh: market.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Markets',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          const LivePriceBadge(),
                        ],
                      ),
                      if (market.marketProvider.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Live via ${market.marketProvider}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.green,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                      if (market.marketError != null && stocks.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          market.marketError!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.red),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: market.setSearchQuery,
                        decoration: AppDecorations.pillSearch(context, hint: 'Search NSE stocks...'),
                      ),
                      if (market.searchQuery.isEmpty && market.marketIndices.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        MarketOverview(indices: market.marketIndices),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        'Explore',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      MarketsFeatureGrid(
                        items: [
                          (icon: Icons.star_rounded, label: 'Watchlist', color: AppColors.yellow, onTap: () => context.push(AppRoutes.watchlist)),
                          (icon: Icons.filter_alt_outlined, label: 'Screener', color: AppColors.blue, onTap: () => context.push(AppRoutes.stockScreener)),
                          (icon: Icons.newspaper_outlined, label: 'News', color: AppColors.green, onTap: () => context.push(AppRoutes.stockNews)),
                          (icon: Icons.smart_toy_outlined, label: 'AI Assist', color: const Color(0xFF8B5CF6), onTap: () => context.push(AppRoutes.aiAssistant)),
                          (icon: Icons.notifications_active_outlined, label: 'Alerts', color: AppColors.red, onTap: () => context.push(AppRoutes.priceAlerts)),
                          (icon: Icons.savings_outlined, label: 'SIP', color: AppColors.green, onTap: () => context.push(AppRoutes.sipTracker)),
                          (icon: Icons.show_chart_outlined, label: 'Paper Trade', color: AppColors.blue, onTap: () => context.push(AppRoutes.paperTrading)),
                          (icon: Icons.account_balance_outlined, label: 'F&O Chain', color: const Color(0xFF6366F1), onTap: () => context.push(AppRoutes.optionChain)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            market.searchQuery.isEmpty ? 'Trending Stocks' : 'Search Results',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.watchlist),
                            child: const Text('Watchlist', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
                if (market.isLoading && stocks.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (stocks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          market.marketError ?? 'No stocks loaded. Pull down to refresh.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => StockListTile(stock: stocks[index]),
                      childCount: stocks.length,
                    ),
                  ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
              ],
            ),
          ),
        );
      },
    );
  }
}
