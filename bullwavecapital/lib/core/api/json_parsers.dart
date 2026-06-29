import '../../models/investment_model.dart';
import '../../models/market_index_model.dart';
import '../../models/notification_model.dart';
import '../../models/portfolio_model.dart';
import '../../models/referral_model.dart';
import '../../models/stock_model.dart';
import '../../models/support_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import '../utils/formatters.dart';

double _num(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim()) ?? 0;
  return 0;
}

int _int(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  if (v is String) {
    final parsed = int.tryParse(v.trim());
    if (parsed != null) return parsed;
    return double.tryParse(v.trim())?.toInt() ?? 0;
  }
  return 0;
}
DateTime _date(dynamic v) {
  if (v == null) return DateTime.now();
  final s = v.toString().trim();
  if (s.length <= 10) return DateTime.parse(s);
  return DateTime.parse(s);
}

UserModel parseUser(Map<String, dynamic> json) => UserModel.fromJson(json);

PortfolioModel parsePortfolio(Map<String, dynamic> json) => PortfolioModel(
      totalInvestment: _num(json['totalInvestment']),
      currentValue: _num(json['currentValue']),
      monthlyProfit: _num(json['monthlyProfit']),
      totalProfit: _num(json['totalProfit']),
      growthPercent: _num(json['growthPercent']),
      dayPnl: _num(json['dayPnl']),
      dayPnlPercent: _num(json['dayPnlPercent']),
      holdingsCount: _int(json['holdingsCount']),
      stocksInvested: _num(json['stocksInvested']),
      stocksValue: _num(json['stocksValue']),
    );

PortfolioSummaryModel parsePortfolioSummary(Map<String, dynamic> json) =>
    PortfolioSummaryModel(
      totalInvested: _num(json['totalInvested']),
      currentValue: _num(json['currentValue']),
      totalPnl: _num(json['totalPnl']),
      totalPnlPercent: _num(json['totalPnlPercent']),
      dayPnl: _num(json['dayPnl']),
      dayPnlPercent: _num(json['dayPnlPercent']),
      holdingsCount: _int(json['holdingsCount']),
    );

SectorAllocationItem parseSectorAllocation(Map<String, dynamic> json) =>
    SectorAllocationItem(
      label: json['label'] as String? ?? '',
      value: _num(json['value']),
      percentage: _num(json['percentage']),
      colorValue: _int(json['colorValue']),
    );

WalletModel parseWallet(Map<String, dynamic> json) => WalletModel(
      balance: _num(json['balance']),
      bankName: json['bankName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      ifsc: json['ifsc'] as String? ?? '',
    );

WalletTransaction parseWalletTransaction(Map<String, dynamic> json) =>
    WalletTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      amount: _num(json['amount']),
      date: _date(json['date']),
      status: json['status'] as String? ?? '',
    );

TransactionModel parseTransaction(Map<String, dynamic> json) {
  TransactionType type;
  switch (json['type'] as String? ?? '') {
    case 'profit':
      type = TransactionType.profit;
      break;
    case 'withdrawal':
      type = TransactionType.withdrawal;
      break;
    default:
      type = TransactionType.investment;
  }

  TransactionStatus status;
  switch (json['status'] as String? ?? '') {
    case 'pending':
      status = TransactionStatus.pending;
      break;
    case 'failed':
      status = TransactionStatus.failed;
      break;
    default:
      status = TransactionStatus.completed;
  }

  return TransactionModel(
    id: json['id']?.toString() ?? '',
    referenceId: json['referenceId'] as String? ?? '',
    type: type,
    status: status,
    amount: _num(json['amount']),
    date: _date(json['date']),
    description: json['description'] as String? ?? '',
  );
}

InvestmentPlanModel parseInvestmentPlan(Map<String, dynamic> json) =>
    InvestmentPlanModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      minimumInvestment: _num(json['minimumInvestment']),
      monthlyReturnRate: _num(json['monthlyReturnRate']),
      annualReturnRate: _num(json['annualReturnRate']),
      description: json['description'] as String? ?? '',
      isFeatured: json['isFeatured'] as bool? ?? false,
    );

InvestmentDetailModel parseInvestmentDetail(Map<String, dynamic> json) =>
    InvestmentDetailModel(
      id: json['id']?.toString() ?? '',
      amount: _num(json['amount']),
      date: _date(json['date']),
      monthlyReturn: _num(json['monthlyReturn']),
      status: json['status'] as String? ?? '',
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );

MarketIndexModel parseMarketIndex(Map<String, dynamic> json) => MarketIndexModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      shortName: json['shortName'] as String? ?? '',
      value: _num(json['value']),
      change: _num(json['change']),
      changePercent: _num(json['changePercent']),
    );

AllocationItem parseAllocation(Map<String, dynamic> json) => AllocationItem(
      label: json['label'] as String? ?? '',
      percentage: _num(json['percentage']),
      colorValue: _int(json['colorValue']),
    );

MonthlyEarning parseMonthlyEarning(Map<String, dynamic> json) => MonthlyEarning(
      month: json['month'] as String? ?? '',
      amount: _num(json['amount']),
    );

NotificationModel parseNotification(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      date: _date(json['date']),
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String? ?? 'general',
    );

SupportFaq parseSupportFaq(Map<String, dynamic> json) => SupportFaq(
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );

SupportTicketModel parseSupportTicket(Map<String, dynamic> json) =>
    SupportTicketModel(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: _date(json['createdAt']),
    );

ReferralModel parseReferral(Map<String, dynamic> json) => ReferralModel(
      code: json['code'] as String? ?? '',
      totalReferrals: _int(json['totalReferrals']),
      pendingReferrals: _int(json['pendingReferrals']),
      totalRewards: _num(json['totalRewards']),
      rewardPerReferral: _num(json['rewardPerReferral']),
      shareMessage: json['shareMessage'] as String? ?? '',
      hasAppliedReferral: json['hasAppliedReferral'] as bool? ?? false,
      appliedReferralCode: json['appliedReferralCode'] as String? ?? '',
      rewardsHistory: (json['rewardsHistory'] as List<dynamic>? ?? [])
          .map((e) => parseReferralReward(e as Map<String, dynamic>))
          .toList(),
      referredFriends: (json['referredFriends'] as List<dynamic>? ?? [])
          .map((e) => parseReferredFriend(e as Map<String, dynamic>))
          .toList(),
    );

ReferralReward parseReferralReward(Map<String, dynamic> json) => ReferralReward(
      friendName: json['friendName'] as String? ?? '',
      amount: _num(json['amount']),
      date: _date(json['date']),
    );

ReferredFriend parseReferredFriend(Map<String, dynamic> json) => ReferredFriend(
      name: json['name'] as String? ?? '',
      joinedAt: _date(json['joinedAt']),
      status: json['status'] as String? ?? 'pending',
    );

StockModel parseStock(Map<String, dynamic> json) => StockModel(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      exchange: json['exchange'] as String? ?? 'NSE',
      sector: json['sector'] as String? ?? '',
      ltp: _num(json['ltp']),
      change: _num(json['change']),
      changePercent: _num(json['changePercent']),
      open: _num(json['open']),
      high: _num(json['high']),
      low: _num(json['low']),
      previousClose: _num(json['previousClose']),
      volume: _int(json['volume']),
      marketCapCr: _num(json['marketCapCr']),
      pe: _num(json['pe']),
      eps: _num(json['eps']),
      week52High: _num(json['week52High']),
      week52Low: _num(json['week52Low']),
    );

CandleModel parseCandle(Map<String, dynamic> json) => CandleModel(
      time: _date(json['time']),
      open: _num(json['open']),
      high: _num(json['high']),
      low: _num(json['low']),
      close: _num(json['close']),
      volume: _int(json['volume']),
    );

StockHoldingModel parseStockHolding(Map<String, dynamic> json) =>
    StockHoldingModel(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sector: json['sector'] as String? ?? '',
      exchange: json['exchange'] as String? ?? 'NSE',
      quantity: _int(json['quantity']),
      avgPrice: _num(json['avgPrice']),
      ltp: _num(json['ltp']),
      change: _num(json['change']),
      changePercent: _num(json['changePercent']),
      dayPnl: _num(json['dayPnl']),
    );

StockNewsModel parseStockNews(Map<String, dynamic> json) => StockNewsModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      source: json['source'] as String? ?? '',
      publishedAt: _date(json['publishedAt']),
      relatedSymbols: (json['relatedSymbols'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: json['category'] as String? ?? 'market',
      url: json['url'] as String? ?? '',
    );

PriceAlertModel parsePriceAlert(Map<String, dynamic> json) => PriceAlertModel(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      targetPrice: _num(json['targetPrice']),
      condition: json['condition'] as String? ?? 'above',
      isActive: json['isActive'] as bool? ?? true,
    );

SipPlanModel parseSipPlan(Map<String, dynamic> json) => SipPlanModel(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      monthlyAmount: _num(json['monthlyAmount']),
      installmentsDone: _int(json['installmentsDone']),
      totalInstallments: _int(json['totalInstallments']),
      totalInvested: _num(json['totalInvested']),
      currentValue: _num(json['currentValue']),
      nextDate: DateFormatter.parseDateOnly(json['nextDate'] as String? ?? ''),
    );

OptionContractModel parseOptionContract(Map<String, dynamic> json) =>
    OptionContractModel(
      symbol: json['symbol'] as String? ?? '',
      strike: _num(json['strike']),
      type: json['type'] as String? ?? '',
      ltp: _num(json['ltp']),
      change: _num(json['change']),
      oi: _int(json['oi']),
      volume: _int(json['volume']),
      expiry: _date(json['expiry']),
    );

PaperTradeModel parsePaperTrade(Map<String, dynamic> json) => PaperTradeModel(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol'] as String? ?? '',
      stockName: json['stockName'] as String? ?? '',
      side: json['side'] as String? ?? '',
      quantity: _int(json['quantity']),
      price: _num(json['price']),
      time: _date(json['time']),
      status: json['status'] as String? ?? '',
      orderValue: _num(json['orderValue']),
      avgCost: json['avgCost'] != null ? _num(json['avgCost']) : null,
      realizedPnl: json['realizedPnl'] != null ? _num(json['realizedPnl']) : null,
      realizedPnlPercent:
          json['realizedPnlPercent'] != null ? _num(json['realizedPnlPercent']) : null,
      holdingQty: json['holdingQty'] != null ? _int(json['holdingQty']) : null,
      holdingAvgPrice:
          json['holdingAvgPrice'] != null ? _num(json['holdingAvgPrice']) : null,
      unrealizedPnl: json['unrealizedPnl'] != null ? _num(json['unrealizedPnl']) : null,
      ltp: _num(json['ltp']),
    );

DividendModel parseDividend(Map<String, dynamic> json) => DividendModel(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amountPerShare: _num(json['amountPerShare']),
      exDate: DateFormatter.parseDateOnly(json['exDate'] as String? ?? ''),
      paymentDate: DateFormatter.parseDateOnly(json['paymentDate'] as String? ?? ''),
      sharesHeld: _int(json['sharesHeld']),
      status: json['status'] as String? ?? '',
    );

ScreenerStockModel parseScreenerStock(Map<String, dynamic> json) =>
    ScreenerStockModel(
      stock: parseStock(json['stock'] as Map<String, dynamic>),
      roe: _num(json['roe']),
      debtToEquity: _num(json['debtToEquity']),
      revenueGrowth: _num(json['revenueGrowth']),
    );

AiMessageModel parseAiMessage(Map<String, dynamic> json) => AiMessageModel(
      role: json['role'] as String? ?? 'assistant',
      content: json['content'] as String? ?? '',
      time: _date(json['createdAt'] ?? json['time']),
    );

List<T> parseList<T>(dynamic data, T Function(Map<String, dynamic>) parser) {
  if (data is! List) return [];
  final out = <T>[];
  for (final item in data) {
    if (item is! Map<String, dynamic>) continue;
    try {
      out.add(parser(item));
    } catch (_) {}
  }
  return out;
}
