import 'package:equatable/equatable.dart';

enum GoalCategory { travel, technology, business, emergency, gift, savings, other }

enum GoalStatus { active, completed, paused }

/// Meta personal: viaje, laptop, negocio, fondo, regalo, ahorro, etc.
class Goal extends Equatable {
  final String id;
  final String name;
  final GoalCategory category;

  /// Monto objetivo en pesos enteros COP
  final int targetAmount;

  /// Monto acumulado actual
  final int currentAmount;

  /// Aporte mensual planeado
  final int monthlyContribution;

  /// Fecha objetivo (opcional)
  final DateTime? deadline;

  final GoalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.name,
    this.category = GoalCategory.other,
    required this.targetAmount,
    this.currentAmount = 0,
    this.monthlyContribution = 0,
    this.deadline,
    this.status = GoalStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Progreso de 0.0 a 1.0
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Porcentaje de progreso (0-100)
  int get progressPercent => (progress * 100).round();

  /// Meses restantes estimados
  int get estimatedMonthsRemaining {
    if (monthlyContribution <= 0) return 0;
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return 0;
    return (remaining / monthlyContribution).ceil();
  }

  bool get isCompleted => currentAmount >= targetAmount || status == GoalStatus.completed;
  bool get isActive => status == GoalStatus.active && !isCompleted;

  Goal copyWith({
    String? id,
    String? name,
    GoalCategory? category,
    int? targetAmount,
    int? currentAmount,
    int? monthlyContribution,
    DateTime? deadline,
    GoalStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, targetAmount, currentAmount, status];
}
