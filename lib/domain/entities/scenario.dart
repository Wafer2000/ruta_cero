import 'package:equatable/equatable.dart';
import '../services/financial_engine.dart';

/// Escenario de simulación financiera
/// Permite cambiar valores hipotéticos y ver el impacto sin modificar el plan real
class Scenario extends Equatable {
  final String id;
  final String name;
  final PaymentStrategy strategy;

  /// Cambios respecto al plan actual
  final int? overrideIncome;
  final int? overrideReserve;
  final Map<String, int>? overrideDebtPayments; // debtId -> nuevo pago
  final Map<String, int>? overrideExpenses; // expenseId -> nuevo valor
  final List<ScenarioEvent> additionalEvents;

  final DateTime createdAt;
  final bool isFavorite;

  const Scenario({
    required this.id,
    required this.name,
    this.strategy = PaymentStrategy.custom,
    this.overrideIncome,
    this.overrideReserve,
    this.overrideDebtPayments,
    this.overrideExpenses,
    this.additionalEvents = const [],
    required this.createdAt,
    this.isFavorite = false,
  });

  Scenario copyWith({
    String? id,
    String? name,
    PaymentStrategy? strategy,
    int? overrideIncome,
    int? overrideReserve,
    Map<String, int>? overrideDebtPayments,
    Map<String, int>? overrideExpenses,
    List<ScenarioEvent>? additionalEvents,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Scenario(
      id: id ?? this.id,
      name: name ?? this.name,
      strategy: strategy ?? this.strategy,
      overrideIncome: overrideIncome ?? this.overrideIncome,
      overrideReserve: overrideReserve ?? this.overrideReserve,
      overrideDebtPayments: overrideDebtPayments ?? this.overrideDebtPayments,
      overrideExpenses: overrideExpenses ?? this.overrideExpenses,
      additionalEvents: additionalEvents ?? this.additionalEvents,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, name, strategy, overrideIncome, overrideReserve, isFavorite];
}

/// Evento adicional dentro de un escenario
class ScenarioEvent extends Equatable {
  final String name;
  final int amount;
  final String month;

  const ScenarioEvent({
    required this.name,
    required this.amount,
    required this.month,
  });

  @override
  List<Object?> get props => [name, amount, month];
}
