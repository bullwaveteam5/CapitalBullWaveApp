
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/provider/auth_provider.dart';

import '../../features/kyc/presentation/provider/kyc_flow_provider.dart';

import '../../features/authentication/presentation/screens/splash_screen.dart';

import '../../features/authentication/presentation/screens/onboarding_screen.dart';

import '../../features/authentication/presentation/screens/login_screen.dart';

import '../../features/authentication/presentation/screens/otp_screen.dart';

import '../../features/authentication/presentation/screens/complete_profile_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';

import '../../features/investment/presentation/screens/investment_details_screen.dart';

import '../../features/stocks/presentation/screens/stock_markets_screen.dart';

import '../../features/stocks/presentation/screens/stock_detail_screen.dart';

import '../../features/stocks/presentation/screens/watchlist_screen.dart';

import '../../features/stocks/presentation/screens/stock_news_screen.dart';

import '../../features/stocks/presentation/screens/stock_screener_screen.dart';

import '../../features/stocks/presentation/screens/price_alerts_screen.dart';

import '../../features/stocks/presentation/screens/sip_tracker_screen.dart';

import '../../features/stocks/presentation/screens/option_chain_screen.dart';

import '../../features/stocks/presentation/screens/paper_trading_screen.dart';

import '../../features/stocks/presentation/screens/portfolio_analytics_screen.dart';

import '../../features/stocks/presentation/screens/dividend_tracker_screen.dart';

import '../../features/stocks/presentation/screens/ai_assistant_screen.dart';

import '../../features/portfolio/presentation/screens/portfolio_screen.dart';

import '../../features/wallet/presentation/screens/wallet_screen.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';

import '../../features/transactions/presentation/screens/transactions_screen.dart';

import '../../features/notifications/presentation/screens/notifications_screen.dart';

import '../../features/support/presentation/screens/support_screen.dart';

import '../../features/kyc/presentation/screens/kyc_submit_screen.dart';

import '../../features/kyc/presentation/screens/kyc_pending_screen.dart';

import '../../features/kyc/presentation/screens/kyc_rejected_screen.dart';

import '../../features/kyc/presentation/screens/kyc_status_screen.dart';

import '../../features/kyc/presentation/screens/pan_verification_screen.dart';

import '../../features/kyc/presentation/screens/bank_verification_kyc_screen.dart';

import '../../features/kyc/presentation/screens/name_match_screen.dart';

import '../../features/kyc/presentation/screens/kyc_success_screen.dart';

import '../../features/kyc/presentation/screens/bank_verification_screen.dart';

import '../../features/profile/presentation/screens/settings_screen.dart';

import '../../features/profile/presentation/screens/edit_profile_screen.dart';

import '../../features/profile/presentation/screens/referral_screen.dart';

import '../../features/profile/presentation/screens/bank_details_screen.dart';

import '../../features/wallet/presentation/screens/withdraw_screen.dart';

import '../../features/wallet/presentation/screens/deposit_screen.dart';

import '../../features/wallet/presentation/screens/deposit_success_screen.dart';

import '../../features/profile/presentation/screens/privacy_screen.dart';

import '../../features/profile/presentation/screens/terms_screen.dart';

import '../widgets/main_shell.dart';

import '../constants/routes.dart';

import '../constants/dimensions.dart';



class AppRouter {

  AppRouter._();



  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;



  static bool _isPublicAuthRoute(String path) =>

      path == AppRoutes.onboarding ||

      path == AppRoutes.login ||

      path == AppRoutes.otp;



  static bool _isKycOnboardingPath(String path) =>

      path == AppRoutes.kyc ||

      path == AppRoutes.kycStatus ||

      path == AppRoutes.kycSubmit ||

      path == AppRoutes.kycPending ||

      path == AppRoutes.kycRejected ||

      path == AppRoutes.panVerification ||

      path == AppRoutes.bankVerificationKyc ||

      path == AppRoutes.nameMatch ||

      path == AppRoutes.kycSuccess ||

      path == AppRoutes.bankVerification;



  static bool _isProfileSupportPath(String path) =>

      path == AppRoutes.profile ||

      path == AppRoutes.settings ||

      path == AppRoutes.editProfile ||

      path == AppRoutes.support ||

      path == AppRoutes.referral ||

      path == AppRoutes.privacy ||

      path == AppRoutes.terms ||

      path == AppRoutes.notifications ||

      path == AppRoutes.bankDetails;



  static bool _requiresKyc(String path) {

    if (_isKycOnboardingPath(path) || _isProfileSupportPath(path)) return false;

    if (path == AppRoutes.completeProfile || path == AppRoutes.transactions) return false;



    const gated = {

      AppRoutes.home,

      AppRoutes.invest,

      AppRoutes.portfolio,

      AppRoutes.wallet,

      AppRoutes.deposit,

      AppRoutes.depositSuccess,

      AppRoutes.withdraw,

      AppRoutes.investmentDetails,

      AppRoutes.stockDetail,

      AppRoutes.watchlist,

      AppRoutes.stockNews,

      AppRoutes.stockScreener,

      AppRoutes.priceAlerts,

      AppRoutes.sipTracker,

      AppRoutes.optionChain,

      AppRoutes.paperTrading,

      AppRoutes.portfolioAnalytics,

      AppRoutes.dividendTracker,

      AppRoutes.aiAssistant,

    };

    return gated.contains(path);

  }



  static String _manualKycRoute(KycFlowProvider kyc) {
    if (kyc.manualStatus.isVerified) return AppRoutes.home;
    if (kyc.manualStatus.isPending) return AppRoutes.kycPending;
    if (kyc.manualStatus.isRejected) return AppRoutes.kycRejected;
    return AppRoutes.kycSubmit;
  }

  static bool _isManualKycRoute(String path) =>
      path == AppRoutes.kycSubmit ||
      path == AppRoutes.kycPending ||
      path == AppRoutes.kycRejected ||
      path == AppRoutes.kycStatus;

  static String _postAuthDestination(KycFlowProvider kyc) =>
      kyc.isFullyVerified ? AppRoutes.home : _manualKycRoute(kyc);



  static GoRouter create(AuthProvider auth, KycFlowProvider kyc) => GoRouter(

        navigatorKey: _rootNavigatorKey,

        initialLocation: AppRoutes.splash,

        refreshListenable: Listenable.merge([auth, kyc]),

        redirect: (context, state) {

          final path = state.matchedLocation;



          if (path == AppRoutes.splash) return null;



          if (!auth.isAuthenticated) {

            if (_isPublicAuthRoute(path)) return null;

            return AppRoutes.login;

          }



          if (auth.needsProfileSetup) {

            if (path == AppRoutes.completeProfile) return null;

            return AppRoutes.completeProfile;

          }



          if (_isPublicAuthRoute(path) || path == AppRoutes.completeProfile) {
            return _postAuthDestination(kyc);
          }

          if (kyc.isFullyVerified && _isManualKycRoute(path)) {
            return AppRoutes.home;
          }

          if (!kyc.isFullyVerified && _requiresKyc(path)) {

            return _manualKycRoute(kyc);

          }



          return null;

        },

        routes: [

          GoRoute(

            path: AppRoutes.splash,

            builder: (context, state) => const SplashScreen(),

          ),

          GoRoute(

            path: AppRoutes.onboarding,

            builder: (context, state) => const OnboardingScreen(),

          ),

          GoRoute(

            path: AppRoutes.login,

            builder: (context, state) => const LoginScreen(),

          ),

          GoRoute(

            path: AppRoutes.otp,

            builder: (context, state) => const OtpScreen(),

          ),

          GoRoute(

            path: AppRoutes.completeProfile,

            builder: (context, state) => const CompleteProfileScreen(),

          ),

          GoRoute(

            path: AppRoutes.bankVerification,

            builder: (context, state) => const BankVerificationScreen(),

          ),

          ShellRoute(

            navigatorKey: _shellNavigatorKey,

            builder: (context, state, child) => MainShell(child: child),

            routes: [

              GoRoute(

                path: AppRoutes.home,

                pageBuilder: (context, state) => _fadePage(state, const HomeScreen()),

              ),

              GoRoute(

                path: AppRoutes.invest,

                pageBuilder: (context, state) =>

                    _fadePage(state, const StockMarketsScreen()),

              ),

              GoRoute(

                path: AppRoutes.portfolio,

                pageBuilder: (context, state) =>

                    _fadePage(state, const PortfolioScreen()),

              ),

              GoRoute(

                path: AppRoutes.wallet,

                pageBuilder: (context, state) => _fadePage(state, const WalletScreen()),

              ),

              GoRoute(

                path: AppRoutes.profile,

                pageBuilder: (context, state) => _fadePage(state, const ProfileScreen()),

              ),

            ],

          ),

          GoRoute(

            path: AppRoutes.transactions,

            builder: (context, state) => const TransactionsScreen(),

          ),

          GoRoute(

            path: AppRoutes.notifications,

            builder: (context, state) => const NotificationsScreen(),

          ),

          GoRoute(

            path: AppRoutes.support,

            builder: (context, state) => const SupportScreen(),

          ),

          GoRoute(

            path: AppRoutes.kyc,

            builder: (context, state) => const KycStatusScreen(),

          ),

          GoRoute(

            path: AppRoutes.kycStatus,

            builder: (context, state) => const KycStatusScreen(),

          ),

          GoRoute(

            path: AppRoutes.kycSubmit,

            builder: (context, state) => const KycSubmitScreen(),

          ),

          GoRoute(

            path: AppRoutes.kycPending,

            builder: (context, state) => const KycPendingScreen(),

          ),

          GoRoute(

            path: AppRoutes.kycRejected,

            builder: (context, state) => const KycRejectedScreen(),

          ),

          GoRoute(

            path: AppRoutes.panVerification,

            builder: (context, state) => const PanVerificationScreen(),

          ),

          GoRoute(

            path: AppRoutes.bankVerificationKyc,

            builder: (context, state) => const BankVerificationKycScreen(),

          ),

          GoRoute(

            path: AppRoutes.nameMatch,

            builder: (context, state) => const NameMatchScreen(),

          ),

          GoRoute(

            path: AppRoutes.kycSuccess,

            builder: (context, state) => const KycSuccessScreen(),

          ),

          GoRoute(

            path: AppRoutes.settings,

            builder: (context, state) => const SettingsScreen(),

          ),

          GoRoute(

            path: AppRoutes.editProfile,

            builder: (context, state) => const EditProfileScreen(),

          ),

          GoRoute(

            path: AppRoutes.referral,

            builder: (context, state) => const ReferralScreen(),

          ),

          GoRoute(

            path: AppRoutes.withdraw,

            builder: (context, state) => const WithdrawScreen(),

          ),

          GoRoute(

            path: AppRoutes.deposit,

            builder: (context, state) => const DepositScreen(),

          ),

          GoRoute(

            path: AppRoutes.depositSuccess,

            builder: (context, state) => const DepositSuccessScreen(),

          ),

          GoRoute(

            path: AppRoutes.investmentDetails,

            builder: (context, state) => const InvestmentDetailsScreen(),

          ),

          GoRoute(

            path: AppRoutes.bankDetails,

            builder: (context, state) => const BankDetailsScreen(),

          ),

          GoRoute(

            path: AppRoutes.privacy,

            builder: (context, state) => const PrivacyScreen(),

          ),

          GoRoute(

            path: AppRoutes.terms,

            builder: (context, state) => const TermsScreen(),

          ),

          GoRoute(

            path: AppRoutes.stockDetail,

            parentNavigatorKey: _rootNavigatorKey,

            builder: (context, state) {

              final symbol = state.uri.queryParameters['symbol'] ?? 'RELIANCE';

              return StockDetailScreen(symbol: symbol);

            },

          ),

          GoRoute(

            path: AppRoutes.watchlist,

            parentNavigatorKey: _rootNavigatorKey,

            builder: (context, state) => const WatchlistScreen(),

          ),

          GoRoute(

            path: AppRoutes.stockNews,

            parentNavigatorKey: _rootNavigatorKey,

            builder: (context, state) => const StockNewsScreen(),

          ),

          GoRoute(

            path: AppRoutes.stockScreener,

            parentNavigatorKey: _rootNavigatorKey,

            builder: (context, state) => const StockScreenerScreen(),

          ),

          GoRoute(

            path: AppRoutes.priceAlerts,

            parentNavigatorKey: _rootNavigatorKey,

            builder: (context, state) => const PriceAlertsScreen(),

          ),

          GoRoute(

            path: AppRoutes.sipTracker,

            parentNavigatorKey: _rootNavigatorKey,

            builder: (context, state) => const SipTrackerScreen(),

          ),

          GoRoute(

            path: AppRoutes.optionChain,

            parentNavigatorKey: _rootNavigatorKey,

            builder: (context, state) {

              final symbol = state.uri.queryParameters['symbol'] ?? 'NIFTY';

              return OptionChainScreen(symbol: symbol);

            },

          ),

          GoRoute(

            path: AppRoutes.paperTrading,

            parentNavigatorKey: _rootNavigatorKey,

            builder: (context, state) => const PaperTradingScreen(),

          ),

          GoRoute(

            path: AppRoutes.portfolioAnalytics,

            parentNavigatorKey: _rootNavigatorKey,

            builder: (context, state) => const PortfolioAnalyticsScreen(),

          ),

          GoRoute(

            path: AppRoutes.dividendTracker,

            parentNavigatorKey: _rootNavigatorKey,

            builder: (context, state) => const DividendTrackerScreen(),

          ),

          GoRoute(

            path: AppRoutes.aiAssistant,

            parentNavigatorKey: _rootNavigatorKey,

            builder: (context, state) => const AiAssistantScreen(),

          ),

        ],

      );



  static CustomTransitionPage _fadePage(GoRouterState state, Widget child) {

    return CustomTransitionPage(

      key: ValueKey('tab-${state.matchedLocation}'),

      transitionDuration: AppDimensions.transitionFast,

      reverseTransitionDuration: AppDimensions.transitionFast,

      child: child,

      transitionsBuilder: (context, animation, secondaryAnimation, child) {

        final slide = Tween<Offset>(begin: const Offset(0.03, 0), end: Offset.zero)

            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        return FadeTransition(

          opacity: animation,

          child: SlideTransition(position: slide, child: child),

        );

      },

    );

  }

}


