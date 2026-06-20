import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/currency_formatter.dart';
import '../../../../domain/entities/plan_month.dart';

/// Sección de próximos pagos del mes
class NextPaymentsSection extends StatelessWidget {
  final PlanMonth planMonth;

  const NextPaymentsSection({super.key, required this.planMonth});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.paymentsThisMonth, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        if (planMonth.debtPayments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(l.noPaymentsScheduled, style: const TextStyle(fontFamily: AppConstants.fontSecondary, color: AppColors.textSecondary, fontSize: 14)),
          )
        else
          ...planMonth.debtPayments.map((payment) => _PaymentRow(payment: payment)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(label: l.totalToDebt, value: CurrencyFormatter.format(planMonth.debtPaymentTotal), color: AppColors.primary),
              _SummaryItem(label: l.reserve, value: CurrencyFormatter.format(planMonth.reserveTotal), color: AppColors.secondary),
              _SummaryItem(label: l.free, value: CurrencyFormatter.format(planMonth.freeMoney), color: planMonth.freeMoney >= 0 ? AppColors.success : AppColors.danger),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final DebtPaymentDetail payment;
  const _PaymentRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: payment.closesDebt ? AppColors.success.withOpacity(0.15) : AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              payment.closesDebt ? Icons.check_circle_rounded : Icons.credit_card_rounded,
              color: payment.closesDebt ? AppColors.success : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.debtName, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                if (payment.remainingBalance > 0)
                  Text(l.remaining(CurrencyFormatter.format(payment.remainingBalance)), style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, color: AppColors.textSecondary)),
                if (payment.closesDebt)
                  Text(l.closesThisMonth, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.success)),
              ],
            ),
          ),
          Text(CurrencyFormatter.format(payment.amountPaid), style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
