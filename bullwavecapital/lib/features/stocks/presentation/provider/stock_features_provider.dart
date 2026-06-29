import 'package:flutter/material.dart';

import '../../../../core/api/api_exception.dart';
import '../../../../core/api/bullwave_api.dart';
import '../../../../models/stock_model.dart';

class _SymbolOptionChain {
  List<OptionContractModel> contracts = [];
  double underlying = 0;
  List<String> expiries = [];
  String selectedExpiry = '';
  String? error;
  bool loading = false;
}

class StockFeaturesProvider extends ChangeNotifier {
  final _api = BullwaveApi.instance;

  List<StockNewsModel> _news = [];
  List<PriceAlertModel> _alerts = [];
  List<SipPlanModel> _sipPlans = [];
  List<PaperTradeModel> _paperTrades = [];
  String? _tradeError;
  List<DividendModel> _dividends = [];
  List<ScreenerStockModel> _screenerResults = [];
  List<String> _screenerSectors = ['All'];
  final Map<String, _SymbolOptionChain> _optionChains = {};
  List<AiMessageModel> _aiMessages = [];
  List<String> _aiSuggestions = [
    'Should I buy RELIANCE?',
    'Explain RSI indicator',
    'Best IT stocks today?',
    'Nifty outlook this week',
  ];
  String _screenerSector = 'All';
  bool _isLoading = false;
  bool _isNewsLoading = false;
  bool _isScreenerLoading = false;
  bool _isAiLoading = false;
  String? _aiError;

  _SymbolOptionChain _chainState(String symbol) =>
      _optionChains.putIfAbsent(symbol.toUpperCase(), () => _SymbolOptionChain());

  List<StockNewsModel> get news => _news;
  List<PriceAlertModel> get alerts => _alerts;
  List<SipPlanModel> get sipPlans => _sipPlans;
  List<PaperTradeModel> get paperTrades => _paperTrades;
  String? get tradeError => _tradeError;
  List<DividendModel> get dividends => _dividends;
  List<AiMessageModel> get aiMessages => _aiMessages;
  List<String> get aiSuggestions => _aiSuggestions;
  bool get isAiLoading => _isAiLoading;
  String? get aiError => _aiError;
  String get screenerSector => _screenerSector;
  bool get isLoading => _isLoading;
  bool get isNewsLoading => _isNewsLoading;
  bool get isScreenerLoading => _isScreenerLoading;

  List<ScreenerStockModel> get screenerResults => _screenerResults;
  List<String> get sectors => _screenerSectors;

  List<OptionContractModel> optionChain(String symbol) => _chainState(symbol).contracts;
  bool isOptionChainLoading(String symbol) => _chainState(symbol).loading;
  String? optionChainError(String symbol) => _chainState(symbol).error;
  double optionUnderlying(String symbol) => _chainState(symbol).underlying;
  List<String> optionExpiries(String symbol) => _chainState(symbol).expiries;
  String optionSelectedExpiry(String symbol) => _chainState(symbol).selectedExpiry;

  StockFeaturesProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        _loadNews(),
        _loadAlerts(),
        _loadSip(),
        _loadPaperTrades(),
        _loadDividends(),
        _loadScreener(),
      ]);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadNews() async => _news = await _api.getStockNews();

  Future<void> refreshNews() async {
    _isNewsLoading = true;
    notifyListeners();
    try {
      _news = await _api.getStockNews();
    } catch (_) {}
    _isNewsLoading = false;
    notifyListeners();
  }

  Future<void> _loadAlerts() async => _alerts = await _api.getPriceAlerts();
  Future<void> _loadSip() async => _sipPlans = await _api.getSipPlans();
  Future<void> _loadPaperTrades() async => _paperTrades = await _api.getPaperTrades();
  Future<void> _loadDividends() async {
    try {
      _dividends = await _api.getDividends(sync: true);
    } catch (_) {}
  }

  Future<void> refreshDividends() async {
    try {
      _dividends = await _api.getDividends(sync: true);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadScreener() async {
    final data = await _api.getScreener(
      sector: _screenerSector == 'All' ? null : _screenerSector,
    );
    _screenerResults = data.results;
    _screenerSectors = ['All', ...data.sectors];
  }

  Future<void> refreshScreener() async {
    _isScreenerLoading = true;
    notifyListeners();
    try {
      await _loadScreener();
    } catch (_) {}
    _isScreenerLoading = false;
    notifyListeners();
  }

  void _applyChain(_SymbolOptionChain state, OptionChainResponse chain) {
    state.contracts = chain.contracts;
    state.underlying = chain.underlyingValue;
    state.expiries = chain.expiryDates;
    state.selectedExpiry = chain.selectedExpiry;
  }

  Future<void> loadOptionChain(String symbol, {String? expiry}) async {
    final state = _chainState(symbol);
    state.loading = true;
    state.error = null;
    notifyListeners();

    try {
      try {
        final cached = await _api.getOptionChain(symbol, expiry: expiry, fast: true);
        if (cached.contracts.isNotEmpty) {
          _applyChain(state, cached);
          notifyListeners();
        }
      } catch (_) {}

      final chain = await _api.getOptionChain(symbol, expiry: expiry);
      if (chain.contracts.isEmpty) {
        state.error = 'No F&O contracts available for ${symbol.toUpperCase()}';
      } else {
        _applyChain(state, chain);
        state.error = null;
      }
    } on ApiException catch (e) {
      if (state.contracts.isEmpty) state.error = e.message;
    } catch (_) {
      if (state.contracts.isEmpty) {
        state.error = 'Could not load F&O chain. Check server connection.';
      }
    }

    state.loading = false;
    notifyListeners();
  }

  void setScreenerSector(String sector) {
    _screenerSector = sector;
    refreshScreener();
  }

  Future<void> refreshAlerts() async {
    try {
      _alerts = await _api.getPriceAlerts();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refreshSipPlans() async {
    try {
      _sipPlans = await _api.getSipPlans();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> addAlert({
    required String symbol,
    required double targetPrice,
    required String condition,
  }) async {
    try {
      final created = await _api.createPriceAlert(
        symbol: symbol,
        targetPrice: targetPrice,
        condition: condition.toLowerCase(),
      );
      _alerts = [created, ..._alerts];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleAlert(String id) async {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index < 0) return;
    final alert = _alerts[index];
    final next = !alert.isActive;
    try {
      final updated = await _api.updatePriceAlert(id, isActive: next);
      _alerts = [..._alerts];
      _alerts[index] = updated;
      notifyListeners();
    } catch (_) {
      _alerts[index] = PriceAlertModel(
        id: alert.id,
        symbol: alert.symbol,
        name: alert.name,
        targetPrice: alert.targetPrice,
        condition: alert.condition,
        isActive: next,
      );
      notifyListeners();
    }
  }

  Future<bool> createSip({
    required String symbol,
    required double monthlyAmount,
    int totalInstallments = 12,
  }) async {
    try {
      final plan = await _api.createSip(
        symbol: symbol,
        monthlyAmount: monthlyAmount,
        totalInstallments: totalInstallments,
      );
      _sipPlans = [plan, ..._sipPlans];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refreshPaperTrades() async {
    try {
      _paperTrades = await _api.getPaperTrades();
      notifyListeners();
    } catch (_) {}
  }

  Future<PaperTradeModel?> placePaperTrade({
    required String symbol,
    required String side,
    required int qty,
  }) async {
    _tradeError = null;
    try {
      final trade = await _api.placePaperTrade(
        symbol: symbol,
        side: side,
        quantity: qty,
      );
      _paperTrades = [trade, ..._paperTrades.where((t) => t.id != trade.id)];
      notifyListeners();
      return trade;
    } catch (e) {
      _tradeError = e is ApiException ? e.message : 'Order failed. Try again.';
      notifyListeners();
      return null;
    }
  }

  Future<void> loadAiChat() async {
    try {
      final history = await _api.getAiHistory();
      if (history.isEmpty) {
        _aiMessages = [
          AiMessageModel(
            role: 'assistant',
            content:
                'Hi! I\'m your BullWave AI Stock Assistant. Ask me about stocks, sectors, or indicators.',
            time: DateTime.now(),
          ),
        ];
      } else {
        _aiMessages = history;
      }
      final suggestions = await _api.getAiSuggestions();
      if (suggestions.isNotEmpty) {
        _aiSuggestions = suggestions;
      }
      _aiError = null;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> clearAiChat() async {
    try {
      await _api.clearAiHistory();
      _aiMessages = [
        AiMessageModel(
          role: 'assistant',
          content: 'Chat cleared. What would you like to know about the markets?',
          time: DateTime.now(),
        ),
      ];
      _aiError = null;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> sendAiMessage(String query, {String symbol = ''}) async {
    if (_isAiLoading) return;
    _aiError = null;
    _aiMessages = [
      ..._aiMessages,
      AiMessageModel(role: 'user', content: query, time: DateTime.now()),
    ];
    _isAiLoading = true;
    notifyListeners();
    try {
      final reply = await _api.sendAiMessage(query, symbol: symbol);
      _aiMessages = [
        ..._aiMessages,
        AiMessageModel(role: 'assistant', content: reply, time: DateTime.now()),
      ];
      _aiError = null;
    } on ApiException catch (e) {
      if (_aiMessages.isNotEmpty && _aiMessages.last.role == 'user') {
        _aiMessages = _aiMessages.sublist(0, _aiMessages.length - 1);
      }
      _aiError = e.message;
    } catch (_) {
      if (_aiMessages.isNotEmpty && _aiMessages.last.role == 'user') {
        _aiMessages = _aiMessages.sublist(0, _aiMessages.length - 1);
      }
      _aiError = 'Could not reach AI assistant. Check server connection and API key in backend/.env.';
    }
    _isAiLoading = false;
    notifyListeners();
  }
}
