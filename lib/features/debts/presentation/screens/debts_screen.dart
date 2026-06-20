import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/currency_formatter.dart';
import '../../../../domain/entities/debt.dart';

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final debtsAsync = ref.watch(debtsProvider);
    final totalDebt = ref.watch(totalDebtProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppConstants.screenHorizontalPadding, 16, AppConstants.screenHorizontalPadding, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.debtsTitle, style: Theme.of(context).textTheme.headlineMedium),
                  IconButton(onPressed: () => context.push('/add-debt'), icon: const Icon(Icons.add_rounded, color: AppColors.primary)),
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
                    Text(l.totalActiveDebt, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, color: AppColors.textSecondary)),
                    Text(CurrencyFormatter.format(totalDebt), style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          debtsAsync.when(
            data: (debts) {
              if (debts.isEmpty) return SliverToBoxAdapter(child: _EmptyDebts(l: l));
              return SliverList(delegate: SliverChildBuilderDelegate((context, index) => _DebtCard(debt: debts[index]), childCount: debts.length));
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

class _DebtCard extends StatelessWidget {
  final Debt debt;
  const _DebtCard({required this.debt});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(AppConstants.screenHorizontalPadding, 0, AppConstants.screenHorizontalPadding, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: _priorityColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(_typeIcon, color: _priorityColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(debt.name, style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(_typeLabel(l), style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyFormatter.format(debt.currentBalance), style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(l.payment(CurrencyFormatter.format(debt.targetPayment)), style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          if (debt.isCreditCard && debt.creditCardDetail != null) ...[
            const SizedBox(height: 12),
            _CreditCardInfo(detail: debt.creditCardDetail!),
          ],
        ],
      ),
    );
  }

  Color get _priorityColor {
    switch (debt.priority) {
      case DebtPriority.high: return AppColors.danger;
      case DebtPriority.medium: return AppColors.primary;
      case DebtPriority.low: return AppColors.secondary;
    }
  }

  IconData get _typeIcon {
    switch (debt.type) {
      case DebtType.creditCard: return Icons.credit_card_rounded;
      case DebtType.freeCredit: return Icons.account_balance_rounded;
      case DebtType.personalLoan: return Icons.handshake_rounded;
      case DebtType.installment: return Icons.shopping_bag_rounded;
      case DebtType.other: return Icons.receipt_rounded;
    }
  }

  String _typeLabel(S l) {
    switch (debt.type) {
      case DebtType.creditCard: return l.creditCard;
      case DebtType.freeCredit: return l.freeCredit;
      case DebtType.personalLoan: return l.personalLoan;
      case DebtType.installment: return l.installments;
      case DebtType.other: return l.otherDebt;
    }
  }
}

class _CreditCardInfo extends StatelessWidget {
  final CreditCardDetail detail;
  const _CreditCardInfo({required this.detail});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.backgroundDark, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MiniInfo(l.creditLimit, CurrencyFormatter.formatShort(detail.creditLimit)),
          _MiniInfo(l.availableCredit, CurrencyFormatter.formatShort(detail.availableCredit)),
          _MiniInfo(l.utilization, '${detail.utilizationPercent}%'),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;
  const _MiniInfo(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _EmptyDebts extends StatelessWidget {
  final S l;
  const _EmptyDebts({required this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius), border: Border.all(color: AppColors.cardBorder)),
        child: Column(
          children: [
            const Icon(Icons.celebration_rounded, size: 40, color: AppColors.success),
            const SizedBox(height: 12),
            Text(l.noDebtsRegistered, textAlign: TextAlign.center, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
