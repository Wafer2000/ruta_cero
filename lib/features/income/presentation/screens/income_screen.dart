import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/currency_formatter.dart';
import '../../../../domain/entities/income.dart';

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final incomesAsync = ref.watch(incomesProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppConstants.screenHorizontalPadding, 16, AppConstants.screenHorizontalPadding, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.incomesTitle, style: Theme.of(context).textTheme.headlineMedium),
                  IconButton(onPressed: () => context.push('/add-income'), icon: const Icon(Icons.add_rounded, color: AppColors.primary)),
                ],
              ),
            ),
          ),
          incomesAsync.when(
            data: (incomes) {
              if (incomes.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(child: Text(l.noIncomesRegistered, style: const TextStyle(color: AppColors.textSecondary))),
                );
              }
              return SliverList(delegate: SliverChildBuilderDelegate((context, index) => _IncomeRow(income: incomes[index]), childCount: incomes.length));
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Text(l.errorGeneric(e.toString()))),
          ),
        ],
      ),
    );
  }
}

class _IncomeRow extends StatelessWidget {
  final Income income;
  const _IncomeRow({required this.income});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(AppConstants.screenHorizontalPadding, 0, AppConstants.screenHorizontalPadding, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
      child: Row(
        children: [
          Icon(
            income.type == IncomeType.salary ? Icons.work_rounded : income.type == IncomeType.bonus ? Icons.card_giftcard_rounded : Icons.attach_money_rounded,
            color: AppColors.success, size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(income.name, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(income.recurring ? l.recurring : income.month, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(CurrencyFormatter.format(income.amount), style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.success)),
        ],
      ),
    );
  }
}
