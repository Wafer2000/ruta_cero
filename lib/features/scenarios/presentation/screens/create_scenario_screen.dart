import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/scenario.dart';
import '../../../../domain/services/financial_engine.dart';
import '../../../../shared/inputs/money_input_field.dart';
import '../../providers/scenario_providers.dart';

class CreateScenarioScreen extends ConsumerStatefulWidget {
  const CreateScenarioScreen({super.key});

  @override
  ConsumerState<CreateScenarioScreen> createState() =>
      _CreateScenarioScreenState();
}

class _CreateScenarioScreenState extends ConsumerState<CreateScenarioScreen> {
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();
  final _reserveController = TextEditingController();
  PaymentStrategy _selectedStrategy = PaymentStrategy.custom;

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    _reserveController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final income = int.tryParse(_incomeController.text.trim());
    final reserve = int.tryParse(_reserveController.text.trim());

    final scenario = Scenario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      strategy: _selectedStrategy,
      overrideIncome: income,
      overrideReserve: reserve,
      createdAt: DateTime.now(),
    );

    ref.read(scenariosListProvider.notifier).add(scenario);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.createScenario,
          style: const TextStyle(
            fontFamily: AppConstants.fontPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                    const SizedBox(height: 8),

                    // Scenario name
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        fontFamily: AppConstants.fontPrimary,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: l.scenarioName,
                        hintText: l.scenarioNameHint,
                        hintStyle: const TextStyle(
                          fontFamily: AppConstants.fontSecondary,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.sectionSpacing),

                    // Strategy picker
                    Text(
                      l.selectStrategy,
                      style: const TextStyle(
                        fontFamily: AppConstants.fontSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StrategyChips(
                      selected: _selectedStrategy,
                      onSelected: (strategy) {
                        setState(() => _selectedStrategy = strategy);
                      },
                    ),
                    const SizedBox(height: AppConstants.sectionSpacing),

                    // Optional income override
                    MoneyInputField(
                      controller: _incomeController,
                      label: l.monthlyIncome,
                    ),
                    const SizedBox(height: 16),

                    // Optional reserve override
                    MoneyInputField(
                      controller: _reserveController,
                      label: l.monthlyReserve,
                    ),
                    const SizedBox(height: AppConstants.sectionSpacing * 1.5),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.buttonBorderRadius,
                            ),
                          ),
                        ),
                        child: Text(
                          l.createScenario,
                          style: const TextStyle(
                            fontFamily: AppConstants.fontSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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

// ===== STRATEGY CHIPS =====

class _StrategyChips extends StatelessWidget {
  final PaymentStrategy selected;
  final ValueChanged<PaymentStrategy> onSelected;

  const _StrategyChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    final strategies = [
      (PaymentStrategy.lowestBalance, l.strategySnowball),
      (PaymentStrategy.highestInterest, l.strategyAvalanche),
      (PaymentStrategy.custom, l.strategyCustom),
      (PaymentStrategy.balanced, l.strategyBalanced),
      (PaymentStrategy.conservative, l.strategyConservative),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: strategies.map((entry) {
        final (strategy, label) = entry;
        final isSelected = strategy == selected;

        return ChoiceChip(
          label: Text(
            label,
            style: TextStyle(
              fontFamily: AppConstants.fontSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onSelected(strategy),
          backgroundColor: AppColors.surfaceDark,
          selectedColor: AppColors.primary,
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : AppColors.cardBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }).toList(),
    );
  }
}
