import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/routes.dart';
import '../../../profile/presentation/provider/app_provider.dart';
import '../../../kyc/presentation/provider/kyc_flow_provider.dart';
import '../../../../core/api/refresh_providers.dart';
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
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final restored = await auth.tryRestoreSession();
    if (!mounted) return;

    final hasCompletedOnboarding =
        context.read<AppProvider>().hasCompletedOnboarding;

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
    return const Scaffold(
      body: SplashAnimation(),
    );
  }
}
