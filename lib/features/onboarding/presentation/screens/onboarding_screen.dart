import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/user_profile.dart';
import '../../../../shared/inputs/money_input_field.dart';

/// Onboarding financiero: captura sueldo, reserva y nombre
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();
  final _reserveController = TextEditingController();
  int _currentPage = 0;

  static const _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _incomeController.dispose();
    _reserveController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: AppConstants.microInteraction,
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final name = _nameController.text.trim();
    final income = int.tryParse(_incomeController.text) ?? 0;
    final reserve = int.tryParse(_reserveController.text) ?? AppConstants.defaultReserveAmount;

    final profile = UserProfile(
      id: const Uuid().v4(),
      name: name.isEmpty ? 'Usuario' : name,
      monthlyIncome: income,
      defaultReserve: reserve,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(userProfileProvider.notifier).save(profile);
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenHorizontalPadding, vertical: 16),
              child: Row(
                children: List.generate(_totalPages, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i <= _currentPage ? AppColors.primary : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomePage(l: l, nameController: _nameController),
                  _IncomePage(l: l, incomeController: _incomeController),
                  _ReservePage(l: l, reserveController: _reserveController),
                ],
              ),
            ),

            // Button
            Padding(
              padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage < _totalPages - 1 ? l.onboardingNext : l.onboardingFinish,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final S l;
  final TextEditingController nameController;
  const _WelcomePage({required this.l, required this.nameController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AppConstants.logoSize,
            height: AppConstants.logoSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.logoBorderRadius),
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
            ),
            child: const Center(
              child: Text(AppConstants.logoCharacter, style: TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: AppConstants.logoFontSize, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ),
          ),
          const SizedBox(height: 32),
          Text(l.onboardingWelcome, style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(l.onboardingWelcomeSubtitle, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          TextField(
            controller: nameController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(labelText: l.yourName, hintText: l.nameHint),
          ),
        ],
      ),
    );
  }
}

class _IncomePage extends StatelessWidget {
  final S l;
  final TextEditingController incomeController;
  const _IncomePage({required this.l, required this.incomeController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.attach_money_rounded, size: 56, color: AppColors.success),
          const SizedBox(height: 24),
          Text(l.onboardingIncome, style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(l.onboardingIncomeSubtitle, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          MoneyInputField(controller: incomeController, label: l.monthlyIncome),
        ],
      ),
    );
  }
}

class _ReservePage extends StatelessWidget {
  final S l;
  final TextEditingController reserveController;
  const _ReservePage({required this.l, required this.reserveController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_rounded, size: 56, color: AppColors.secondary),
          const SizedBox(height: 24),
          Text(l.onboardingReserve, style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(l.onboardingReserveSubtitle, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          MoneyInputField(controller: reserveController, label: l.monthlyReserve),
        ],
      ),
    );
  }
}
