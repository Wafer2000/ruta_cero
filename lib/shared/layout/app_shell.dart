import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

/// Shell principal con bottom navigation
/// 5 tabs: Inicio, Plan, Deudas, Gastos, Ajustes
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/plan')) return 1;
    if (location.startsWith('/debts')) return 2;
    if (location.startsWith('/expenses')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/plan');
        break;
      case 2:
        context.go('/debts');
        break;
      case 3:
        context.go('/expenses');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(
            top: BorderSide(
              color: AppColors.cardBorder,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex(context),
          onTap: (index) => _onTap(context, index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: l.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month_rounded),
              label: l.navPlan,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_rounded),
              label: l.navDebts,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_rounded),
              label: l.navExpenses,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: l.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
