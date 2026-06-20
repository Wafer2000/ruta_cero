import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../shared/inputs/money_input_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();
  final _reserveController = TextEditingController();
  final _salaryDayController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    _reserveController.dispose();
    _salaryDayController.dispose();
    super.dispose();
  }

  void _initFromProfile(UserProfile? profile) {
    if (_initialized || profile == null) return;
    _nameController.text = profile.name;
    _incomeController.text = profile.monthlyIncome.toString();
    _reserveController.text = profile.defaultReserve.toString();
    _salaryDayController.text = profile.salaryDay.toString();
    _initialized = true;
  }

  Future<void> _save() async {
    final l = S.of(context);
    final profile = UserProfile(
      id: ref.read(userProfileProvider).valueOrNull?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      monthlyIncome: int.tryParse(_incomeController.text) ?? 0,
      defaultReserve: int.tryParse(_reserveController.text) ?? 500000,
      salaryDay: int.tryParse(_salaryDayController.text) ?? 30,
      createdAt: ref.read(userProfileProvider).valueOrNull?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ref.read(userProfileProvider.notifier).save(profile);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.profileSaved), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final currentLocale = ref.watch(localeProvider);
    _initFromProfile(profileAsync.valueOrNull);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(l.settingsTitle, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),

            // Language Switcher
            Text(l.language, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  _LanguageTab(
                    label: l.langSpanish,
                    flag: '🇨🇴',
                    selected: currentLocale.languageCode == 'es',
                    onTap: () => ref.read(localeProvider.notifier).setSpanish(),
                  ),
                  _LanguageTab(
                    label: l.langEnglish,
                    flag: '🇺🇸',
                    selected: currentLocale.languageCode == 'en',
                    onTap: () => ref.read(localeProvider.notifier).setEnglish(),
                  ),
                  _LanguageTab(
                    label: l.langPortuguese,
                    flag: '🇧🇷',
                    selected: currentLocale.languageCode == 'pt',
                    onTap: () => ref.read(localeProvider.notifier).setPortuguese(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name
            Text(l.yourName, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(hintText: l.nameHint),
            ),
            const SizedBox(height: 20),

            // Monthly Income
            Text(l.monthlyIncome, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            MoneyInputField(controller: _incomeController),
            const SizedBox(height: 20),

            // Reserve
            Text(l.monthlyReserve, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            MoneyInputField(controller: _reserveController),
            const SizedBox(height: 20),

            // Salary Day
            Text(l.salaryDay, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _salaryDayController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(hintText: l.salaryDayHint),
            ),
            const SizedBox(height: 32),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _save, child: Text(l.saveProfile)),
            ),

            const SizedBox(height: 32),
            // App info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.appInfo, style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(l.appCurrency, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(l.localData, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTab extends StatelessWidget {
  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTab({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
          ),
          child: Column(
            children: [
              Text(flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppConstants.fontSecondary,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
