import 'package:equatable/equatable.dart';

/// Perfil y configuración base del usuario
class UserProfile extends Equatable {
  final String id;
  final String name;
  final String currency;
  final String locale;
  final String timezone;

  /// Ingreso mensual base en pesos enteros
  final int monthlyIncome;

  /// Reserva mensual por defecto en pesos enteros
  final int defaultReserve;

  /// Día del mes en que recibe el salario
  final int salaryDay;

  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    this.currency = 'COP',
    this.locale = 'es_CO',
    this.timezone = 'America/Bogota',
    required this.monthlyIncome,
    required this.defaultReserve,
    this.salaryDay = 30,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? currency,
    String? locale,
    String? timezone,
    int? monthlyIncome,
    int? defaultReserve,
    int? salaryDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      timezone: timezone ?? this.timezone,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      defaultReserve: defaultReserve ?? this.defaultReserve,
      salaryDay: salaryDay ?? this.salaryDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, currency, monthlyIncome, defaultReserve, salaryDay];
}
