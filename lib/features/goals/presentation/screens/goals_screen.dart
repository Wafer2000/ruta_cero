import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/currency_formatter.dart';
import '../../../../domain/entities/goal.dart';
import '../../providers/goals_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final goals = ref.watch(goalsListProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.screenHorizontalPadding,
                  16,
                  AppConstants.screenHorizontalPadding,
                  8,
                ),
                child: Text(
                  l.goalsTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            if (goals.isEmpty)
              SliverToBoxAdapter(child: _EmptyGoals(l: l))
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _GoalCard(goal: goals[index]),
                  childCount: goals.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-goal'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.screenHorizontalPadding,
        0,
        AppConstants.screenHorizontalPadding,
        AppConstants.cardSpacing,
      ),
      padding: const EdgeInsets.all(AppConstants.cardInternalPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.cardSecondaryBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _categoryColor(goal.category).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(goal.category),
                  color: _categoryColor(goal.category),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontFamily: AppConstants.fontPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _categoryLabel(goal.category, l),
                      style: const TextStyle(
                        fontFamily: AppConstants.fontSecondary,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${goal.progressPercent}%',
                    style: const TextStyle(
                      fontFamily: AppConstants.fontPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  if (goal.estimatedMonthsRemaining > 0)
                    Text(
                      '${goal.estimatedMonthsRemaining} ${l.estimatedMonths}',
                      style: const TextStyle(
                        fontFamily: AppConstants.fontSecondary,
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar with gradient
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: goal.progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(goal.currentAmount),
                style: const TextStyle(
                  fontFamily: AppConstants.fontSecondary,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CurrencyFormatter.format(goal.targetAmount),
                style: const TextStyle(
                  fontFamily: AppConstants.fontSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _categoryColor(GoalCategory cat) {
    switch (cat) {
      case GoalCategory.travel:
        return AppColors.secondary;
      case GoalCategory.technology:
        return AppColors.primary;
      case GoalCategory.business:
        return AppColors.warning;
      case GoalCategory.emergency:
        return AppColors.danger;
      case GoalCategory.gift:
        return const Color(0xFFE879F9);
      case GoalCategory.savings:
        return AppColors.success;
      case GoalCategory.other:
        return AppColors.textSecondary;
    }
  }

  IconData _categoryIcon(GoalCategory cat) {
    switch (cat) {
      case GoalCategory.travel:
        return Icons.flight_rounded;
      case GoalCategory.technology:
        return Icons.laptop_rounded;
      case GoalCategory.business:
        return Icons.business_center_rounded;
      case GoalCategory.emergency:
        return Icons.shield_rounded;
      case GoalCategory.gift:
        return Icons.card_giftcard_rounded;
      case GoalCategory.savings:
        return Icons.savings_rounded;
      case GoalCategory.other:
        return Icons.flag_rounded;
    }
  }

  String _categoryLabel(GoalCategory cat, S l) {
    switch (cat) {
      case GoalCategory.travel:
        return l.catTravel;
      case GoalCategory.technology:
        return l.catTechnology;
      case GoalCategory.business:
        return l.catBusiness;
      case GoalCategory.emergency:
        return l.catEmergency;
      case GoalCategory.gift:
        return l.catGift;
      case GoalCategory.savings:
        return l.catSavings;
      case GoalCategory.other:
        return l.catOther;
    }
  }
}

class _EmptyGoals extends StatelessWidget {
  final S l;
  const _EmptyGoals({required this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.flag_rounded, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              l.noGoalsYet,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppConstants.fontSecondary,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
