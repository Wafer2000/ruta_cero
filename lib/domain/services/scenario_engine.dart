import '../entities/scenario.dart';
import '../entities/scenario_comparison.dart';
import '../entities/income.dart';
import '../entities/expense.dart';
import '../entities/debt.dart';
import '../entities/special_event.dart';
import '../entities/plan_month.dart';
import 'financial_engine.dart';

/// Motor de escenarios: simula cambios hipotéticos y compara contra el plan actual
class ScenarioEngine {
  final FinancialEngine _engine;

  const ScenarioEngine(this._engine);

  /// Simula un escenario y retorna el plan resultante
  FinancialPlanResult simulate({
    required Scenario scenario,
    required int baseIncome,
    required int baseReserve,
    required List<Income> incomes,
    required List<Expense> expenses,
    required List<Debt> debts,
    required List<SpecialEvent> events,
    required String startMonth,
  }) {
    // Aplicar overrides del escenario
    final simIncome = scenario.overrideIncome ?? baseIncome;
    final simReserve = scenario.overrideReserve ?? baseReserve;

    // Clonar deudas con pagos override
    final simDebts = debts.map((d) {
      if (scenario.overrideDebtPayments?.containsKey(d.id) == true) {
        return d.copyWith(targetPayment: scenario.overrideDebtPayments![d.id]!);
      }
      return d;
    }).toList();

    // Clonar gastos con override
    final simExpenses = expenses.map((e) {
      if (scenario.overrideExpenses?.containsKey(e.id) == true) {
        return e.copyWith(amount: scenario.overrideExpenses![e.id]!);
      }
      return e;
    }).toList();

    // Agregar eventos adicionales del escenario
    final simEvents = [
      ...events,
      ...scenario.additionalEvents.map((se) => SpecialEvent(
            id: 'sim_${se.name}',
            name: se.name,
            amount: se.amount,
            month: se.month,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )),
    ];

    return _engine.generatePlan(FinancialPlanInput(
      monthlyIncome: simIncome,
      monthlyReserve: simReserve,
      extraIncomes: incomes.where((i) => i.type != IncomeType.salary).toList(),
      expenses: simExpenses,
      debts: simDebts,
      events: simEvents,
      strategy: scenario.strategy,
      startMonth: startMonth,
    ));
  }

  /// Compara el plan actual contra un escenario
  ScenarioComparison compare({
    required FinancialPlanResult currentPlan,
    required FinancialPlanResult scenarioPlan,
    required String scenarioName,
  }) {
    final currentFreeMonth = currentPlan.debtFreeMonth ?? '?';
    final scenarioFreeMonth = scenarioPlan.debtFreeMonth ?? '?';

    final monthsDiff = currentPlan.debtFreeMonth != null && scenarioPlan.debtFreeMonth != null
        ? _monthsBetween(currentPlan.debtFreeMonth!, scenarioPlan.debtFreeMonth!)
        : 0;

    final currentAvgFree = currentPlan.months.isEmpty
        ? 0
        : currentPlan.months.fold<int>(0, (s, m) => s + m.freeMoney) ~/ currentPlan.months.length;

    final scenarioAvgFree = scenarioPlan.months.isEmpty
        ? 0
        : scenarioPlan.months.fold<int>(0, (s, m) => s + m.freeMoney) ~/ scenarioPlan.months.length;

    final redMonths = scenarioPlan.months.where((m) => m.status == MonthStatus.red).length;

    return ScenarioComparison(
      scenarioName: scenarioName,
      currentDebtFreeMonth: currentFreeMonth,
      scenarioDebtFreeMonth: scenarioFreeMonth,
      monthsDifference: monthsDiff,
      currentAvgFreeMoney: currentAvgFree,
      scenarioAvgFreeMoney: scenarioAvgFree,
      scenarioRedMonths: redMonths,
      totalDebt: currentPlan.totalDebt,
    );
  }

  /// "¿Me alcanza?" — evalúa si una compra conviene
  AffordabilityResult checkAffordability({
    required int purchaseAmount,
    required String purchaseMonth,
    required FinancialPlanResult currentPlan,
    required int baseIncome,
    required int baseReserve,
    required List<Income> incomes,
    required List<Expense> expenses,
    required List<Debt> debts,
    required List<SpecialEvent> events,
    required String startMonth,
  }) {
    // Simular con la compra como evento adicional
    final withPurchase = _engine.generatePlan(FinancialPlanInput(
      monthlyIncome: baseIncome,
      monthlyReserve: baseReserve,
      extraIncomes: incomes.where((i) => i.type != IncomeType.salary).toList(),
      expenses: expenses,
      debts: debts,
      events: [
        ...events,
        SpecialEvent(
          id: 'affordability_check',
          name: 'Compra evaluada',
          amount: purchaseAmount,
          month: purchaseMonth,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      strategy: PaymentStrategy.custom,
      startMonth: startMonth,
    ));

    final currentFreeMonth = currentPlan.debtFreeMonth;
    final newFreeMonth = withPurchase.debtFreeMonth;
    final delaysDebt = currentFreeMonth != null && newFreeMonth != null
        ? _monthsBetween(currentFreeMonth, newFreeMonth) > 0
        : false;

    // Verificar si usa reserva
    final purchaseMonthPlan = withPurchase.months.firstWhere(
      (m) => m.monthKey == purchaseMonth,
      orElse: () => withPurchase.months.last,
    );
    final usesReserve = purchaseMonthPlan.freeMoney < 0;

    AffordabilityLevel level;
    if (purchaseMonthPlan.freeMoney < -baseReserve) {
      level = AffordabilityLevel.cannotAfford;
    } else if (usesReserve || delaysDebt) {
      level = AffordabilityLevel.withReserve;
    } else {
      level = AffordabilityLevel.canAfford;
    }

    return AffordabilityResult(
      level: level,
      delaysDebtFreeBy: delaysDebt
          ? _monthsBetween(currentFreeMonth, newFreeMonth)
          : 0,
      freeMoneyAfter: purchaseMonthPlan.freeMoney,
      usesReserve: usesReserve,
    );
  }

  int _monthsBetween(String from, String to) {
    final fromParts = from.split('-');
    final toParts = to.split('-');
    final fromMonths = int.parse(fromParts[0]) * 12 + int.parse(fromParts[1]);
    final toMonths = int.parse(toParts[0]) * 12 + int.parse(toParts[1]);
    return toMonths - fromMonths;
  }
}

enum AffordabilityLevel { canAfford, withReserve, cannotAfford }

/// Resultado de "¿Me alcanza?"
class AffordabilityResult {
  final AffordabilityLevel level;
  final int delaysDebtFreeBy;
  final int freeMoneyAfter;
  final bool usesReserve;

  const AffordabilityResult({
    required this.level,
    required this.delaysDebtFreeBy,
    required this.freeMoneyAfter,
    required this.usesReserve,
  });
}
