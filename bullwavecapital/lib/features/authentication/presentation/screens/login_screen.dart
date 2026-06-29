import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/assets.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _phoneController = TextEditingController(text: auth.phoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.appColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SvgPicture.asset(AppAssets.logo, height: 56),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.appColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppDimensions.paddingXl),
                Text('Phone Number', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDimensions.paddingSm),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.length != 10) {
                      return 'Enter a valid 10 digit mobile number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter 10 digit mobile number',
                    prefixIcon: Container(
                      width: 70,
                      alignment: Alignment.center,
                      child: Text(
                        '+91',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 56),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMd),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: auth.termsAccepted,
                      onChanged: (v) => auth.setTermsAccepted(v ?? false),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => auth.setTermsAccepted(!auth.termsAccepted),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: Theme.of(context).textTheme.bodySmall,
                              children: const [
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingLg),
                PrimaryButton(
                  label: 'Continue',
                  isLoading: auth.isLoading,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    if (!auth.termsAccepted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please accept terms')),
                      );
                      return;
                    }
                    auth.setPhoneNumber(_phoneController.text);
                    final router = GoRouter.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await auth.sendOtp();
                    if (!mounted) return;
                    if (success) {
                      if (auth.devOtp != null) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Dev OTP: ${auth.devOtp} (also in Django terminal)'),
                            duration: const Duration(seconds: 8),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      router.push(AppRoutes.otp);
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(auth.error ?? 'Failed to send OTP'),
                          backgroundColor: AppColors.red,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 6),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
