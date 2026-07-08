import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/api/refresh_providers.dart';
import '../../../../core/constants/routes.dart';
import '../../../kyc/presentation/provider/kyc_flow_provider.dart';
import '../../../profile/presentation/provider/app_provider.dart';
import '../provider/auth_provider.dart';
import '../widgets/splash_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final auth = context.read<AuthProvider>();
    final app = context.read<AppProvider>();

    final restoreFuture = auth.tryRestoreSession();
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 5)),
      restoreFuture,
    ]);
    if (!mounted) return;

    final restored = results[1] as bool;
    final hasCompletedOnboarding = app.hasCompletedOnboarding;

    if (restored) {
      final kyc = context.read<KycFlowProvider>();
      await kyc.loadStatus();
      if (!mounted) return;

      if (auth.needsProfileSetup) {
        context.go(AppRoutes.completeProfile);
      } else if (kyc.isFullyVerified) {
        unawaited(refreshAllProviders(context));
        context.go(AppRoutes.home);
      } else {
        if (kyc.manualStatus.isPending) {
          context.go(AppRoutes.kycPending);
        } else if (kyc.manualStatus.isRejected) {
          context.go(AppRoutes.kycRejected);
        } else {
          context.go(AppRoutes.kycSubmit);
        }
      }
    } else {
      context.go(
        hasCompletedOnboarding ? AppRoutes.login : AppRoutes.onboarding,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashAnimation();
  }
}
