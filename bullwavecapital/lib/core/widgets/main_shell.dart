import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/kyc/presentation/provider/kyc_flow_provider.dart';
import '../../features/stocks/presentation/provider/stock_portfolio_provider.dart';
import '../constants/routes.dart';
import '../widgets/bottom_navigation.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.invest)) return 1;
    if (location.startsWith(AppRoutes.portfolio)) return 2;
    if (location.startsWith(AppRoutes.wallet)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    final kyc = context.read<KycFlowProvider>();
    final marketsLocked = !kyc.isFullyVerified;

    switch (index) {
      case 0:
        context.go(marketsLocked ? AppRoutes.kycSubmit : AppRoutes.home);
      case 1:
        context.go(marketsLocked ? AppRoutes.kycSubmit : AppRoutes.invest);
      case 2:
        if (!marketsLocked) {
          context.read<StockPortfolioProvider>().ensureLoaded(refreshQuotes: false);
        }
        context.go(marketsLocked ? AppRoutes.kycSubmit : AppRoutes.portfolio);
      case 3:
        context.go(marketsLocked ? AppRoutes.kycSubmit : AppRoutes.wallet);
      case 4:
        context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kyc = context.watch<KycFlowProvider>();
    final marketsLocked = !kyc.isFullyVerified;

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex(context),
        onTap: (index) => _onTap(context, index),
        marketsLocked: marketsLocked,
      ),
    );
  }
}
