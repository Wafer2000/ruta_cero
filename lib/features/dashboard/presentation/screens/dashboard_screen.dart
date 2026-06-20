import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/next_payments_section.dart';
import '../widgets/month_status_badge.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    final plan = ref.watch(financialPlanProvider);
    final totalDebt = ref.watch(totalDebtProvider);

    // Redirigir a onboarding si no hay perfil configurado
    if (profileAsync is AsyncData && profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/onboarding');
      });
      return const SizedBox();
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenHorizontalPadding,
                16,
                AppConstants.screenHorizontalPadding,
                8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.greeting(profile != null ? ', ${profile.name}' : ''),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.appName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                  plan.when(
                    data: (result) {
                      if (result.months.isEmpty) return const SizedBox();
                      return MonthStatusBadge(status: result.months.first.status);
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ],
              ),
            ),
          ),

          // Financial Summary Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenHorizontalPadding,
                vertical: 8,
              ),
              child: plan.when(
                data: (result) => FinancialSummaryCard(
                  totalDebt: totalDebt,
                  debtFreeMonth: result.debtFreeMonth,
                  currentMonthFreeMoney: result.months.isNotEmpty
                      ? result.months.first.freeMoney
                      : 0,
                  monthsRemaining: result.months.length,
                ),
                loading: () => const _LoadingCard(),
                error: (e, _) => _ErrorCard(message: e.toString()),
              ),
            ),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenHorizontalPadding,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.add_rounded,
                      label: l.quickAddExpense,
                      onTap: () => context.push('/add-expense'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.credit_card_rounded,
                      label: l.quickAddDebt,
                      onTap: () => context.push('/add-debt'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.attach_money_rounded,
                      label: l.quickAddIncome,
                      onTap: () => context.push('/add-income'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Next Payments
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenHorizontalPadding,
                vertical: 8,
              ),
              child: plan.when(
                data: (result) {
                  if (result.months.isEmpty) {
                    return _EmptyState(l: l);
                  }
                  return NextPaymentsSection(planMonth: result.months.first);
                },
                loading: () => const SizedBox(height: 100),
                error: (_, __) => const SizedBox(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.secondary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppConstants.fontSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.danger)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final S l;
  const _EmptyState({required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.route_rounded, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            l.configureProfile,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l.addDataHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
