import 'package:equatable/equatable.dart';

enum MonthStatus { green, yellow, red, blue, purple }

/// Resultado calculado para un mes por el motor financiero
class PlanMonth extends Equatable {
  /// Identificador del mes: "2026-06"
  final String monthKey;

  /// Ingresos totales del mes
  final int incomeTotal;

  /// Gastos fijos totales del mes
  final int expenseTotal;

  /// Reserva separada del mes
  final int reserveTotal;

  /// Eventos especiales del mes
  final int eventsTotal;

  /// Total pagado a deudas este mes
  final int debtPaymentTotal;

  /// Dinero libre al final del mes
  final int freeMoney;

  /// Estado/semáforo del mes
  final MonthStatus status;

  /// Detalle de pagos por deuda
  final List<DebtPaymentDetail> debtPayments;

  /// Saldo total de deudas al finalizar el mes
  final int totalDebtRemaining;

  const PlanMonth({
    required this.monthKey,
    required this.incomeTotal,
    required this.expenseTotal,
    required this.reserveTotal,
    required this.eventsTotal,
    required this.debtPaymentTotal,
    required this.freeMoney,
    required this.status,
    required this.debtPayments,
    required this.totalDebtRemaining,
  });

  /// Dinero disponible para deuda antes de pagos
  int get availableForDebt =>
      incomeTotal - expenseTotal - reserveTotal - eventsTotal;

  @override
  List<Object?> get props => [
        monthKey,
        incomeTotal,
        expenseTotal,
        reserveTotal,
        eventsTotal,
        debtPaymentTotal,
        freeMoney,
        status,
        totalDebtRemaining,
      ];
}

/// Detalle de pago a una deuda específica en un mes
class DebtPaymentDetail extends Equatable {
  final String debtId;
  final String debtName;

  /// Monto pagado a esta deuda
  final int amountPaid;

  /// Saldo de la deuda después de este pago
  final int remainingBalance;

  /// Si este pago liquida la deuda
  final bool closesDebt;

  const DebtPaymentDetail({
    required this.debtId,
    required this.debtName,
    required this.amountPaid,
    required this.remainingBalance,
    this.closesDebt = false,
  });

  @override
  List<Object?> get props => [debtId, amountPaid, remainingBalance, closesDebt];
}
