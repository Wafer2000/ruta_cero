import 'package:flutter_test/flutter_test.dart';
import 'package:ruta_cero/domain/services/financial_engine.dart';
import 'package:ruta_cero/domain/entities/debt.dart';
import 'package:ruta_cero/domain/entities/expense.dart';

import 'package:ruta_cero/domain/entities/special_event.dart';

void main() {
  group('FinancialEngine', () {
    const engine = FinancialEngine();

    test('Genera plan correcto con datos base de Ruta Cero', () {
      // Datos del documento: sueldo $6.400.000, gastos $3.816.048, reserva $500.000
      final input = FinancialPlanInput(
        monthlyIncome: 6400000,
        monthlyReserve: 500000,
        expenses: [
          Expense(
            id: 'gastos-fijos',
            name: 'Gastos fijos',
            amount: 3816048,
            category: ExpenseCategory.other,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        debts: [
          Debt(
            id: 'tarjeta',
            name: 'Tarjeta de crédito',
            type: DebtType.creditCard,
            currentBalance: 791606,
            minimumPayment: 200000,
            targetPayment: 791606,
            priority: DebtPriority.high,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Debt(
            id: 'credito',
            name: 'Crédito Libre Destino',
            type: DebtType.freeCredit,
            currentBalance: 8308693,
            minimumPayment: 400000,
            targetPayment: 1200000,
            priority: DebtPriority.medium,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        events: [
          SpecialEvent(
            id: 'cumple-maira',
            name: 'Cumpleaños Maira',
            amount: 500000,
            month: '2026-10',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        strategy: PaymentStrategy.custom,
        startMonth: '2026-06',
      );

      final result = engine.generatePlan(input);

      // Verificaciones del motor financiero
      expect(result.months.isNotEmpty, true);
      expect(result.totalDebt, 791606 + 8308693);
      expect(result.debtFreeMonth, isNotNull);

      // Primer mes debe tener ingreso de 6.4M
      expect(result.months.first.incomeTotal, 6400000);
    });

    test('Respeta pagos mínimos', () {
      final input = FinancialPlanInput(
        monthlyIncome: 1000000,
        monthlyReserve: 100000,
        expenses: [
          Expense(
            id: 'e1',
            name: 'Gastos',
            amount: 500000,
            category: ExpenseCategory.other,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        debts: [
          Debt(
            id: 'd1',
            name: 'Deuda 1',
            type: DebtType.other,
            currentBalance: 2000000,
            minimumPayment: 300000,
            targetPayment: 400000,
            priority: DebtPriority.high,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        strategy: PaymentStrategy.custom,
        startMonth: '2026-01',
      );

      final result = engine.generatePlan(input);
      // Disponible: 1M - 500K - 100K = 400K para deuda
      // Pago mínimo: 300K -> debe pagar al menos eso
      expect(result.months.first.debtPaymentTotal >= 300000, true);
    });

    test('Cierra deuda cuando llega a cero', () {
      final input = FinancialPlanInput(
        monthlyIncome: 2000000,
        monthlyReserve: 100000,
        expenses: [],
        debts: [
          Debt(
            id: 'd1',
            name: 'Deuda pequeña',
            type: DebtType.other,
            currentBalance: 500000,
            minimumPayment: 100000,
            targetPayment: 500000,
            priority: DebtPriority.high,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        strategy: PaymentStrategy.custom,
        startMonth: '2026-01',
      );

      final result = engine.generatePlan(input);
      // Con 1.9M disponible y deuda de 500K, debe terminarse en 1 mes
      expect(result.debtFreeMonth, '2026-02');
      expect(result.months.first.debtPayments.first.closesDebt, true);
    });
  });
}
