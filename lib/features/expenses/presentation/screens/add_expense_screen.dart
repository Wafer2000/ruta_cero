import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/expense.dart';
import '../../../../shared/inputs/money_input_field.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.other;

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

    final expense = Expense(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      category: _category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(repositoryProvider).saveExpense(expense);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.addExpense)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameController, style: const TextStyle(color: AppColors.textPrimary), decoration: InputDecoration(labelText: l.expenseName, hintText: l.expenseNameHint)),
            const SizedBox(height: 16),
            MoneyInputField(controller: _amountController, label: l.monthlyValue),
            const SizedBox(height: 16),
            Text(l.category, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.values.map((cat) {
                return ChoiceChip(label: Text(_catLabel(cat, l)), selected: _category == cat, onSelected: (v) => setState(() => _category = cat), selectedColor: AppColors.primary.withOpacity(0.2), labelStyle: TextStyle(color: _category == cat ? AppColors.primary : AppColors.textSecondary, fontSize: 12));
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: Text(l.saveExpense))),
          ],
        ),
      ),
    );
  }

  String _catLabel(ExpenseCategory cat, S l) {
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
