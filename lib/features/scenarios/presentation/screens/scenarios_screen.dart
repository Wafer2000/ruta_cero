import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/scenario.dart';
import '../../../../domain/services/financial_engine.dart';
import '../../providers/scenario_providers.dart';

class ScenariosScreen extends ConsumerWidget {
  const ScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final scenarios = ref.watch(scenariosListProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      l.scenariosTitle,
                      style: const TextStyle(
                        fontFamily: AppConstants.fontPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.compareScenarios,
                      style: const TextStyle(
                        fontFamily: AppConstants.fontSecondary,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.sectionSpacing),
                  ],
                ),
              ),
            ),
            if (scenarios.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.layers_outlined,
                        size: 56,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.noScenariosYet,
                        style: const TextStyle(
                          fontFamily: AppConstants.fontSecondary,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenHorizontalPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final scenario = scenarios[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.cardSpacing,
                        ),
                        child: _ScenarioCard(scenario: scenario),
                      );
                    },
                    childCount: scenarios.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-scenario'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.textPrimary),
        label: Text(
          l.createScenario,
          style: const TextStyle(
            fontFamily: AppConstants.fontSecondary,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ===== SCENARIO CARD =====

class _ScenarioCard extends ConsumerWidget {
  final Scenario scenario;

  const _ScenarioCard({required this.scenario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.cardInternalPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Strategy badge
          Row(
            children: [
              Expanded(
                child: Text(
                  scenario.name,
                  style: const TextStyle(
                    fontFamily: AppConstants.fontPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _StrategyBadge(strategy: scenario.strategy),
            ],
          ),
          const SizedBox(height: 12),

          // Debt-free info
          Row(
            children: [
              const Icon(
                Icons.flag_rounded,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 6),
              Text(
                l.debtFreeIn,
                style: const TextStyle(
                  fontFamily: AppConstants.fontSecondary,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Compare button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showComparison(context, ref, scenario),
              icon: const Icon(Icons.compare_arrows, size: 18),
              label: Text(
                l.compareScenarios,
                style: const TextStyle(
                  fontFamily: AppConstants.fontSecondary,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: BorderSide(color: AppColors.secondary.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonBorderRadius,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComparison(BuildContext context, WidgetRef ref, Scenario scenario) {
    final engine = ref.read(scenarioEngineProvider);
    final profile = ref.read(userProfileProvider).valueOrNull;
    final incomes = ref.read(incomesProvider).valueOrNull ?? [];
    final expenses = ref.read(expensesProvider).valueOrNull ?? [];
    final debts = ref.read(debtsProvider).valueOrNull ?? [];
    final events = ref.read(specialEventsProvider).valueOrNull ?? [];
    final currentPlan = ref.read(financialPlanProvider).valueOrNull;

    if (profile == null || currentPlan == null) return;

    final now = DateTime.now();
    final startMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final scenarioPlan = engine.simulate(
      scenario: scenario,
      baseIncome: profile.monthlyIncome,
      baseReserve: profile.defaultReserve,
      incomes: incomes,
      expenses: expenses,
      debts: debts,
      events: events,
      startMonth: startMonth,
    );

    final comparison = engine.compare(
      currentPlan: currentPlan,
      scenarioPlan: scenarioPlan,
      scenarioName: scenario.name,
    );

    final l = S.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.bottomSheetBorderRadius)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(scenario.name, style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _ComparisonRow(label: l.currentPlan, value: comparison.currentDebtFreeMonth),
            _ComparisonRow(label: scenario.name, value: comparison.scenarioDebtFreeMonth),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: comparison.isBetter ? AppColors.success.withOpacity(0.1) : comparison.isWorse ? AppColors.danger.withOpacity(0.1) : AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                comparison.isBetter
                    ? '${comparison.monthsDifference.abs()} ${l.monthsEarlier}'
                    : comparison.isWorse
                        ? '${comparison.monthsDifference} ${l.monthsLater}'
                        : l.sameDate,
                style: TextStyle(
                  fontFamily: AppConstants.fontPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: comparison.isBetter ? AppColors.success : comparison.isWorse ? AppColors.danger : AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ===== STRATEGY BADGE =====

class _StrategyBadge extends StatelessWidget {
  final PaymentStrategy strategy;

  const _StrategyBadge({required this.strategy});

  String _label(S l) {
    switch (strategy) {
      case PaymentStrategy.lowestBalance:
        return l.strategySnowball;
      case PaymentStrategy.highestInterest:
        return l.strategyAvalanche;
      case PaymentStrategy.custom:
        return l.strategyCustom;
      case PaymentStrategy.balanced:
        return l.strategyBalanced;
      case PaymentStrategy.conservative:
        return l.strategyConservative;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label(l),
        style: const TextStyle(
          fontFamily: AppConstants.fontSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}


class _ComparisonRow extends StatelessWidget {
  final String label;
  final String value;
  const _ComparisonRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
