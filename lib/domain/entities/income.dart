import 'package:equatable/equatable.dart';

enum IncomeType { salary, bonus, extra }

/// Entidad de ingreso: sueldo, prima o ingreso extra
class Income extends Equatable {
  final String id;
  final String name;

  /// Valor en pesos enteros COP
  final int amount;
  final IncomeType type;

  /// Mes al que aplica (año-mes): "2026-06"
  final String month;

  /// Si se repite cada mes
  final bool recurring;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Income({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.month,
    this.recurring = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Income copyWith({
    String? id,
    String? name,
    int? amount,
    IncomeType? type,
    String? month,
    bool? recurring,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Income(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      month: month ?? this.month,
      recurring: recurring ?? this.recurring,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, amount, type, month, recurring];
}
