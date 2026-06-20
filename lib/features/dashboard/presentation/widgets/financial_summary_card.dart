import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/currency_formatter.dart';
import '../../../../core/formatting/month_names.dart';

/// Hero card: muestra deuda total, fecha de salida y dinero libre
class FinancialSummaryCard extends StatelessWidget {
  final int totalDebt;
  final String? debtFreeMonth;
  final int currentMonthFreeMoney;
  final int monthsRemaining;

  const FinancialSummaryCard({
    super.key,
    required this.totalDebt,
    this.debtFreeMonth,
    required this.currentMonthFreeMoney,
    required this.monthsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.cardInternalPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.glowViolet,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.totalDebt,
                style: const TextStyle(
                  fontFamily: AppConstants.fontSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              if (totalDebt == 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l.debtFree,
                    style: const TextStyle(
                      fontFamily: AppConstants.fontSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(totalDebt),
            style: const TextStyle(
              fontFamily: AppConstants.fontPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AppColors.backgroundDark,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: totalDebt > 0 ? 0.3 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: l.debtFreeDate,
                  value: debtFreeMonth != null
                      ? _formatMonth(debtFreeMonth!, l)
                      : l.calculating,
                  color: AppColors.secondary,
                ),
              ),
              Expanded(
                child: _InfoTile(
                  label: l.freeMoneyToday,
                  value: CurrencyFormatter.formatShort(currentMonthFreeMoney),
                  color: currentMonthFreeMoney >= 0
                      ? AppColors.success
                      : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMonth(String monthKey, S l) {
    return MonthNames.formatShort(l, monthKey);
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 16, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
