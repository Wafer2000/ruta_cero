import 'package:equatable/equatable.dart';

enum DebtType { creditCard, freeCredit, personalLoan, installment, other }

enum DebtStatus { active, paid, paused, restructured }

enum DebtPriority { high, medium, low }

/// Entidad de deuda: tarjeta, crédito libre destino, Addi, etc.
class Debt extends Equatable {
  final String id;
  final String name;
  final DebtType type;

  /// Saldo actual en pesos enteros COP
  final int currentBalance;

  /// Pago mínimo mensual obligatorio
  final int minimumPayment;

  /// Pago objetivo mensual (lo que planea pagar)
  final int targetPayment;

  /// Prioridad definida por el usuario
  final DebtPriority priority;

  /// Fecha de vencimiento del pago mensual
  final int? dueDay;

  /// Tasa de interés mensual (en centésimas de porcentaje: 180 = 1.80%)
  final int? interestRateBps;

  final DebtStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos específicos de tarjeta de crédito
  final CreditCardDetail? creditCardDetail;

  const Debt({
    required this.id,
    required this.name,
    required this.type,
    required this.currentBalance,
    required this.minimumPayment,
    required this.targetPayment,
    this.priority = DebtPriority.medium,
    this.dueDay,
    this.interestRateBps,
    this.status = DebtStatus.active,
    this.creditCardDetail,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPaid => currentBalance <= 0 || status == DebtStatus.paid;
  bool get isActive => status == DebtStatus.active && currentBalance > 0;
  bool get isCreditCard => type == DebtType.creditCard;
  int get paymentDay => dueDay ?? 15;

  Debt copyWith({
    String? id,
    String? name,
    DebtType? type,
    int? currentBalance,
    int? minimumPayment,
    int? targetPayment,
    DebtPriority? priority,
    int? dueDay,
    int? interestRateBps,
    DebtStatus? status,
    CreditCardDetail? creditCardDetail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentBalance: currentBalance ?? this.currentBalance,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      targetPayment: targetPayment ?? this.targetPayment,
      priority: priority ?? this.priority,
      dueDay: dueDay ?? this.dueDay,
      interestRateBps: interestRateBps ?? this.interestRateBps,
      status: status ?? this.status,
      creditCardDetail: creditCardDetail ?? this.creditCardDetail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        currentBalance,
        minimumPayment,
        targetPayment,
        priority,
        status,
      ];
}

/// Campos específicos de tarjeta de crédito
class CreditCardDetail extends Equatable {
  /// Cupo total aprobado
  final int creditLimit;

  /// Cupo disponible actual
  final int availableCredit;

  /// Día de corte
  final int cutoffDay;

  /// Día límite de pago
  final int paymentDueDay;

  const CreditCardDetail({
    required this.creditLimit,
    required this.availableCredit,
    required this.cutoffDay,
    required this.paymentDueDay,
  });

  /// Porcentaje de utilización (0-100)
  int get utilizationPercent {
    if (creditLimit <= 0) return 0;
    return ((creditLimit - availableCredit) * 100 / creditLimit).round();
  }

  CreditCardDetail copyWith({
    int? creditLimit,
    int? availableCredit,
    int? cutoffDay,
    int? paymentDueDay,
  }) {
    return CreditCardDetail(
      creditLimit: creditLimit ?? this.creditLimit,
      availableCredit: availableCredit ?? this.availableCredit,
      cutoffDay: cutoffDay ?? this.cutoffDay,
      paymentDueDay: paymentDueDay ?? this.paymentDueDay,
    );
  }

  @override
  List<Object?> get props => [creditLimit, availableCredit, cutoffDay, paymentDueDay];
}
