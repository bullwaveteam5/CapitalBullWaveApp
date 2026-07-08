import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';



import '../../../../core/constants/routes.dart';

import '../../../../core/theme/app_theme_extension.dart';

import '../../../../core/theme/colors.dart';

import '../../../../core/utils/formatters.dart';

import '../../../../core/widgets/custom_app_bar.dart';

import '../../../../models/goal_plan_model.dart';

import '../provider/goal_plan_provider.dart';

import '../widgets/goal_return_widgets.dart';



class GoalPlansScreen extends StatefulWidget {

  const GoalPlansScreen({super.key});



  @override

  State<GoalPlansScreen> createState() => _GoalPlansScreenState();

}



class _GoalPlansScreenState extends State<GoalPlansScreen> {

  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      context.read<GoalPlanProvider>().load();

    });

  }



  @override

  Widget build(BuildContext context) {

    final colors = context.appColors;

    return Scaffold(

      backgroundColor: Colors.transparent,

      appBar: const CustomAppBar(title: 'Goal Plans'),

      body: Consumer<GoalPlanProvider>(

        builder: (context, provider, _) {

          if (provider.isLoading) {

            return const Center(child: CircularProgressIndicator(color: AppColors.brandPink));

          }

          return RefreshIndicator(

            color: AppColors.brandPink,

            onRefresh: provider.load,

            child: ListView(

              padding: const EdgeInsets.all(20),

              physics: const AlwaysScrollableScrollPhysics(),

              children: [

                _HeroBanner(returnTiers: provider.returnTiers),

                const SizedBox(height: 20),

                Text('Choose a goal', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colors.textPrimary)),

                const SizedBox(height: 4),

                Text(

                  'House • Education • Marriage • Vehicle • Retirement',

                  style: TextStyle(fontSize: 12, color: colors.textSecondary),

                ),

                const SizedBox(height: 12),

                GridView.count(

                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  crossAxisCount: 2,

                  mainAxisSpacing: 12,

                  crossAxisSpacing: 12,

                  childAspectRatio: 0.92,

                  children: provider.templates.map((t) {

                    return _TemplateCard(

                      template: t,

                      onTap: () => context.push('${AppRoutes.createGoal}?category=${t.category}'),

                    );

                  }).toList(),

                ),

                if (provider.goals.isNotEmpty) ...[

                  const SizedBox(height: 28),

                  Text('Your goals', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: colors.textPrimary)),

                  const SizedBox(height: 12),

                  ...provider.goals.map((g) => _GoalProgressCard(

                        goal: g,

                        onTap: () => context.push('${AppRoutes.goalDetail}?id=${g.id}'),

                      )),

                ],

              ],

            ),

          );

        },

      ),

    );

  }

}



class _HeroBanner extends StatelessWidget {

  final List<GoalReturnTierModel> returnTiers;



  const _HeroBanner({required this.returnTiers});



  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        gradient: LinearGradient(

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [

            const Color(0xFF1E1B4B),

            AppColors.brandPrimary.withValues(alpha: 0.85),

            AppColors.brandPink.withValues(alpha: 0.55),

          ],

        ),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [

          BoxShadow(

            color: AppColors.brandPink.withValues(alpha: 0.2),

            blurRadius: 24,

            offset: const Offset(0, 10),

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Container(

                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

                decoration: BoxDecoration(

                  color: AppColors.green.withValues(alpha: 0.2),

                  borderRadius: BorderRadius.circular(8),

                ),

                child: const Row(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    Icon(Icons.verified_rounded, color: AppColors.green, size: 14),

                    SizedBox(width: 4),

                    Text('Up to 16% p.a.', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w800, fontSize: 11)),

                  ],

                ),

              ),

            ],

          ),

          const SizedBox(height: 14),

          const Text(

            'Smart Goal Investing',

            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, height: 1.15),

          ),

          const SizedBox(height: 8),

          Text(

            'Save monthly for life goals. Earn tiered returns on every installment. Withdraw anytime.',

            style: TextStyle(color: Colors.white.withValues(alpha: 0.82), height: 1.45, fontSize: 13),

          ),

          const SizedBox(height: 18),

          GoalReturnTiersStrip(tiers: returnTiers),

        ],

      ),

    );

  }

}



class _TemplateCard extends StatelessWidget {

  final GoalTemplateModel template;

  final VoidCallback onTap;



  const _TemplateCard({required this.template, required this.onTap});



  @override

  Widget build(BuildContext context) {

    final colors = context.appColors;

    return Material(

      color: Colors.transparent,

      child: InkWell(

        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: Ink(

          decoration: BoxDecoration(

            color: colors.surface,

            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: template.color.withValues(alpha: 0.22)),

          ),

          padding: const EdgeInsets.all(14),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Row(

                children: [

                  Container(

                    padding: const EdgeInsets.all(10),

                    decoration: BoxDecoration(

                      color: template.color.withValues(alpha: 0.12),

                      borderRadius: BorderRadius.circular(14),

                    ),

                    child: Icon(template.iconData, color: template.color, size: 24),

                  ),

                  const Spacer(),

                  const GoalReturnBadge(annualReturnRate: 8, compact: true),

                ],

              ),

              const Spacer(),

              Text(template.name, style: TextStyle(fontWeight: FontWeight.w800, color: template.color, fontSize: 15)),

              const SizedBox(height: 4),

              Text(

                template.tagline,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(fontSize: 11, height: 1.3, color: colors.textSecondary),

              ),

              const SizedBox(height: 8),

              Row(

                children: [

                  Text('Start from ₹500/mo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.textMuted)),

                  const Spacer(),

                  Icon(Icons.arrow_forward_rounded, size: 14, color: template.color),

                ],

              ),

            ],

          ),

        ),

      ),

    );

  }

}



class _GoalProgressCard extends StatelessWidget {

  final UserGoalPlanModel goal;

  final VoidCallback onTap;



  const _GoalProgressCard({required this.goal, required this.onTap});



  @override

  Widget build(BuildContext context) {

    final colors = context.appColors;

    return Padding(

      padding: const EdgeInsets.only(bottom: 12),

      child: Material(

        color: colors.surface,

        borderRadius: BorderRadius.circular(16),

        child: InkWell(

          onTap: onTap,

          borderRadius: BorderRadius.circular(16),

          child: Padding(

            padding: const EdgeInsets.all(16),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Row(

                  children: [

                    Expanded(child: Text(goal.title, style: TextStyle(fontWeight: FontWeight.w800, color: colors.textPrimary))),

                    GoalReturnBadge(annualReturnRate: goal.annualReturnRate, compact: true),

                    if (goal.isDue) ...[

                      const SizedBox(width: 6),

                      Container(

                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),

                        decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),

                        child: const Text('Due', style: TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w700)),

                      ),

                    ],

                  ],

                ),

                const SizedBox(height: 8),

                ClipRRect(

                  borderRadius: BorderRadius.circular(8),

                  child: LinearProgressIndicator(

                    value: (goal.progressPercent / 100).clamp(0, 1),

                    minHeight: 8,

                    backgroundColor: goal.color.withValues(alpha: 0.15),

                    color: goal.color,

                  ),

                ),

                const SizedBox(height: 8),

                Text(

                  '${CurrencyFormatter.format(goal.accumulatedAmount)} of ${CurrencyFormatter.format(goal.targetAmount)} • ${goal.progressPercent.toStringAsFixed(0)}%',

                  style: TextStyle(color: colors.textSecondary, fontSize: 12),

                ),

                if (goal.returnsEarned > 0) ...[

                  const SizedBox(height: 4),

                  Text(

                    '+${CurrencyFormatter.format(goal.returnsEarned)} returns earned',

                    style: const TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w700),

                  ),

                ],

              ],

            ),

          ),

        ),

      ),

    );

  }

}


