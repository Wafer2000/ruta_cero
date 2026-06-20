import 'package:equatable/equatable.dart';

/// Resultado de comparar el plan actual vs un escenario
class ScenarioComparison extends Equatable {
  final String scenarioName;

  /// Fecha final del plan actual
  final String currentDebtFreeMonth;

  /// Fecha final del escenario
  final String scenarioDebtFreeMonth;

  /// Diferencia en meses (positivo = retrasa, negativo = adelanta)
  final int monthsDifference;

  /// Dinero libre promedio en el plan actual
  final int currentAvgFreeMoney;

  /// Dinero libre promedio en el escenario
  final int scenarioAvgFreeMoney;

  /// Meses en riesgo (rojo) en el escenario
  final int scenarioRedMonths;

  /// Deuda total al momento de comparar
  final int totalDebt;

  const ScenarioComparison({
    required this.scenarioName,
    required this.currentDebtFreeMonth,
    required this.scenarioDebtFreeMonth,
    required this.monthsDifference,
    required this.currentAvgFreeMoney,
    required this.scenarioAvgFreeMoney,
    required this.scenarioRedMonths,
    required this.totalDebt,
  });

  bool get isWorse => monthsDifference > 0;
  bool get isBetter => monthsDifference < 0;
  bool get isSame => monthsDifference == 0;

  @override
  List<Object?> get props => [scenarioName, monthsDifference, scenarioDebtFreeMonth];
}
