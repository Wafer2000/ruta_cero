import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/goal.dart';
import '../../../../shared/inputs/money_input_field.dart';
import '../../providers/goals_providers.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _contributionController = TextEditingController();

  GoalCategory _category = GoalCategory.savings;
  DateTime? _deadline;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _contributionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _save() {
    final l = S.of(context);
    final name = _nameController.text.trim();
    final target = int.tryParse(_targetController.text) ?? 0;
    final contribution = int.tryParse(_contributionController.text) ?? 0;

    if (name.isEmpty || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.nameAndValueRequired)),
      );
      return;
    }

    final goal = Goal(
      id: const Uuid().v4(),
      name: name,
      category: _category,
      targetAmount: target,
      monthlyContribution: contribution,
      deadline: _deadline,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(goalsListProvider.notifier).add(goal);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.addGoal)),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: l.goalName,
                        hintText: l.goalNameHint,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category chips
                    Text(
                      l.goalCategory,
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
                      children: GoalCategory.values
                          .where((c) => c != GoalCategory.other)
                          .map((cat) {
                        return ChoiceChip(
                          label: Text(_categoryLabel(cat, l)),
                          selected: _category == cat,
                          onSelected: (v) => setState(() => _category = cat),
                          avatar: Icon(
                            _categoryIcon(cat),
                            size: 16,
                            color: _category == cat
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _category == cat
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Target amount
                    MoneyInputField(
                      controller: _targetController,
                      label: l.targetAmount,
                    ),
                    const SizedBox(height: 16),

                    // Monthly contribution
                    MoneyInputField(
                      controller: _contributionController,
                      label: l.monthlyContribution,
                    ),
                    const SizedBox(height: 20),

                    // Deadline picker
                    Text(
                      l.deadline,
                      style: const TextStyle(
                        fontFamily: AppConstants.fontSecondary,
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDeadline,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(
                            AppConstants.inputBorderRadius,
                          ),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _deadline != null
                                  ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                                  : '---',
                              style: TextStyle(
                                fontFamily: AppConstants.fontSecondary,
                                fontSize: 14,
                                color: _deadline != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: Text(l.saveGoal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(GoalCategory cat, S l) {
    switch (cat) {
      case GoalCategory.travel:
        return l.catTravel;
      case GoalCategory.technology:
        return l.catTechnology;
      case GoalCategory.business:
        return l.catBusiness;
      case GoalCategory.emergency:
        return l.catEmergency;
      case GoalCategory.gift:
        return l.catGift;
      case GoalCategory.savings:
        return l.catSavings;
      case GoalCategory.other:
        return l.catOther;
    }
  }

  IconData _categoryIcon(GoalCategory cat) {
    switch (cat) {
      case GoalCategory.travel:
        return Icons.flight_rounded;
      case GoalCategory.technology:
        return Icons.laptop_rounded;
      case GoalCategory.business:
        return Icons.business_center_rounded;
      case GoalCategory.emergency:
        return Icons.shield_rounded;
      case GoalCategory.gift:
        return Icons.card_giftcard_rounded;
      case GoalCategory.savings:
        return Icons.savings_rounded;
      case GoalCategory.other:
        return Icons.flag_rounded;
    }
  }
}
