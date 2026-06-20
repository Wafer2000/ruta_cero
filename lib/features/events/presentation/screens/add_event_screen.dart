import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/date_formatter.dart';
import '../../../../domain/entities/special_event.dart';
import '../../../../shared/inputs/money_input_field.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  EventCategory _category = EventCategory.other;
  bool _flexible = false;
  late String _selectedMonth;
  late List<String> _monthOptions;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _monthOptions = List.generate(12, (i) {
      final date = DateTime(now.year, now.month + i, 1);
      return DateFormatter.monthKey(date);
    });
    _selectedMonth = _monthOptions.first;
  }

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

    final event = SpecialEvent(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      month: _selectedMonth,
      category: _category,
      flexible: _flexible,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(repositoryProvider).saveSpecialEvent(event);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.addEvent)),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: l.eventName,
                      hintText: l.eventNameHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MoneyInputField(controller: _amountController, label: l.monthlyValue),
                  const SizedBox(height: 16),
                  Text(
                    l.eventMonth,
                    style: const TextStyle(
                      fontFamily: AppConstants.fontSecondary,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    dropdownColor: AppColors.surfaceDark,
                    style: const TextStyle(
                      fontFamily: AppConstants.fontSecondary,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    items: _monthOptions.map((month) {
                      return DropdownMenuItem(value: month, child: Text(month));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedMonth = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.eventCategory,
                    style: const TextStyle(
                      fontFamily: AppConstants.fontSecondary,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: EventCategory.values.map((cat) {
                      return ChoiceChip(
                        label: Text(_catLabel(cat, l)),
                        selected: _category == cat,
                        onSelected: (v) => setState(() => _category = cat),
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _category == cat ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(
                      l.flexible,
                      style: const TextStyle(
                        fontFamily: AppConstants.fontSecondary,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    value: _flexible,
                    onChanged: (v) => setState(() => _flexible = v),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(l.saveEvent),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _catLabel(EventCategory cat, S l) {
    switch (cat) {
      case EventCategory.birthday:
        return l.catBirthday;
      case EventCategory.travel:
        return l.catTravel;
      case EventCategory.repair:
        return l.catRepair;
      case EventCategory.gift:
        return l.catGift;
      case EventCategory.medical:
        return l.catMedical;
      case EventCategory.purchase:
        return l.catPurchase;
      case EventCategory.other:
        return l.catOther;
    }
  }
}
