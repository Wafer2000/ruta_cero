import '../entities/goal.dart';

/// Motor de proyección post-deuda
/// Calcula qué hacer con el dinero libre después de pagar todas las deudas
class PostDebtEngine {
  const PostDebtEngine();

  /// Calcula el excedente mensual una vez libre de deudas
  int calculateMonthlyExcess({
    required int monthlyIncome,
    required int monthlyExpenses,
    required int monthlyReserve,
  }) {
    return monthlyIncome - monthlyExpenses - monthlyReserve;
  }

  /// Calcula las metas del fondo de emergencia basado en gastos fijos
  EmergencyFundTargets calculateEmergencyFundTargets({
    required int monthlyExpenses,
  }) {
    return EmergencyFundTargets(
      minimum: monthlyExpenses * 1,
      recommended: monthlyExpenses * 3,
      ideal: monthlyExpenses * 6,
    );
  }

  /// Calcula en cuántos meses se alcanza una meta dado un aporte mensual
  int monthsToGoal({
    required int targetAmount,
    required int currentAmount,
    required int monthlyContribution,
  }) {
    if (monthlyContribution <= 0) return 0;
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return 0;
    return (remaining / monthlyContribution).ceil();
  }

  /// Sugiere distribución del excedente mensual post-deuda
  PostDebtDistribution suggestDistribution({
    required int monthlyExcess,
    required int emergencyFundCurrent,
    required int emergencyFundTarget,
    required List<Goal> activeGoals,
  }) {
    // Si el fondo de emergencia no está completo, priorizar
    if (emergencyFundCurrent < emergencyFundTarget) {
      final toEmergency = (monthlyExcess * 0.5).round();
      final toGoals = (monthlyExcess * 0.3).round();
      final toFree = monthlyExcess - toEmergency - toGoals;
      return PostDebtDistribution(
        toEmergencyFund: toEmergency,
        toGoals: toGoals,
        toFreeMoney: toFree,
      );
    }

    // Fondo completo: distribuir entre metas y libre
    if (activeGoals.isNotEmpty) {
      final toGoals = (monthlyExcess * 0.6).round();
      final toFree = monthlyExcess - toGoals;
      return PostDebtDistribution(
        toEmergencyFund: 0,
        toGoals: toGoals,
        toFreeMoney: toFree,
      );
    }

    // Sin metas: todo libre
    return PostDebtDistribution(
      toEmergencyFund: 0,
      toGoals: 0,
      toFreeMoney: monthlyExcess,
    );
  }

  /// Calcula presupuesto diario disponible
  int calculateDailyBudget({
    required int monthlyIncome,
    required int monthlyExpenses,
    required int monthlyReserve,
    required int monthlyDebtPayments,
    required int daysRemainingInMonth,
  }) {
    if (daysRemainingInMonth <= 0) return 0;
    final available = monthlyIncome - monthlyExpenses - monthlyReserve - monthlyDebtPayments;
    if (available <= 0) return 0;
    return available ~/ daysRemainingInMonth;
  }
}

/// Metas de fondo de emergencia
class EmergencyFundTargets {
  final int minimum;     // 1 mes de gastos
  final int recommended; // 3 meses de gastos
  final int ideal;       // 6 meses de gastos

  const EmergencyFundTargets({
    required this.minimum,
    required this.recommended,
    required this.ideal,
  });
}

/// Distribución sugerida del excedente mensual
class PostDebtDistribution {
  final int toEmergencyFund;
  final int toGoals;
  final int toFreeMoney;

  const PostDebtDistribution({
    required this.toEmergencyFund,
    required this.toGoals,
    required this.toFreeMoney,
  });

  int get total => toEmergencyFund + toGoals + toFreeMoney;
}
