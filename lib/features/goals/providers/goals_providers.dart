import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../domain/entities/goal.dart';
import '../../../domain/services/post_debt_engine.dart';

// ===== GOALS =====

final goalsListProvider =
    StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  return GoalsNotifier();
});

class GoalsNotifier extends StateNotifier<List<Goal>> {
  GoalsNotifier() : super([]);

  void add(Goal goal) {
    state = [...state, goal];
  }

  void remove(String id) {
    state = state.where((g) => g.id != id).toList();
  }

  void update(Goal updated) {
    state = state.map((g) => g.id == updated.id ? updated : g).toList();
  }
}

// ===== POST DEBT ENGINE =====

final postDebtEngineProvider = Provider<PostDebtEngine>((ref) {
  return const PostDebtEngine();
});

// ===== DAILY BUDGET =====

final dailyBudgetProvider = Provider<int>((ref) {
  final engine = ref.watch(postDebtEngineProvider);
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final totalExpenses = ref.watch(totalFixedExpensesProvider);
  final plan = ref.watch(financialPlanProvider);

  if (profile == null) return 0;

  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final daysRemaining = daysInMonth - now.day + 1;

  // Sum debt payments from the plan's current month
  final currentMonth = plan.valueOrNull?.months.isNotEmpty == true
      ? plan.valueOrNull!.months.first
      : null;
  final monthlyDebtPayments = currentMonth?.debtPaymentTotal ?? 0;

  return engine.calculateDailyBudget(
    monthlyIncome: profile.monthlyIncome,
    monthlyExpenses: totalExpenses,
    monthlyReserve: profile.defaultReserve,
    monthlyDebtPayments: monthlyDebtPayments,
    daysRemainingInMonth: daysRemaining,
  );
});

// ===== EMERGENCY FUND =====

final emergencyFundProvider = Provider<EmergencyFundTargets>((ref) {
  final engine = ref.watch(postDebtEngineProvider);
  final totalExpenses = ref.watch(totalFixedExpensesProvider);

  return engine.calculateEmergencyFundTargets(
    monthlyExpenses: totalExpenses,
  );
});
