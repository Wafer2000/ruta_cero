import 'dart:math';
import '../entities/income.dart';
import '../entities/expense.dart';
import '../entities/debt.dart';
import '../entities/special_event.dart';
import '../entities/plan_month.dart';

enum PaymentStrategy {
  /// Menor saldo primero (snowball)
  lowestBalance,

  /// Mayor interés primero (avalanche)
  highestInterest,

  /// El usuario define prioridades manualmente
  custom,

  /// Distribuye proporcionalmente
  balanced,

  /// Reserva intocable, pagos conservadores
  conservative,
}

/// Entrada del motor financiero para generar el plan
class FinancialPlanInput {
  final int monthlyIncome;
  final int monthlyReserve;
  final List<Income> extraIncomes;
  final List<Expense> expenses;
  final List<Debt> debts;
  final List<SpecialEvent> events;
  final PaymentStrategy strategy;

  /// Mes de inicio de la simulación: "2026-06"
  final String startMonth;

  /// Máximo de meses a proyectar
  final int maxMonths;

  const FinancialPlanInput({
    required this.monthlyIncome,
    required this.monthlyReserve,
    this.extraIncomes = const [],
    required this.expenses,
    required this.debts,
    this.events = const [],
    this.strategy = PaymentStrategy.custom,
    required this.startMonth,
    this.maxMonths = 60,
  });
}

/// Resultado completo del motor financiero
class FinancialPlanResult {
  /// Plan mes a mes hasta salir de deudas
  final List<PlanMonth> months;

  /// Mes en que todas las deudas llegan a cero (null si no se logra)
  final String? debtFreeMonth;

  /// Deuda total actual
  final int totalDebt;

  /// Mes con menos dinero libre
  final String? tightestMonth;
  final int tightestMonthFreeMoney;

  const FinancialPlanResult({
    required this.months,
    this.debtFreeMonth,
    required this.totalDebt,
    this.tightestMonth,
    this.tightestMonthFreeMoney = 0,
  });
}

/// Motor financiero determinístico de Ruta Cero
/// Recibe un escenario y devuelve una proyección mensual completa.
/// REGLAS:
/// - Nunca pagar más de lo que queda en una deuda
/// - Respetar pagos mínimos antes de abonos extra
/// - Condición de parada: todas las deudas a cero o maxMonths
class FinancialEngine {
  const FinancialEngine();

  /// Genera el plan financiero completo
  FinancialPlanResult generatePlan(FinancialPlanInput input) {
    final List<PlanMonth> planMonths = [];

    // Copiar saldos de deuda para mutación durante la simulación
    final Map<String, int> debtBalances = {
      for (final d in input.debts)
        if (d.isActive) d.id: d.currentBalance,
    };

    // Obtener deudas activas ordenadas por estrategia
    final List<Debt> activeDebts = input.debts.where((d) => d.isActive).toList();

    String currentMonth = input.startMonth;
    String? debtFreeMonth;
    String? tightestMonth;
    int tightestFreeMoney = 999999999;

    for (int i = 0; i < input.maxMonths; i++) {
      // 1. Verificar si todas las deudas están pagadas
      final allPaid = debtBalances.values.every((b) => b <= 0);
      if (allPaid && i > 0) {
        debtFreeMonth ??= currentMonth;
        break;
      }

      // 2. Calcular ingresos del mes
      int monthIncome = input.monthlyIncome;
      for (final extra in input.extraIncomes) {
        if (extra.recurring || extra.month == currentMonth) {
          monthIncome += extra.amount;
        }
      }

      // 3. Calcular gastos fijos del mes
      int monthExpenses = 0;
      for (final expense in input.expenses) {
        if (expense.appliesTo(currentMonth)) {
          monthExpenses += expense.amount;
        }
      }

      // 4. Calcular eventos especiales del mes
      int monthEvents = 0;
      for (final event in input.events) {
        if (event.month == currentMonth) {
          monthEvents += event.amount;
        }
      }

      // 5. Separar reserva
      final int monthReserve = input.monthlyReserve;

      // 6. Calcular dinero disponible para deuda
      int availableForDebt =
          monthIncome - monthExpenses - monthReserve - monthEvents;

      // 7. Pagar mínimos obligatorios primero
      final List<DebtPaymentDetail> payments = [];
      int totalPaid = 0;

      for (final debt in activeDebts) {
        final balance = debtBalances[debt.id] ?? 0;
        if (balance <= 0) continue;

        final minPayment = min(debt.minimumPayment, balance);
        if (availableForDebt >= minPayment) {
          availableForDebt -= minPayment;
          debtBalances[debt.id] = balance - minPayment;
          totalPaid += minPayment;
          payments.add(DebtPaymentDetail(
            debtId: debt.id,
            debtName: debt.name,
            amountPaid: minPayment,
            remainingBalance: debtBalances[debt.id]!,
            closesDebt: debtBalances[debt.id]! <= 0,
          ));
        } else {
          // No alcanza ni para el mínimo
          final canPay = max(0, availableForDebt);
          if (canPay > 0) {
            availableForDebt -= canPay;
            debtBalances[debt.id] = balance - canPay;
            totalPaid += canPay;
          }
          payments.add(DebtPaymentDetail(
            debtId: debt.id,
            debtName: debt.name,
            amountPaid: canPay,
            remainingBalance: debtBalances[debt.id] ?? balance,
            closesDebt: false,
          ));
        }
      }

      // 8. Aplicar excedente según estrategia (pagos extra sobre el mínimo)
      if (availableForDebt > 0) {
        _applyStrategy(
          activeDebts,
          debtBalances,
          availableForDebt,
          input.strategy,
          payments,
        );
        // Recalcular total pagado
        totalPaid = payments.fold<int>(0, (sum, p) => sum + p.amountPaid);
      }

      // 9. Calcular dinero libre final
      final int freeMoney = monthIncome - monthExpenses - monthReserve - monthEvents - totalPaid;

      // 10. Deuda total restante
      final int totalDebtRemaining =
          debtBalances.values.fold<int>(0, (sum, b) => sum + max(0, b));

      // 11. Determinar semáforo del mes
      MonthStatus status;
      final bool hasExtraIncome = input.extraIncomes.any(
          (e) => e.month == currentMonth && e.type == IncomeType.bonus);
      final bool hasEvent = monthEvents > 0;

      if (hasExtraIncome) {
        status = MonthStatus.blue;
      } else if (hasEvent) {
        status = MonthStatus.purple;
      } else if (freeMoney < 0) {
        status = MonthStatus.red;
      } else if (freeMoney < monthReserve) {
        status = MonthStatus.yellow;
      } else {
        status = MonthStatus.green;
      }

      // 12. Guardar snapshot del mes
      planMonths.add(PlanMonth(
        monthKey: currentMonth,
        incomeTotal: monthIncome,
        expenseTotal: monthExpenses,
        reserveTotal: monthReserve,
        eventsTotal: monthEvents,
        debtPaymentTotal: totalPaid,
        freeMoney: freeMoney,
        status: status,
        debtPayments: payments,
        totalDebtRemaining: totalDebtRemaining,
      ));

      // Track mes más ajustado
      if (freeMoney < tightestFreeMoney) {
        tightestFreeMoney = freeMoney;
        tightestMonth = currentMonth;
      }

      // Avanzar al siguiente mes
      currentMonth = _nextMonth(currentMonth);
    }

    return FinancialPlanResult(
      months: planMonths,
      debtFreeMonth: debtFreeMonth,
      totalDebt: input.debts
          .where((d) => d.isActive)
          .fold<int>(0, (sum, d) => sum + d.currentBalance),
      tightestMonth: tightestMonth,
      tightestMonthFreeMoney: tightestFreeMoney,
    );
  }

  /// Aplica la estrategia de pago con el excedente
  void _applyStrategy(
    List<Debt> debts,
    Map<String, int> balances,
    int available,
    PaymentStrategy strategy,
    List<DebtPaymentDetail> payments,
  ) {
    if (available <= 0) return;

    // Ordenar deudas según estrategia
    final List<Debt> sorted = debts
        .where((d) => (balances[d.id] ?? 0) > 0)
        .toList();

    switch (strategy) {
      case PaymentStrategy.lowestBalance:
        sorted.sort((a, b) =>
            (balances[a.id] ?? 0).compareTo(balances[b.id] ?? 0));
        break;
      case PaymentStrategy.highestInterest:
        sorted.sort((a, b) =>
            (b.interestRateBps ?? 0).compareTo(a.interestRateBps ?? 0));
        break;
      case PaymentStrategy.custom:
        sorted.sort((a, b) =>
            a.priority.index.compareTo(b.priority.index));
        break;
      case PaymentStrategy.balanced:
        _applyBalanced(sorted, balances, available, payments);
        return;
      case PaymentStrategy.conservative:
        // Solo pagar mínimos, no excedente
        return;
    }

    // Para las demás estrategias: abonar en orden
    int remaining = available;
    for (final debt in sorted) {
      if (remaining <= 0) break;
      final balance = balances[debt.id] ?? 0;
      if (balance <= 0) continue;

      final extraPayment = min(balance, remaining);
      if (extraPayment > 0) {
        balances[debt.id] = balance - extraPayment;
        remaining -= extraPayment;

        // Actualizar el payment existente
        final idx = payments.indexWhere((p) => p.debtId == debt.id);
        if (idx >= 0) {
          final existing = payments[idx];
          payments[idx] = DebtPaymentDetail(
            debtId: debt.id,
            debtName: debt.name,
            amountPaid: existing.amountPaid + extraPayment,
            remainingBalance: balances[debt.id]!,
            closesDebt: balances[debt.id]! <= 0,
          );
        }
      }
    }
  }

  void _applyBalanced(
    List<Debt> debts,
    Map<String, int> balances,
    int available,
    List<DebtPaymentDetail> payments,
  ) {
    if (debts.isEmpty) return;
    final perDebt = available ~/ debts.length;
    int remaining = available;

    for (final debt in debts) {
      if (remaining <= 0) break;
      final balance = balances[debt.id] ?? 0;
      if (balance <= 0) continue;

      final payment = min(perDebt, min(balance, remaining));
      if (payment > 0) {
        balances[debt.id] = balance - payment;
        remaining -= payment;

        final idx = payments.indexWhere((p) => p.debtId == debt.id);
        if (idx >= 0) {
          final existing = payments[idx];
          payments[idx] = DebtPaymentDetail(
            debtId: debt.id,
            debtName: debt.name,
            amountPaid: existing.amountPaid + payment,
            remainingBalance: balances[debt.id]!,
            closesDebt: balances[debt.id]! <= 0,
          );
        }
      }
    }
  }

  /// Avanza al siguiente mes
  String _nextMonth(String monthKey) {
    final parts = monthKey.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    month++;
    if (month > 12) {
      month = 1;
      year++;
    }
    return '$year-${month.toString().padLeft(2, '0')}';
  }
}
