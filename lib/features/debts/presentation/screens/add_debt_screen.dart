import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../shared/inputs/money_input_field.dart';

class AddDebtScreen extends ConsumerStatefulWidget {
  const AddDebtScreen({super.key});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _minimumController = TextEditingController();
  final _targetController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _availableCreditController = TextEditingController();

  DebtType _type = DebtType.creditCard;
  DebtPriority _priority = DebtPriority.high;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _minimumController.dispose();
    _targetController.dispose();
    _creditLimitController.dispose();
    _availableCreditController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = S.of(context);
    final name = _nameController.text.trim();
    final balance = int.tryParse(_balanceController.text) ?? 0;
    final minimum = int.tryParse(_minimumController.text) ?? 0;
    final target = int.tryParse(_targetController.text) ?? minimum;

    if (name.isEmpty || balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.nameAndBalanceRequired)));
      return;
    }

    CreditCardDetail? cardDetail;
    if (_type == DebtType.creditCard) {
      cardDetail = CreditCardDetail(
        creditLimit: int.tryParse(_creditLimitController.text) ?? 0,
        availableCredit: int.tryParse(_availableCreditController.text) ?? 0,
        cutoffDay: 15,
        paymentDueDay: 5,
      );
    }

    final debt = Debt(
      id: const Uuid().v4(),
      name: name,
      type: _type,
      currentBalance: balance,
      minimumPayment: minimum,
      targetPayment: target,
      priority: _priority,
      status: DebtStatus.active,
      creditCardDetail: cardDetail,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(repositoryProvider).saveDebt(debt);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.addDebt)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameController, style: const TextStyle(color: AppColors.textPrimary), decoration: InputDecoration(labelText: l.debtName, hintText: l.debtNameHint)),
            const SizedBox(height: 16),
            Text(l.debtType, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: DebtType.values.map((type) {
                return ChoiceChip(label: Text(_typeLabel(type, l)), selected: _type == type, onSelected: (v) => setState(() => _type = type), selectedColor: AppColors.primary.withOpacity(0.2), labelStyle: TextStyle(color: _type == type ? AppColors.primary : AppColors.textSecondary, fontSize: 12));
              }).toList(),
            ),
            const SizedBox(height: 16),
            MoneyInputField(controller: _balanceController, label: l.currentBalance),
            const SizedBox(height: 16),
            MoneyInputField(controller: _minimumController, label: l.minimumPayment),
            const SizedBox(height: 16),
            MoneyInputField(controller: _targetController, label: l.targetPayment),
            const SizedBox(height: 16),
            Text(l.priority, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: DebtPriority.values.map((p) {
                return ChoiceChip(label: Text(_priorityLabel(p, l)), selected: _priority == p, onSelected: (v) => setState(() => _priority = p), selectedColor: _priorityColor(p).withOpacity(0.2), labelStyle: TextStyle(color: _priority == p ? _priorityColor(p) : AppColors.textSecondary, fontSize: 12));
              }).toList(),
            ),
            if (_type == DebtType.creditCard) ...[
              const Divider(height: 32),
              Text(l.creditCardData, style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              MoneyInputField(controller: _creditLimitController, label: l.totalCreditLimit),
              const SizedBox(height: 16),
              MoneyInputField(controller: _availableCreditController, label: l.availableCreditLimit),
            ],
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: Text(l.saveDebt))),
          ],
        ),
      ),
    );
  }

  String _typeLabel(DebtType type, S l) {
    switch (type) {
      case DebtType.creditCard: return l.creditCard;
      case DebtType.freeCredit: return l.freeCredit;
      case DebtType.personalLoan: return l.personalLoan;
      case DebtType.installment: return l.installments;
      case DebtType.other: return l.otherDebt;
    }
  }

  String _priorityLabel(DebtPriority p, S l) {
    switch (p) {
      case DebtPriority.high: return l.priorityHigh;
      case DebtPriority.medium: return l.priorityMedium;
      case DebtPriority.low: return l.priorityLow;
    }
  }

  Color _priorityColor(DebtPriority p) {
    switch (p) {
      case DebtPriority.high: return AppColors.danger;
      case DebtPriority.medium: return AppColors.warning;
      case DebtPriority.low: return AppColors.secondary;
    }
  }
}
