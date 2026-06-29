import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../models/market_index_model.dart';
import '../../models/investment_model.dart';
import '../../models/notification_model.dart';
import '../../models/portfolio_model.dart';
import '../../models/referral_model.dart';
import '../../models/stock_model.dart';
import '../../models/support_model.dart';
import '../../models/transaction_model.dart';
import '../../models/bank_account_model.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'json_parsers.dart';
import 'token_storage.dart';

class BullwaveApi {
  BullwaveApi._();

  static final BullwaveApi instance = BullwaveApi._();
  final _client = ApiClient.instance;

  Future<void> init() => _client.loadToken();

  // ── Auth ──

  Future<String?> sendOtp(String phone) async {
    final normalized = _normalizePhone(phone);
    final data = await _client.post(
      '/auth/send-otp/',
      body: {'phone': normalized},
      auth: false,
      timeout: const Duration(seconds: 20),
    ) as Map<String, dynamic>;
    final dev = data['devOtp'];
    return dev?.toString();
  }

  Future<UserModel> verifyOtp(String phone, String otp) async {
    final normalizedPhone = _normalizePhone(phone);
    final normalizedOtp = otp.replaceAll(RegExp(r'\D'), '');
    final data = await _client.post(
      '/auth/verify-otp/',
      body: {'phone': normalizedPhone, 'otp': normalizedOtp},
      auth: false,
      timeout: const Duration(seconds: 30),
    ) as Map<String, dynamic>;

    final access = data['access'] as String?;
    final refresh = data['refresh'] as String?;
    if (access == null || refresh == null) {
      throw ApiException(500, 'Invalid server response. Please try again.');
    }

    await TokenStorage.saveTokens(access: access, refresh: refresh);
    await _client.setAccessToken(access);
    return parseUser(data['user'] as Map<String, dynamic>);
  }

  static String _normalizePhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    } else if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    await _client.setAccessToken(null);
  }

  Future<UserModel> getProfile() async {
    final data = await _client.get('/users/me/') as Map<String, dynamic>;
    return parseUser(data);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? city,
    String? bio,
    DateTime? dateOfBirth,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (city != null) body['city'] = city;
    if (bio != null) body['bio'] = bio;
    if (dateOfBirth != null) {
      body['date_of_birth'] = dateOfBirth.toIso8601String().split('T').first;
    }
    final data = await _client.patch('/users/me/', body: body) as Map<String, dynamic>;
    return parseUser(data);
  }

  Future<UserModel> completeProfileSetup({
    required String name,
    String? email,
    String? city,
    String? bio,
    DateTime? dateOfBirth,
    String? referralCode,
  }) async {
    final body = <String, dynamic>{'name': name.trim()};
    if (email != null && email.trim().isNotEmpty) body['email'] = email.trim();
    if (city != null && city.trim().isNotEmpty) body['city'] = city.trim();
    if (bio != null && bio.trim().isNotEmpty) body['bio'] = bio.trim();
    if (dateOfBirth != null) {
      body['date_of_birth'] = dateOfBirth.toIso8601String().split('T').first;
    }
    if (referralCode != null && referralCode.trim().isNotEmpty) {
      body['referral_code'] = referralCode.trim().toUpperCase();
    }
    final data =
        await _client.post('/users/me/complete-profile/', body: body) as Map<String, dynamic>;
    return parseUser(data);
  }

  Future<UserModel> uploadAvatar(List<int> bytes, String filename) async {
    final data = await _client.multipart(
      '/users/me/avatar/',
      fields: {},
      files: [
        http.MultipartFile.fromBytes('avatar', bytes, filename: filename),
      ],
    ) as Map<String, dynamic>;
    return parseUser(data);
  }

  Future<UserModel> removeAvatar() async {
    final data = await _client.delete('/users/me/avatar/') as Map<String, dynamic>;
    return parseUser(data);
  }

  // ── Home ──

  Future<Map<String, dynamic>> getHome() async {
    return await _client.get('/home/') as Map<String, dynamic>;
  }

  // ── Portfolio ──

  Future<PortfolioModel> getPortfolio() async {
    final data = await _client.get('/portfolio/') as Map<String, dynamic>;
    return parsePortfolio(data);
  }

  Future<List<AllocationItem>> getAllocations() async {
    return parseList(await _client.get('/portfolio/allocations/'), parseAllocation);
  }

  Future<List<MonthlyEarning>> getEarnings() async {
    return parseList(await _client.get('/portfolio/earnings/'), parseMonthlyEarning);
  }

  // ── Investments ──

  Future<List<InvestmentPlanModel>> getInvestmentPlans() async {
    return parseList(await _client.get('/investment/plans/', auth: false), parseInvestmentPlan);
  }

  Future<List<FaqItem>> getInvestmentFaqs() async {
    final list = parseList(await _client.get('/investment/faqs/', auth: false), (json) {
      return FaqItem(question: json['question'] as String, answer: json['answer'] as String);
    });
    return list;
  }

  Future<InvestmentDetailModel> subscribeInvestment({
    required String planId,
    required double amount,
  }) async {
    final data = await _client.post('/investment/subscribe/', body: {
      'plan_id': planId,
      'amount': amount,
    }) as Map<String, dynamic>;
    return parseInvestmentDetail(data);
  }

  Future<List<InvestmentDetailModel>> getMyInvestments() async {
    return parseList(await _client.get('/investment/my-investments/'), parseInvestmentDetail);
  }

  // ── Wallet ──

  Future<WalletModel> getWallet() async {
    final data = await _client.get('/wallet/') as Map<String, dynamic>;
    return parseWallet(data);
  }

  Future<List<WalletTransaction>> getWalletTransactions() async {
    return parseList(await _client.get('/wallet/transactions/'), parseWalletTransaction);
  }

  Future<void> deposit(double amount) async {
    await _client.post('/wallet/deposit/', body: {'amount': amount});
  }

  Future<void> withdraw(double amount) async {
    await _client.post('/wallet/withdraw/', body: {'amount': amount});
  }

  // ── Transactions ──

  Future<List<TransactionModel>> getTransactions({String? type}) async {
    return parseList(
      await _client.get('/transactions/', query: type != null ? {'type': type} : null),
      parseTransaction,
    );
  }

  // ── Bank & KYC ──

  Future<BankAccountModel?> getBankAccount() async {
    try {
      final data = await _client.get('/bank/') as Map<String, dynamic>;
      return BankAccountModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBankAccount({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String ifsc,
    required String panNumber,
  }) async {
    await _client.post('/bank/', body: {
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc': ifsc,
      'pan_number': panNumber,
    });
  }

  Future<BankVerificationResponse> verifyBankAccount() async {
    final data =
        await _client.post('/bank/verify/') as Map<String, dynamic>;
    return BankVerificationResponse.fromJson(data);
  }

  Future<void> uploadKycDocument(String documentType) async {
    final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);
    await _client.multipart(
      '/kyc/documents/',
      fields: {'document_type': documentType},
      files: [
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: '$documentType.jpg',
        ),
      ],
    );
  }

  Future<void> submitKyc() async {
    await _client.post('/kyc/submit/');
  }

  Future<List<String>> getKycUploadedDocuments() async {
    final list = await _client.get('/kyc/documents/') as List<dynamic>;
    return list
        .map((e) => (e as Map<String, dynamic>)['documentType'] as String? ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // ── Notifications ──

  Future<List<NotificationModel>> getNotifications() async {
    return parseList(await _client.get('/notifications/'), parseNotification);
  }

  Future<void> markNotificationRead(String id) async {
    await _client.patch('/notifications/$id/read/');
  }

  Future<void> markAllNotificationsRead() async {
    await _client.post('/notifications/mark-all-read/');
  }

  // ── Support & Referrals ──

  Future<List<SupportFaq>> getSupportFaqs() async {
    return parseList(await _client.get('/support/faqs/', auth: false), parseSupportFaq);
  }

  Future<List<SupportTicketModel>> getSupportTickets() async {
    return parseList(await _client.get('/support/tickets/'), parseSupportTicket);
  }

  Future<void> createSupportTicket({required String subject, String message = ''}) async {
    await _client.post('/support/tickets/', body: {
      'subject': subject,
      'message': message,
    });
  }

  Future<ReferralModel> getReferrals() async {
    final data = await _client.get('/referrals/') as Map<String, dynamic>;
    return parseReferral(data);
  }

  Future<ApplyReferralResult> applyReferralCode(String code) async {
    final data = await _client.post('/referrals/apply/', body: {'code': code.trim()})
        as Map<String, dynamic>;
    return ApplyReferralResult(
      success: data['success'] as bool? ?? true,
      message: data['message'] as String? ?? 'Referral code applied.',
      rewardCreditedToFriend: data['rewardCreditedToFriend'] as bool? ?? false,
    );
  }

  // ── Stocks ──

  Future<List<StockModel>> searchStocks({String query = '', bool live = false}) async {
    return parseList(
      await _client.get(
        '/stocks/search/',
        query: {'q': query, 'exchange': 'NSE', 'live': live ? '1' : '0'},
      ),
      parseStock,
    );
  }

  Future<({List<StockModel> stocks, List<MarketIndexModel> indices, String updatedAt, String provider})> getLiveMarket({bool fast = true}) async {
    final data = await _client.get(
      '/market/live/',
      query: fast ? {'fast': '1'} : {'fast': '0', 'refresh': '1'},
    ) as Map<String, dynamic>;
    return (
      stocks: parseList(data['stocks'], parseStock),
      indices: parseList(data['indices'], parseMarketIndex),
      updatedAt: data['updatedAt'] as String? ?? '',
      provider: data['provider'] as String? ?? 'live',
    );
  }

  Future<StockModel> getStockQuote(String symbol) async {
    final data =
        await _client.get('/stocks/$symbol/quote/') as Map<String, dynamic>;
    return parseStock(data);
  }

  Future<List<CandleModel>> getCandles(
    String symbol, {
    String interval = '1d',
    bool fast = false,
  }) async {
    return parseList(
      await _client.get(
        '/stocks/$symbol/candles/',
        query: {
          'interval': interval,
          if (fast) 'fast': '1',
        },
        timeout: const Duration(seconds: 60),
      ),
      parseCandle,
    );
  }

  Future<List<StockModel>> getWatchlist() async {
    return parseList(await _client.get('/watchlist/'), parseStock);
  }

  Future<void> addToWatchlist(String symbol) async {
    await _client.post('/watchlist/$symbol/');
  }

  Future<void> removeFromWatchlist(String symbol) async {
    await _client.delete('/watchlist/$symbol/');
  }

  Future<List<StockHoldingModel>> getStockHoldings() async {
    return parseList(await _client.get('/portfolio/holdings/'), parseStockHolding);
  }

  Future<Map<String, dynamic>> getPortfolioOverview({bool refreshQuotes = false}) async {
    return await _client.get(
      '/portfolio/overview/',
      query: {'refresh': refreshQuotes ? '1' : '0'},
      timeout: refreshQuotes ? const Duration(seconds: 90) : const Duration(seconds: 25),
    ) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPortfolioAnalytics() async {
    return await _client.get('/portfolio/analytics/') as Map<String, dynamic>;
  }

  Future<List<StockNewsModel>> getStockNews({String? symbol}) async {
    return parseList(
      await _client.get('/news/', query: symbol != null ? {'symbol': symbol} : null),
      parseStockNews,
    );
  }

  Future<PriceAlertModel> updatePriceAlert(String id, {required bool isActive}) async {
    final data = await _client.patch('/alerts/$id/', body: {
      'is_active': isActive,
    }) as Map<String, dynamic>;
    return parsePriceAlert(data);
  }

  Future<List<PriceAlertModel>> getPriceAlerts() async {
    return parseList(await _client.get('/alerts/'), parsePriceAlert);
  }

  Future<PriceAlertModel> createPriceAlert({
    required String symbol,
    required double targetPrice,
    required String condition,
  }) async {
    final data = await _client.post('/alerts/', body: {
      'symbol': symbol,
      'target_price': targetPrice,
      'condition': condition,
    }) as Map<String, dynamic>;
    return parsePriceAlert(data);
  }

  Future<List<SipPlanModel>> getSipPlans() async {
    return parseList(await _client.get('/sip/'), parseSipPlan);
  }

  Future<SipPlanModel> createSip({
    required String symbol,
    required double monthlyAmount,
    int totalInstallments = 12,
  }) async {
    final data = await _client.post('/sip/', body: {
      'symbol': symbol,
      'monthly_amount': monthlyAmount,
      'total_installments': totalInstallments,
    }) as Map<String, dynamic>;
    return parseSipPlan(data);
  }

  Future<OptionChainResponse> getOptionChain(String symbol, {String? expiry, bool fast = false}) async {
    final data = await _client.get(
      '/options/$symbol/chain/',
      query: {
        if (expiry != null) 'expiry': expiry,
        if (fast) 'fast': '1',
      },
      timeout: const Duration(seconds: 45),
    ) as Map<String, dynamic>;
    return OptionChainResponse(
      symbol: data['symbol'] as String? ?? symbol,
      underlyingValue: _parseDouble(data['underlyingValue']),
      expiryDates: (data['expiryDates'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      selectedExpiry: data['selectedExpiry'] as String? ?? '',
      contracts: parseList(data['contracts'], parseOptionContract),
    );
  }

  double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim()) ?? 0;
    return 0;
  }

  Future<List<PaperTradeModel>> getPaperTrades() async {
    return parseList(await _client.get('/paper-trading/orders/'), parsePaperTrade);
  }

  Future<PaperTradeModel> placePaperTrade({
    required String symbol,
    required String side,
    required int quantity,
  }) async {
    final data = await _client.post('/paper-trading/orders/', body: {
      'symbol': symbol,
      'side': side,
      'quantity': quantity,
    }) as Map<String, dynamic>;
    return parsePaperTrade(data);
  }

  Future<({List<ScreenerStockModel> results, List<String> sectors})> getScreener({
    String? sector,
    String sort = 'market_cap',
  }) async {
    final data = await _client.get(
      '/screener/',
      query: {
        if (sector != null && sector != 'All') 'sector': sector,
        'sort': sort,
      },
    ) as Map<String, dynamic>;
    final results = parseList(data['results'], parseScreenerStock);
    final sectors = (data['sectors'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    return (results: results, sectors: sectors);
  }

  Future<List<DividendModel>> getDividends({bool sync = true}) async {
    return parseList(
      await _client.get('/dividends/', query: {if (!sync) 'sync': 'false'}),
      parseDividend,
    );
  }

  Future<String> sendAiMessage(String message, {String symbol = ''}) async {
    final data = await _client.post(
      '/ai/stock-assistant/',
      body: {
        'message': message,
        'symbol': symbol,
      },
      timeout: const Duration(seconds: 120),
    ) as Map<String, dynamic>;
    return data['content'] as String? ?? '';
  }

  Future<List<AiMessageModel>> getAiHistory() async {
    return parseList(await _client.get('/ai/history/'), parseAiMessage);
  }

  Future<void> clearAiHistory() async {
    await _client.delete('/ai/history/');
  }

  Future<List<String>> getAiSuggestions() async {
    final data = await _client.get('/ai/suggestions/') as Map<String, dynamic>;
    return (data['suggestions'] as List<dynamic>? ?? [])
        .map((item) => item.toString())
        .toList();
  }
}
