import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/routes.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../models/fno_status_model.dart';
import '../provider/fno_flow_provider.dart';

class FnoVerificationScreen extends StatefulWidget {
  const FnoVerificationScreen({super.key});

  @override
  State<FnoVerificationScreen> createState() => _FnoVerificationScreenState();
}

class _FnoVerificationScreenState extends State<FnoVerificationScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FnoFlowProvider>().refresh();
    });
  }

  Future<void> _pickAndSubmit(String proofType) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (file == null || !mounted) return;

    final message = await context.read<FnoFlowProvider>().submitDocument(
          proofType: proofType,
          file: file,
        );
    if (!mounted) return;
    if (message != null) {
      _showSnack(message);
      if (context.read<FnoFlowProvider>().isVerified) {
        context.go(AppRoutes.optionChain);
      }
    }
  }

  Future<void> _verifyPortfolio() async {
    final fno = context.read<FnoFlowProvider>();
    final message = await fno.submitPortfolioHolding();
    if (!mounted) return;
    if (message != null) {
      _showSnack(message);
      if (fno.isVerified) {
        context.go(AppRoutes.optionChain);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(
        title: 'F&O Verification',
        actions: [
          Consumer<FnoFlowProvider>(
            builder: (context, fno, _) => IconButton(
              tooltip: 'Retry',
              onPressed: fno.isLoading ? null : () => context.read<FnoFlowProvider>().refresh(),
              icon: fno.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandPink),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: Consumer<FnoFlowProvider>(
        builder: (context, fno, _) {
          if (fno.isLoading && !fno.statusLoaded) {
            return const Center(child: CircularProgressIndicator(color: AppColors.green));
          }

          final options = fno.status.proofOptions.isNotEmpty
              ? fno.status.proofOptions
              : [
                  FnoProofOptionModel(
                    type: 'bank_statement',
                    label: '6-Month Bank Statement',
                    requiresUpload: true,
                  ),
                  FnoProofOptionModel(type: 'form16', label: 'FORM 16', requiresUpload: true),
                  FnoProofOptionModel(type: 'itr', label: 'ITR Form', requiresUpload: true),
                  FnoProofOptionModel(
                    type: 'portfolio_holding',
                    label: '₹50,000 Portfolio Holding',
                    requiresUpload: false,
                  ),
                ];
          final portfolio = fno.status.portfolioValue;
          final minPortfolio = fno.status.minPortfolioValue;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enable F&O Trading',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose one eligibility proof to access Futures & Options. '
                      'Document proofs are sent to admin for email review.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), height: 1.4),
                    ),
                    if (portfolio > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Portfolio value: ${CurrencyFormatter.format(portfolio)}',
                        style: const TextStyle(color: Color(0xFF86EFAC), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ),
              if (fno.isPending) ...[
                const SizedBox(height: 16),
                _StatusBanner(
                  color: AppColors.yellow,
                  title: 'Under admin review',
                  message:
                      'Your ${fno.status.latestRequest?.proofLabel ?? 'document'} was sent to admin. '
                      'You will be notified once approved and can then trade F&O.',
                ),
              ],
              if (fno.isRejected) ...[
                const SizedBox(height: 16),
                _StatusBanner(
                  color: AppColors.red,
                  title: 'Verification rejected',
                  message: fno.status.latestRequest?.rejectionReason ??
                      'Please choose another proof option and resubmit.',
                ),
              ],
              if (fno.error != null) ...[
                const SizedBox(height: 16),
                _StatusBanner(
                  color: AppColors.red,
                  title: 'Connection error',
                  message: fno.error!,
                  actionLabel: 'Retry',
                  onAction: fno.isLoading ? null : () => context.read<FnoFlowProvider>().refresh(),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Select one option',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 12),
              ...options.map((option) {
                final icon = _iconFor(option.type);
                final color = _colorFor(option.type);
                final subtitle = option.requiresUpload
                    ? 'Upload photo or scan (PDF as image)'
                    : 'Portfolio must be at least ${CurrencyFormatter.format(minPortfolio)}';
                final onTap = fno.isLoading || fno.isPending
                    ? null
                    : () {
                        if (option.requiresUpload) {
                          _pickAndSubmit(option.type);
                        } else {
                          _verifyPortfolio();
                        }
                      };
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProofCard(
                    icon: icon,
                    color: color,
                    title: option.label,
                    subtitle: subtitle,
                    onTap: onTap,
                  ),
                );
              }),
              if (fno.isVerified)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FilledButton(
                    onPressed: () => context.go(AppRoutes.optionChain),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.green,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Open F&O Chain'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'bank_statement':
        return Icons.account_balance_outlined;
      case 'form16':
        return Icons.description_outlined;
      case 'itr':
        return Icons.receipt_long_outlined;
      case 'portfolio_holding':
        return Icons.savings_outlined;
      default:
        return Icons.verified_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'bank_statement':
        return const Color(0xFF6366F1);
      case 'form16':
        return AppColors.blue;
      case 'itr':
        return AppColors.green;
      case 'portfolio_holding':
        return AppColors.yellow;
      default:
        return AppColors.green;
    }
  }
}

class _ProofCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ProofCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: onTap == null ? Colors.grey.shade300 : Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Color color;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatusBanner({
    required this.color,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(message, style: const TextStyle(color: Color(0xFF475569), height: 1.4)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}
