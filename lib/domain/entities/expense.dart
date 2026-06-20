import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  housing, // Arriendo
  food, // Comida
  transport, // Transporte
  utilities, // Servicios (luz, agua, internet)
  subscriptions, // Suscripciones
  health, // Salud, gym, creatina
  personal, // Gastos personales
  education, // Educación
  entertainment, // Entretenimiento
  other, // Otros
}

enum ExpenseFrequency { monthly, biweekly, weekly, once }

/// Entidad de gasto fijo o variable
class Expense extends Equatable {
  final String id;
  final String name;

  /// Valor en pesos enteros COP
  final int amount;
  final ExpenseCategory category;
  final ExpenseFrequency frequency;

  /// Día del mes en que vence (1-31)
  final int? dueDay;

  /// Si el gasto está activo o pausado
  final bool active;

  /// Mes desde el que aplica (null = siempre)
  final String? startMonth;

  /// Mes hasta el que aplica (null = indefinido)
  final String? endMonth;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    this.frequency = ExpenseFrequency.monthly,
    this.dueDay,
    this.active = true,
    this.startMonth,
    this.endMonth,
    required this.createdAt,
    required this.updatedAt,
  });

  Expense copyWith({
    String? id,
    String? name,
    int? amount,
    ExpenseCategory? category,
    ExpenseFrequency? frequency,
    int? dueDay,
    bool? active,
    String? startMonth,
    String? endMonth,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      dueDay: dueDay ?? this.dueDay,
      active: active ?? this.active,
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica si el gasto aplica para un mes dado
  bool appliesTo(String monthKey) {
    if (!active) return false;
    if (startMonth != null && monthKey.compareTo(startMonth!) < 0) return false;
    if (endMonth != null && monthKey.compareTo(endMonth!) > 0) return false;
    return true;
  }

  @override
  List<Object?> get props =>
      [id, name, amount, category, frequency, dueDay, active, startMonth, endMonth];
}
