import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/currency_formatter.dart';
import '../../providers/goals_providers.dart';

class DisciplineScreen extends ConsumerWidget {
  const DisciplineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final dailyBudget = ref.watch(dailyBudgetProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final debtsAsync = ref.watch(debtsProvider);

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1;
    final reserve = profile?.defaultReserve ?? 0;

    // Check credit card utilization
    final debts = debtsAsync.valueOrNull ?? [];
    final creditCards = debts.where((d) => d.isCreditCard && d.creditCardDetail != null).toList();
    final hasHighUtilization = creditCards.any(
      (d) => d.creditCardDetail!.utilizationPercent > 70,
    );

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
                  l.disciplineTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),

            // Daily budget - big number
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenHorizontalPadding,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.cardInternalPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glowCyan,
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        l.dailyBudget,
                        style: const TextStyle(
                          fontFamily: AppConstants.fontSecondary,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(dailyBudget),
                        style: const TextStyle(
                          fontFamily: AppConstants.fontPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.dailyBudgetDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppConstants.fontSecondary,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Days remaining & reserve
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenHorizontalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: l.daysRemaining,
                        value: '$daysRemaining',
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        label: l.reserveAvailable,
                        value: CurrencyFormatter.formatShort(reserve),
                        icon: Icons.shield_rounded,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Credit card status
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenHorizontalPadding,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(AppConstants.cardSecondaryBorderRadius),
                    border: Border.all(
                      color: hasHighUtilization
                          ? AppColors.warning.withOpacity(0.4)
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.credit_card_rounded,
                        color: hasHighUtilization
                            ? AppColors.warning
                            : AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hasHighUtilization
                              ? l.creditCardWarning
                              : l.creditCardSafe,
                          style: TextStyle(
                            fontFamily: AppConstants.fontSecondary,
                            fontSize: 13,
                            color: hasHighUtilization
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Emergency fund targets
            SliverToBoxAdapter(
              child: _EmergencyFundSection(ref: ref, l: l),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Motivational message
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenHorizontalPadding,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.secondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.cardSecondaryBorderRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.warning,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.keepItUp,
                          style: const TextStyle(
                            fontFamily: AppConstants.fontSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.cardSecondaryBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppConstants.fontPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppConstants.fontSecondary,
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyFundSection extends StatelessWidget {
  final WidgetRef ref;
  final S l;

  const _EmergencyFundSection({required this.ref, required this.l});

  @override
  Widget build(BuildContext context) {
    final targets = ref.watch(emergencyFundProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenHorizontalPadding,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.cardInternalPadding),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppConstants.cardSecondaryBorderRadius),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.emergencyFundTitle,
              style: const TextStyle(
                fontFamily: AppConstants.fontPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            _FundRow(
              label: l.emergencyMinimum,
              amount: targets.minimum,
              color: AppColors.warning,
            ),
            const SizedBox(height: 10),
            _FundRow(
              label: l.emergencyRecommended,
              amount: targets.recommended,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 10),
            _FundRow(
              label: l.emergencyIdeal,
              amount: targets.ideal,
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _FundRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;

  const _FundRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppConstants.fontSecondary,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontFamily: AppConstants.fontPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
