import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/currency_formatter.dart';
import '../../../../domain/entities/expense.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final expensesAsync = ref.watch(expensesProvider);
    final totalExpenses = ref.watch(totalFixedExpensesProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppConstants.screenHorizontalPadding, 16, AppConstants.screenHorizontalPadding, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.expensesTitle, style: Theme.of(context).textTheme.headlineMedium),
                  IconButton(onPressed: () => context.push('/add-expense'), icon: const Icon(Icons.add_rounded, color: AppColors.primary)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenHorizontalPadding),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.totalMonthly, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, color: AppColors.textSecondary)),
                    Text(CurrencyFormatter.format(totalExpenses), style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.warning)),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          expensesAsync.when(
            data: (expenses) {
              if (expenses.isEmpty) return SliverToBoxAdapter(child: _EmptyExpenses(l: l));
              return SliverList(delegate: SliverChildBuilderDelegate((context, index) => _ExpenseRow(expense: expenses[index]), childCount: expenses.length));
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

class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  const _ExpenseRow({required this.expense});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(AppConstants.screenHorizontalPadding, 0, AppConstants.screenHorizontalPadding, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: _categoryColor(expense.category).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(_categoryIcon(expense.category), color: _categoryColor(expense.category), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.name, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(_categoryLabel(expense.category, l), style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(CurrencyFormatter.format(expense.amount), style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          if (!expense.active)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
              child: Text(l.paused, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ),
        ],
      ),
    );
  }

  Color _categoryColor(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.housing: return AppColors.primary;
      case ExpenseCategory.food: return AppColors.warning;
      case ExpenseCategory.transport: return AppColors.secondary;
      case ExpenseCategory.utilities: return AppColors.success;
      case ExpenseCategory.subscriptions: return const Color(0xFFE879F9);
      case ExpenseCategory.health: return AppColors.danger;
      case ExpenseCategory.personal: return AppColors.secondary;
      case ExpenseCategory.education: return const Color(0xFF60A5FA);
      case ExpenseCategory.entertainment: return AppColors.warning;
      case ExpenseCategory.other: return AppColors.textSecondary;
    }
  }

  IconData _categoryIcon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.housing: return Icons.home_rounded;
      case ExpenseCategory.food: return Icons.restaurant_rounded;
      case ExpenseCategory.transport: return Icons.directions_car_rounded;
      case ExpenseCategory.utilities: return Icons.flash_on_rounded;
      case ExpenseCategory.subscriptions: return Icons.subscriptions_rounded;
      case ExpenseCategory.health: return Icons.fitness_center_rounded;
      case ExpenseCategory.personal: return Icons.person_rounded;
      case ExpenseCategory.education: return Icons.school_rounded;
      case ExpenseCategory.entertainment: return Icons.movie_rounded;
      case ExpenseCategory.other: return Icons.more_horiz_rounded;
    }
  }

  String _categoryLabel(ExpenseCategory cat, S l) {
    switch (cat) {
      case ExpenseCategory.housing: return l.catHousing;
      case ExpenseCategory.food: return l.catFood;
      case ExpenseCategory.transport: return l.catTransport;
      case ExpenseCategory.utilities: return l.catUtilities;
      case ExpenseCategory.subscriptions: return l.catSubscriptions;
      case ExpenseCategory.health: return l.catHealth;
      case ExpenseCategory.personal: return l.catPersonal;
      case ExpenseCategory.education: return l.catEducation;
      case ExpenseCategory.entertainment: return l.catEntertainment;
      case ExpenseCategory.other: return l.catOther;
    }
  }
}

class _EmptyExpenses extends StatelessWidget {
  final S l;
  const _EmptyExpenses({required this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius), border: Border.all(color: AppColors.cardBorder)),
        child: Column(
          children: [
            const Icon(Icons.receipt_long_rounded, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(l.addFixedExpenses, textAlign: TextAlign.center, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
