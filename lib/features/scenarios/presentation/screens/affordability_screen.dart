import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/date_formatter.dart';
import '../../../../domain/services/scenario_engine.dart';
import '../../../../app/providers.dart';
import '../../providers/scenario_providers.dart';

class AffordabilityScreen extends ConsumerStatefulWidget {
  const AffordabilityScreen({super.key});

  @override
  ConsumerState<AffordabilityScreen> createState() =>
      _AffordabilityScreenState();
}

class _AffordabilityScreenState extends ConsumerState<AffordabilityScreen> {
  final _amountController = TextEditingController();
  String? _selectedMonth;
  AffordabilityResult? _result;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateFormatter.monthKey(now);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _check() {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0 || _selectedMonth == null) return;

    final plan = ref.read(financialPlanProvider);
    final profile = ref.read(userProfileProvider).valueOrNull;
    final incomes = ref.read(incomesProvider).valueOrNull ?? [];
    final expenses = ref.read(expensesProvider).valueOrNull ?? [];
    final debts = ref.read(debtsProvider).valueOrNull ?? [];
    final events = ref.read(specialEventsProvider).valueOrNull ?? [];

    if (plan.valueOrNull == null || profile == null) return;

    final engine = ref.read(scenarioEngineProvider);
    final now = DateTime.now();

    final result = engine.checkAffordability(
      purchaseAmount: amount,
      purchaseMonth: _selectedMonth!,
      currentPlan: plan.valueOrNull!,
      baseIncome: profile.monthlyIncome,
      baseReserve: profile.defaultReserve,
      incomes: incomes,
      expenses: expenses,
      debts: debts,
      events: events,
      startMonth: DateFormatter.monthKey(now),
    );

    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(
                  AppConstants.screenHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      l.affordabilityTitle,
                      style: const TextStyle(
                        fontFamily: AppConstants.fontPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.sectionSpacing),

                    // Amount input
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontFamily: AppConstants.fontPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: l.purchaseAmount,
                        prefixText: AppConstants.currencyPrefix,
                        prefixStyle: const TextStyle(
                          fontFamily: AppConstants.fontPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Month picker
                    _MonthPicker(
                      selectedMonth: _selectedMonth,
                      onChanged: (month) {
                        setState(() => _selectedMonth = month);
                      },
                    ),
                    const SizedBox(height: AppConstants.sectionSpacing),

                    // Check button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _check,
                        child: Text(
                          l.checkAffordability,
                          style: const TextStyle(
                            fontFamily: AppConstants.fontSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.sectionSpacing),

                    // Result
                    if (_result != null) _AffordabilityResultView(result: _result!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== MONTH PICKER =====

class _MonthPicker extends StatelessWidget {
  final String? selectedMonth;
  final ValueChanged<String> onChanged;

  const _MonthPicker({required this.selectedMonth, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final now = DateTime.now();

    // Generate next 12 months
    final months = List.generate(12, (i) {
      final date = DateTime(now.year, now.month + i);
      return DateFormatter.monthKey(date);
    });

    return DropdownButtonFormField<String>(
      value: selectedMonth,
      decoration: InputDecoration(
        labelText: l.purchaseMonth,
        labelStyle: const TextStyle(
          fontFamily: AppConstants.fontSecondary,
          color: AppColors.textSecondary,
        ),
      ),
      dropdownColor: AppColors.surfaceDark,
      style: const TextStyle(
        fontFamily: AppConstants.fontSecondary,
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      items: months
          .map((m) => DropdownMenuItem(
                value: m,
                child: Text(m),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

// ===== RESULT VIEW =====

class _AffordabilityResultView extends StatelessWidget {
  final AffordabilityResult result;

  const _AffordabilityResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    final Color circleColor;
    final String mainText;
    final List<String> details = [];

    switch (result.level) {
      case AffordabilityLevel.canAfford:
        circleColor = AppColors.success;
        mainText = l.canAfford;
        details.add(
          '${l.freeMoneyAfterPurchase}: ${AppConstants.currencyPrefix}${result.freeMoneyAfter}',
        );
        break;
      case AffordabilityLevel.withReserve:
        circleColor = AppColors.warning;
        mainText = l.canAffordWithReserve;
        if (result.usesReserve) {
          details.add(l.usesReserve);
        }
        if (result.delaysDebtFreeBy > 0) {
          details.add('${l.delaysDebtBy}: ${result.delaysDebtFreeBy} meses');
        }
        details.add(
          '${l.freeMoneyAfterPurchase}: ${AppConstants.currencyPrefix}${result.freeMoneyAfter}',
        );
        break;
      case AffordabilityLevel.cannotAfford:
        circleColor = AppColors.danger;
        mainText = l.cannotAfford;
        if (result.delaysDebtFreeBy > 0) {
          details.add('${l.delaysDebtBy}: ${result.delaysDebtFreeBy} meses');
        }
        details.add(
          '${l.freeMoneyAfterPurchase}: ${AppConstants.currencyPrefix}${result.freeMoneyAfter}',
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.cardInternalPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: circleColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Traffic light circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor.withOpacity(0.15),
              border: Border.all(color: circleColor, width: 3),
            ),
            child: Icon(
              result.level == AffordabilityLevel.canAfford
                  ? Icons.check_rounded
                  : result.level == AffordabilityLevel.withReserve
                      ? Icons.warning_rounded
                      : Icons.close_rounded,
              color: circleColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),

          // Main text
          Text(
            mainText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppConstants.fontPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: circleColor,
            ),
          ),
          const SizedBox(height: 12),

          // Details
          ...details.map(
            (detail) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                detail,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppConstants.fontSecondary,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
