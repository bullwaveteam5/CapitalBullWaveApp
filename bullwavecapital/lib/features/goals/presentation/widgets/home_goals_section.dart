import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/goal_plan_model.dart';

class HomeGoalsSection extends StatelessWidget {
  final List<UserGoalPlanModel> goals;
  final VoidCallback? onViewAll;

  const HomeGoalsSection({super.key, required this.goals, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox.shrink();
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Goals', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colors.textPrimary)),
            TextButton(onPressed: onViewAll ?? () => context.push(AppRoutes.goalPlans), child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: goals.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final g = goals[i];
              return _GoalChip(goal: g, onTap: () => context.push('${AppRoutes.goalDetail}?id=${g.id}'));
            },
          ),
        ),
      ],
    );
  }
}

class _GoalChip extends StatelessWidget {
  final UserGoalPlanModel goal;
  final VoidCallback onTap;

  const _GoalChip({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goal.color.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, color: colors.textPrimary)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (goal.progressPercent / 100).clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: goal.color.withValues(alpha: 0.15),
                  color: goal.color,
                ),
              ),
              const Spacer(),
              Text(
                '${CurrencyFormatter.format(goal.accumulatedAmount)} • ${goal.progressPercent.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),
              if (goal.annualReturnRate > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${goal.annualReturnRate.toStringAsFixed(0)}% p.a.',
                  style: const TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void showGoalDueDialog(BuildContext context, UserGoalPlanModel goal) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.savings_rounded, color: goal.color, size: 36),
      title: Text('${goal.title} — installment due'),
      content: Text(
        'Your monthly savings of ${CurrencyFormatter.format(goal.monthlyContribution)} is due. '
        'Pay now to keep your goal on track.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.brandPink),
          onPressed: () {
            Navigator.pop(ctx);
            context.push('${AppRoutes.goalDetail}?id=${goal.id}');
          },
          child: const Text('Pay Now'),
        ),
      ],
    ),
  );
}
