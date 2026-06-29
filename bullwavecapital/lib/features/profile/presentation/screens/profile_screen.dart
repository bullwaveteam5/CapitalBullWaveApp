import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/profile_tile.dart';
import '../../../authentication/presentation/provider/auth_provider.dart';
import '../../../kyc/presentation/provider/kyc_flow_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final colors = context.appColors;

    if (user == null) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    final avatarUrl = ApiConfig.resolveMediaUrl(user.avatarUrl);
    final displayName = user.displayName;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppDecorations.heroCard(context),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.editProfile),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.green.withValues(alpha: 0.15),
                          backgroundImage: avatarUrl.isNotEmpty
                              ? CachedNetworkImageProvider(avatarUrl)
                              : null,
                          child: avatarUrl.isEmpty
                              ? const Icon(Icons.person, size: 40, color: AppColors.green)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (user.city.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(user.city, style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: 4),
                  Text('+91 ${user.phone}', style: Theme.of(context).textTheme.bodyMedium),
                  if (user.email.isNotEmpty)
                    Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      user.bio,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatusBadge(label: 'PAN', status: user.panStatus),
                      const SizedBox(width: 10),
                      _StatusBadge(label: 'KYC', status: user.kycStatus),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.editProfile),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            ProfileTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Name, photo, email, city',
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            ProfileTile(
              icon: Icons.candlestick_chart_outlined,
              title: 'Markets & Stocks',
              onTap: () => context.go(AppRoutes.invest),
            ),
            ProfileTile(
              icon: Icons.star_rounded,
              title: 'Watchlist',
              onTap: () => context.push(AppRoutes.watchlist),
            ),
            ProfileTile(
              icon: Icons.smart_toy_outlined,
              title: 'AI Stock Assistant',
              onTap: () => context.push(AppRoutes.aiAssistant),
            ),
            ProfileTile(
              icon: Icons.notifications_active_outlined,
              title: 'Price Alerts',
              onTap: () => context.push(AppRoutes.priceAlerts),
            ),
            ProfileTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => context.push(AppRoutes.settings),
            ),
            ProfileTile(
              icon: Icons.account_balance_outlined,
              title: 'Bank Details',
              onTap: () => context.push(AppRoutes.bankDetails),
            ),
            ProfileTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => context.push(AppRoutes.notifications),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'More',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            ProfileTile(
              icon: Icons.headset_mic_outlined,
              title: 'Support',
              onTap: () => context.push(AppRoutes.support),
            ),
            ProfileTile(
              icon: Icons.card_giftcard_outlined,
              title: 'Referral',
              onTap: () => context.push(AppRoutes.referral),
            ),
            ProfileTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => context.push(AppRoutes.privacy),
            ),
            ProfileTile(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () => context.push(AppRoutes.terms),
            ),
            ProfileTile(
              icon: Icons.verified_user_outlined,
              title: 'Complete KYC',
              subtitle: user.kycStatus,
              onTap: () => context.push(AppRoutes.kyc),
            ),
            ProfileTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              iconColor: AppColors.error,
              onTap: () async {
                final confirm = await CustomDialog.showConfirm(
                  context,
                  title: 'Logout',
                  message: 'Are you sure you want to logout?',
                  confirmLabel: 'Logout',
                );
                if (confirm == true && context.mounted) {
                  context.read<KycFlowProvider>().reset();
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go(AppRoutes.login);
                }
              },
            ),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final String status;

  const _StatusBadge({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: $status',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
