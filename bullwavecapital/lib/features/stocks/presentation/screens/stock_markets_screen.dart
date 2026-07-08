import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/routes.dart';
import '../../../fno/fno_navigation.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../features/home/presentation/widgets/market_overview.dart';
import '../provider/stock_market_provider.dart';
import '../widgets/explore_feature_tile.dart';
import '../widgets/stock_list_tile.dart';

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
            color: AppColors.brandCyan,
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
                        const SizedBox(height: 6),
                        Text(
                          'Live via ${market.marketProvider}',
                          style: GoogleFonts.inter(
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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
                      const SizedBox(height: 18),
                      TextField(
                        controller: _searchController,
                        onChanged: market.setSearchQuery,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: AppDecorations.pillSearch(
                          context,
                          hint: 'Search NSE stocks...',
                        ),
                      ),
                      if (market.searchQuery.isEmpty && market.marketIndices.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        MarketOverview(indices: market.marketIndices),
                      ],
                      const SizedBox(height: 22),
                      Text(
                        'Explore',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ExploreFeatureGrid(
                        items: MarketsExploreShortcuts.all(
                          watchlist: () => context.push(AppRoutes.watchlist),
                          screener: () => context.push(AppRoutes.stockScreener),
                          news: () => context.push(AppRoutes.stockNews),
                          commodities: () => context.push(AppRoutes.commodities),
                          alerts: () => context.push(AppRoutes.priceAlerts),
                          sip: () => context.push(AppRoutes.sipTracker),
                          paperTrade: () => openFnoFeature(context, AppRoutes.paperTrading),
                          fnoChain: () => openFnoFeature(context, AppRoutes.optionChain),
                          ipoCalendar: () => context.push(AppRoutes.ipoCalendar),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            market.searchQuery.isEmpty ? 'Trending Stocks' : 'Search Results',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              letterSpacing: -0.3,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => context.push(AppRoutes.watchlist),
                            icon: const Icon(Icons.bookmark_outline_rounded, size: 18, color: AppColors.brandPink),
                            label: Text(
                              'Watchlist',
                              style: GoogleFonts.inter(
                                color: AppColors.brandPink,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ]),
                  ),
                ),
                if (market.isLoading && stocks.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator(color: AppColors.brandCyan)),
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
                const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
              ],
            ),
          ),
        );
      },
    );
  }
}
