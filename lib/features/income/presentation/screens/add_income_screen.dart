import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/date_formatter.dart';
import '../../../../domain/entities/income.dart';
import '../../../../shared/inputs/money_input_field.dart';

class AddIncomeScreen extends ConsumerStatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  IncomeType _type = IncomeType.extra;
  bool _recurring = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = S.of(context);
    final name = _nameController.text.trim();
    final amount = int.tryParse(_amountController.text) ?? 0;

    if (name.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.nameAndValueRequired)));
      return;
    }

    final income = Income(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      type: _type,
      month: DateFormatter.monthKey(DateTime.now()),
      recurring: _recurring,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(repositoryProvider).saveIncome(income);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.addIncome)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameController, style: const TextStyle(color: AppColors.textPrimary), decoration: InputDecoration(labelText: l.incomeName, hintText: l.incomeNameHint)),
            const SizedBox(height: 16),
            MoneyInputField(controller: _amountController, label: l.value),
            const SizedBox(height: 16),
            Text(l.incomeType, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: IncomeType.values.map((type) {
                return ChoiceChip(label: Text(_typeLabel(type, l)), selected: _type == type, onSelected: (v) => setState(() => _type = type), selectedColor: AppColors.success.withOpacity(0.2), labelStyle: TextStyle(color: _type == type ? AppColors.success : AppColors.textSecondary, fontSize: 12));
              }).toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l.recurringMonthly, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              value: _recurring,
              onChanged: (v) => setState(() => _recurring = v),
              activeColor: AppColors.success,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: Text(l.saveIncome))),
          ],
        ),
      ),
    );
  }

  String _typeLabel(IncomeType type, S l) {
    switch (type) {
      case IncomeType.salary: return l.typeSalary;
      case IncomeType.bonus: return l.typeBonus;
      case IncomeType.extra: return l.typeExtra;
    }
  }
}
