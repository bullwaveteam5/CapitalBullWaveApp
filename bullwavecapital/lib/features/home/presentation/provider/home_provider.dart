import 'package:flutter/material.dart';

import '../../../../core/api/bullwave_api.dart';
import '../../../../models/investment_model.dart';
import '../../../../models/market_index_model.dart';
import '../../../../models/portfolio_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../../core/api/json_parsers.dart';

class HomeProvider extends ChangeNotifier {
  final _api = BullwaveApi.instance;

  bool _isLoading = true;
  PortfolioModel _portfolio = const PortfolioModel(
    totalInvestment: 0,
    currentValue: 0,
    monthlyProfit: 0,
    totalProfit: 0,
    growthPercent: 0,
  );
  List<InvestmentPlanModel> _featuredPlans = [];
  List<MarketIndexModel> _marketIndices = [];
  List<Map<String, String>> _marketNews = [];
  List<MonthlyEarning> _monthlyEarnings = [];
  List<TransactionModel> _recentTransactions = [];

  bool get isLoading => _isLoading;
  PortfolioModel get portfolio => _portfolio;
  List<InvestmentPlanModel> get featuredPlans => _featuredPlans;
  List<MarketIndexModel> get marketIndices => _marketIndices;
  List<Map<String, String>> get marketNews => _marketNews;
  List<MonthlyEarning> get monthlyEarnings => _monthlyEarnings;
  List<TransactionModel> get recentTransactions => _recentTransactions;

  HomeProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final home = await _api.getHome();
      _portfolio = parsePortfolio(home['portfolio'] as Map<String, dynamic>);
      _featuredPlans = parseList(home['featuredPlans'], parseInvestmentPlan);
      _marketIndices = parseList(home['marketIndices'], parseMarketIndex);
      _marketNews = (home['marketNews'] as List<dynamic>? ?? [])
          .map((e) => {
                'title': (e as Map)['title']?.toString() ?? '',
                'subtitle': e['subtitle']?.toString() ?? '',
              })
          .toList();
      _monthlyEarnings = await _api.getEarnings();
      final txns = await _api.getTransactions();
      _recentTransactions = txns.take(3).toList();
    } catch (_) {
      // Keep defaults on error
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadData();
}
