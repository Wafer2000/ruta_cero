import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, paid, overdue, cancelled }

/// Entidad de pago real: compara planeado vs ejecutado
class Payment extends Equatable {
  final String id;
  final String? debtId;
  final String? debtName;

  /// Monto realmente pagado
  final int amount;

  /// Monto que estaba planeado
  final int plannedAmount;

  /// Fecha planeada de pago
  final DateTime? plannedDate;

  /// Fecha real de pago
  final DateTime? paidDate;

  final PaymentStatus status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Payment({
    required this.id,
    this.debtId,
    this.debtName,
    required this.amount,
    required this.plannedAmount,
    this.plannedDate,
    this.paidDate,
    this.status = PaymentStatus.pending,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPaid => status == PaymentStatus.paid;
  bool get isOverdue =>
      status == PaymentStatus.pending &&
      plannedDate != null &&
      DateTime.now().isAfter(plannedDate!);

  /// Diferencia entre lo planeado y lo pagado
  int get difference => amount - plannedAmount;

  Payment copyWith({
    String? id,
    String? debtId,
    String? debtName,
    int? amount,
    int? plannedAmount,
    DateTime? plannedDate,
    DateTime? paidDate,
    PaymentStatus? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      debtName: debtName ?? this.debtName,
      amount: amount ?? this.amount,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      plannedDate: plannedDate ?? this.plannedDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, debtId, amount, plannedAmount, status, paidDate];
}
