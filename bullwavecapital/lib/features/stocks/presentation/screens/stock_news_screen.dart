import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/robinhood_card.dart';
import '../provider/stock_features_provider.dart';

class StockNewsScreen extends StatelessWidget {
  const StockNewsScreen({super.key});

  Future<void> _openArticle(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Market News'),
      body: Consumer<StockFeaturesProvider>(
        builder: (context, features, _) {
          if (features.isNewsLoading && features.news.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.green));
          }
          if (features.news.isEmpty) {
            return RefreshIndicator(
              color: AppColors.green,
              onRefresh: features.refreshNews,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No news available. Pull to refresh.')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.green,
            onRefresh: features.refreshNews,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: features.news.length,
              itemBuilder: (_, i) {
                final n = features.news[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RobinhoodCard(
                    onTap: () async {
                      if (n.url.isNotEmpty) {
                        await _openArticle(n.url);
                        return;
                      }
                      if (n.relatedSymbols.isNotEmpty && context.mounted) {
                        context.push('${AppRoutes.stockDetail}?symbol=${n.relatedSymbols.first}');
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                n.category,
                                style: const TextStyle(
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            if (n.relatedSymbols.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  n.relatedSymbols.take(3).join(', '),
                                  style: Theme.of(context).textTheme.labelSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          n.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(n.summary, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${n.source} • ${DateFormatter.display(n.publishedAt)}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                            if (n.url.isNotEmpty)
                              const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
