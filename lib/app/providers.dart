import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';
import '../data/repositories/financial_repository.dart';
import '../domain/services/financial_engine.dart';
import '../domain/entities/income.dart' as domain;
import '../domain/entities/expense.dart' as domain;
import '../domain/entities/debt.dart' as domain;
import '../domain/entities/special_event.dart' as domain;
import '../domain/entities/user_profile.dart' as domain;
import '../domain/entities/plan_month.dart' as domain;
import '../core/formatting/date_formatter.dart';

// ===== DATABASE & REPOSITORY =====

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final repositoryProvider = Provider<FinancialRepository>((ref) {
  return FinancialRepository(ref.watch(databaseProvider));
});

// ===== FINANCIAL ENGINE =====

final financialEngineProvider = Provider<FinancialEngine>((ref) {
  return const FinancialEngine();
});

// ===== USER PROFILE =====

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<domain.UserProfile?>>((ref) {
  return UserProfileNotifier(ref.watch(repositoryProvider));
});

class UserProfileNotifier extends StateNotifier<AsyncValue<domain.UserProfile?>> {
  final FinancialRepository _repo;

  UserProfileNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _repo.getUserProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save(domain.UserProfile profile) async {
    await _repo.saveUserProfile(profile);
    state = AsyncValue.data(profile);
  }
}

// ===== INCOMES =====

final incomesProvider =
    StreamProvider<List<domain.Income>>((ref) {
  return ref.watch(repositoryProvider).watchIncomes();
});

// ===== EXPENSES =====

final expensesProvider =
    StreamProvider<List<domain.Expense>>((ref) {
  return ref.watch(repositoryProvider).watchExpenses();
});

// ===== DEBTS =====

final debtsProvider =
    StreamProvider<List<domain.Debt>>((ref) {
  return ref.watch(repositoryProvider).watchDebts();
});

// ===== SPECIAL EVENTS =====

final specialEventsProvider =
    StreamProvider<List<domain.SpecialEvent>>((ref) {
  return ref.watch(repositoryProvider).watchSpecialEvents();
});

// ===== FINANCIAL PLAN (Motor financiero) =====

final financialPlanProvider =
    Provider<AsyncValue<FinancialPlanResult>>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  final incomesAsync = ref.watch(incomesProvider);
  final expensesAsync = ref.watch(expensesProvider);
  final debtsAsync = ref.watch(debtsProvider);
  final eventsAsync = ref.watch(specialEventsProvider);

  final profile = profileAsync.valueOrNull;
  final incomes = incomesAsync.valueOrNull;
  final expenses = expensesAsync.valueOrNull;
  final debts = debtsAsync.valueOrNull;
  final events = eventsAsync.valueOrNull;

  if (profile == null || incomes == null || expenses == null || debts == null || events == null) {
    return const AsyncValue.loading();
  }

  try {
    final engine = ref.read(financialEngineProvider);
    final now = DateTime.now();
    final currentMonth = DateFormatter.monthKey(now);

    final input = FinancialPlanInput(
      monthlyIncome: profile.monthlyIncome,
      monthlyReserve: profile.defaultReserve,
      extraIncomes: incomes.where((i) => i.type != domain.IncomeType.salary).toList(),
      expenses: expenses,
      debts: debts,
      events: events,
      strategy: PaymentStrategy.custom,
      startMonth: currentMonth,
    );

    final result = engine.generatePlan(input);
    return AsyncValue.data(result);
  } catch (e, st) {
    return AsyncValue.error(e, st);
  }
});

// ===== DERIVED DATA =====

/// Deuda total actual
final totalDebtProvider = Provider<int>((ref) {
  final debts = ref.watch(debtsProvider).valueOrNull ?? [];
  return debts
      .where((d) => d.isActive)
      .fold<int>(0, (sum, d) => sum + d.currentBalance);
});

/// Gastos fijos totales del mes
final totalFixedExpensesProvider = Provider<int>((ref) {
  final expenses = ref.watch(expensesProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final currentMonth = DateFormatter.monthKey(now);
  return expenses
      .where((e) => e.appliesTo(currentMonth))
      .fold<int>(0, (sum, e) => sum + e.amount);
});

/// Mes actual del plan
final currentPlanMonthProvider = Provider<domain.PlanMonth?>((ref) {
  final plan = ref.watch(financialPlanProvider);
  return plan.valueOrNull?.months.isNotEmpty == true
      ? plan.valueOrNull!.months.first
      : null;
});
