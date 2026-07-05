import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api/bullwave_api.dart';
import 'core/api/token_storage.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/provider/auth_provider.dart';
import 'features/kyc/presentation/provider/kyc_flow_provider.dart';
import 'features/home/presentation/provider/home_provider.dart';
import 'features/investment/presentation/provider/investment_provider.dart';
import 'features/portfolio/presentation/provider/portfolio_provider.dart';
import 'features/wallet/presentation/provider/wallet_provider.dart';
import 'features/transactions/presentation/provider/transaction_provider.dart';
import 'features/notifications/presentation/provider/notification_provider.dart';
import 'features/kyc/presentation/provider/kyc_provider.dart';
import 'features/kyc/presentation/provider/bank_verification_provider.dart';
import 'features/profile/presentation/provider/app_provider.dart';
import 'features/profile/presentation/provider/referral_support_provider.dart';
import 'features/stocks/presentation/provider/commodity_provider.dart';
import 'features/stocks/presentation/provider/stock_market_provider.dart';
import 'features/stocks/presentation/provider/stock_portfolio_provider.dart';
import 'features/stocks/presentation/provider/option_trading_provider.dart';
import 'features/stocks/presentation/provider/stock_features_provider.dart';
import 'features/fno/presentation/provider/fno_flow_provider.dart';
import 'features/goals/presentation/provider/goal_plan_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.init();
  await BullwaveApi.instance.init();
  runApp(const BullWaveApp());
}

class BullWaveApp extends StatefulWidget {
  const BullWaveApp({super.key});

  @override
  State<BullWaveApp> createState() => _BullWaveAppState();
}

class _BullWaveAppState extends State<BullWaveApp> {
  late final AuthProvider _authProvider = AuthProvider();
  late final KycFlowProvider _kycFlowProvider = KycFlowProvider();
  late final _router = AppRouter.create(_authProvider, _kycFlowProvider);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _kycFlowProvider),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => InvestmentProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => KycProvider()),
        ChangeNotifierProvider(create: (_) => BankVerificationProvider()),
        ChangeNotifierProvider(create: (_) => SupportProvider()),
        ChangeNotifierProvider(create: (_) => ReferralProvider()),
        ChangeNotifierProvider(create: (_) => StockMarketProvider()),
        ChangeNotifierProvider(create: (_) => CommodityProvider()),
        ChangeNotifierProvider(create: (_) => StockPortfolioProvider()),
        ChangeNotifierProvider(create: (_) => StockFeaturesProvider()),
        ChangeNotifierProvider(create: (_) => OptionTradingProvider()),
        ChangeNotifierProvider(create: (_) => FnoFlowProvider()),
        ChangeNotifierProvider(create: (_) => GoalPlanProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp.router(
            title: 'BullWave Invest',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
