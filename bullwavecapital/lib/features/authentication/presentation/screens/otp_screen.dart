import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/refresh_providers.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/otp_box.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../kyc/presentation/provider/kyc_flow_provider.dart';
import '../provider/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final GlobalKey<ModernOtpInputState> _otpKey = GlobalKey<ModernOtpInputState>();
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isResending = false;
  bool _isVerifying = false;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  String _maskedPhone(String phone) {
    if (phone.length != 10) return phone;
    return '${phone.substring(0, 5)} ${phone.substring(5)}';
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;

    final auth = context.read<AuthProvider>();
    final code = _otp.replaceAll(RegExp(r'\D'), '');
    if (code.length != 6 || auth.isLoading) return;

    if (auth.phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number missing. Go back and enter your number again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final success = await auth.verifyOtp(code);
    if (!mounted) return;

    setState(() => _isVerifying = false);

    if (success) {
      if (auth.needsProfileSetup) {
        router.go(AppRoutes.completeProfile);
      } else {
        final kyc = context.read<KycFlowProvider>();
        await kyc.loadStatus();
        if (!mounted) return;
        if (kyc.isFullyVerified) {
          unawaited(refreshAllProviders(context));
          router.go(AppRoutes.home);
        } else if (kyc.manualStatus.isPending) {
          router.go(AppRoutes.kycPending);
        } else if (kyc.manualStatus.isRejected) {
          router.go(AppRoutes.kycRejected);
        } else {
          router.go(AppRoutes.kycSubmit);
        }
      }
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(auth.error ?? 'Incorrect OTP. Please try again.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.red,
        duration: const Duration(seconds: 5),
      ),
    );
    _otpKey.currentState?.clear();
    setState(() => _otp = '');
  }

  Future<void> _resendOtp() async {
    if (_secondsRemaining > 0 || _isResending) return;

    final auth = context.read<AuthProvider>();
    if (auth.phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Go back and enter your phone number first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isResending = true);

    final sent = await auth.sendOtp();
    if (!mounted) return;

    setState(() => _isResending = false);

    if (sent) {
      _otpKey.currentState?.clear();
      setState(() => _otp = '');
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.devOtp != null
                ? 'New OTP sent. Dev code: ${auth.devOtp}'
                : 'OTP sent to +91 ${auth.phoneNumber}',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Failed to resend OTP'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final colors = context.appColors;
    final canResend = _secondsRemaining == 0 && !_isResending;
    final isBusy = auth.isLoading || _isVerifying;
    final canVerify = _otp.replaceAll(RegExp(r'\D'), '').length == 6 && !isBusy;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: isBusy ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a 6-digit code to',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '+91 ${_maskedPhone(auth.phoneNumber)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 32),
              if (auth.devOtp != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Latest OTP: ${auth.devOtp}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ModernOtpInput(
                key: _otpKey,
                enabled: !isBusy,
                onChanged: (value) => setState(() => _otp = value),
                onCompleted: (_) {
                  if (!_isVerifying && !auth.isLoading) {
                    _verifyOtp();
                  }
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: canResend
                    ? TextButton(
                        onPressed: _resendOtp,
                        child: Text(
                          _isResending ? 'Sending...' : 'Resend OTP',
                          style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Text(
                        'Resend OTP in 0:${_secondsRemaining.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Verify & Continue',
                isLoading: isBusy,
                onPressed: canVerify ? _verifyOtp : null,
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tip: Paste the full 6-digit OTP from SMS or dev banner',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
