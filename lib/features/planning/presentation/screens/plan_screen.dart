import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/currency_formatter.dart';
import '../../../../core/formatting/month_names.dart';
import '../../../../domain/entities/plan_month.dart';
import '../../../dashboard/presentation/widgets/month_status_badge.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final plan = ref.watch(financialPlanProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppConstants.screenHorizontalPadding, 16, AppConstants.screenHorizontalPadding, 16),
              child: Text(l.planTitle, style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          plan.when(
            data: (result) {
              if (result.months.isEmpty) return SliverToBoxAdapter(child: _EmptyPlan(l: l));
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _MonthCard(planMonth: result.months[index], isFirst: index == 0),
                  childCount: result.months.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text(l.errorGeneric(e.toString())))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final PlanMonth planMonth;
  final bool isFirst;
  const _MonthCard({required this.planMonth, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(AppConstants.screenHorizontalPadding, isFirst ? 0 : 6, AppConstants.screenHorizontalPadding, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(MonthNames.formatFull(l, planMonth.monthKey), style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              MonthStatusBadge(status: planMonth.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ValueLabel(label: l.income, value: CurrencyFormatter.format(planMonth.incomeTotal), color: AppColors.success)),
              Expanded(child: _ValueLabel(label: l.expenses, value: CurrencyFormatter.format(planMonth.expenseTotal), color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _ValueLabel(label: l.toDebt, value: CurrencyFormatter.format(planMonth.debtPaymentTotal), color: AppColors.primary)),
              Expanded(child: _ValueLabel(label: l.free, value: CurrencyFormatter.format(planMonth.freeMoney), color: planMonth.freeMoney >= 0 ? AppColors.secondary : AppColors.danger)),
            ],
          ),
          if (planMonth.eventsTotal > 0) ...[
            const SizedBox(height: 8),
            _ValueLabel(label: l.events, value: CurrencyFormatter.format(planMonth.eventsTotal), color: AppColors.primary),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.backgroundDark, borderRadius: BorderRadius.circular(8)),
            child: Text(
              l.debtRemaining(CurrencyFormatter.format(planMonth.totalDebtRemaining)),
              style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

}

class _ValueLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ValueLabel({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}

class _EmptyPlan extends StatelessWidget {
  final S l;
  const _EmptyPlan({required this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius), border: Border.all(color: AppColors.cardBorder)),
        child: Column(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(l.addDataForPlan, textAlign: TextAlign.center, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
