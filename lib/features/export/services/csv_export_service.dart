import 'package:csv/csv.dart';
import '../../../domain/entities/plan_month.dart';
import '../../../domain/entities/debt.dart';
import '../../../domain/entities/expense.dart';

/// Servicio de exportación a CSV (compatible con Excel)
class CsvExportService {
  const CsvExportService();

  /// Genera CSV del plan mes a mes
  String generatePlanCsv(List<PlanMonth> months) {
    final rows = <List<String>>[
      ['Mes', 'Ingresos', 'Gastos', 'Reserva', 'Eventos', 'Pago deuda', 'Libre', 'Deuda restante'],
      ...months.map((m) => [
            m.monthKey,
            m.incomeTotal.toString(),
            m.expenseTotal.toString(),
            m.reserveTotal.toString(),
            m.eventsTotal.toString(),
            m.debtPaymentTotal.toString(),
            m.freeMoney.toString(),
            m.totalDebtRemaining.toString(),
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  /// Genera CSV de deudas
  String generateDebtsCsv(List<Debt> debts) {
    final rows = <List<String>>[
      ['Nombre', 'Tipo', 'Saldo', 'Pago minimo', 'Pago objetivo', 'Prioridad', 'Estado'],
      ...debts.map((d) => [
            d.name,
            d.type.name,
            d.currentBalance.toString(),
            d.minimumPayment.toString(),
            d.targetPayment.toString(),
            d.priority.name,
            d.status.name,
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  /// Genera CSV de gastos
  String generateExpensesCsv(List<Expense> expenses) {
    final rows = <List<String>>[
      ['Nombre', 'Valor', 'Categoria', 'Frecuencia', 'Activo'],
      ...expenses.map((e) => [
            e.name,
            e.amount.toString(),
            e.category.name,
            e.frequency.name,
            e.active ? 'Si' : 'No',
          ]),
    ];
    return const ListToCsvConverter().convert(rows);
  }
}
