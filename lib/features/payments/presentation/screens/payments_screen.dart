import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/currency_formatter.dart';
import '../../../../domain/entities/payment.dart';

/// Genera pagos a partir del plan financiero actual
final paymentsProvider = Provider<AsyncValue<List<Payment>>>((ref) {
  final debtsAsync = ref.watch(debtsProvider);
  final planAsync = ref.watch(financialPlanProvider);

  final debts = debtsAsync.valueOrNull;
  final plan = planAsync.valueOrNull;

  if (debts == null || plan == null) {
    return const AsyncValue.loading();
  }

  final now = DateTime.now();
  final payments = <Payment>[];

  for (final debt in debts.where((d) => d.isActive)) {
    final plannedDate = DateTime(now.year, now.month, debt.paymentDay);
    final isOverdue = now.isAfter(plannedDate) && now.month == plannedDate.month;

    payments.add(Payment(
      id: '${debt.id}_${now.month}_${now.year}',
      debtId: debt.id,
      debtName: debt.name,
      amount: 0,
      plannedAmount: debt.targetPayment,
      plannedDate: plannedDate,
      status: isOverdue ? PaymentStatus.overdue : PaymentStatus.pending,
      createdAt: now,
      updatedAt: now,
    ));
  }

  payments.sort((a, b) => (a.plannedDate ?? now).compareTo(b.plannedDate ?? now));
  return AsyncValue.data(payments);
});

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final paymentsAsync = ref.watch(paymentsProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showMarkAsPaidSheet(context),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.check_rounded, color: AppColors.textPrimary),
          label: Text(
            l.markAsPaid,
            style: const TextStyle(
              fontFamily: AppConstants.fontSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: CustomScrollView(
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
                  l.paymentsTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            paymentsAsync.when(
              data: (payments) {
                if (payments.isEmpty) {
                  return SliverToBoxAdapter(child: _EmptyPayments(l: l));
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _PaymentRow(payment: payments[index]),
                    childCount: payments.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    e.toString(),
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  void _showMarkAsPaidSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.bottomSheetBorderRadius),
        ),
      ),
      builder: (ctx) {
        final l = S.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l.markAsPaid,
                style: const TextStyle(
                  fontFamily: AppConstants.fontPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.construction_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Payment payment;
  const _PaymentRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.screenHorizontalPadding,
        0,
        AppConstants.screenHorizontalPadding,
        10,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_statusIcon, color: _statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.debtName ?? '',
                  style: const TextStyle(
                    fontFamily: AppConstants.fontPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusLabel(l),
                  style: TextStyle(
                    fontFamily: AppConstants.fontSecondary,
                    fontSize: 12,
                    color: _statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${l.planned}: ${CurrencyFormatter.formatShort(payment.plannedAmount)}',
                style: const TextStyle(
                  fontFamily: AppConstants.fontSecondary,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${l.paid}: ${CurrencyFormatter.formatShort(payment.amount)}',
                style: TextStyle(
                  fontFamily: AppConstants.fontSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: payment.isPaid ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(S l) {
    switch (payment.status) {
      case PaymentStatus.paid:
        return l.paid;
      case PaymentStatus.overdue:
        return l.overdue;
      case PaymentStatus.pending:
        return l.upcoming;
      case PaymentStatus.cancelled:
        return l.upcoming;
    }
  }

  Color get _statusColor {
    switch (payment.status) {
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.overdue:
        return AppColors.danger;
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  IconData get _statusIcon {
    switch (payment.status) {
      case PaymentStatus.paid:
        return Icons.check_circle_rounded;
      case PaymentStatus.overdue:
        return Icons.warning_rounded;
      case PaymentStatus.pending:
        return Icons.schedule_rounded;
      case PaymentStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}

class _EmptyPayments extends StatelessWidget {
  final S l;
  const _EmptyPayments({required this.l});

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
            const Icon(Icons.payments_rounded, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              l.noPaymentsYet,
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
