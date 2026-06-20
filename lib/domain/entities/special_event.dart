import 'package:equatable/equatable.dart';

enum EventCategory { birthday, travel, repair, gift, medical, purchase, other }

/// Entidad de evento especial: cumpleaños, viaje, reparación, etc.
/// Gasto que solo aplica en un mes específico
class SpecialEvent extends Equatable {
  final String id;
  final String name;

  /// Valor en pesos enteros COP
  final int amount;

  /// Mes al que aplica: "2026-10"
  final String month;
  final EventCategory category;

  /// Si puede moverse a otro mes cuando el plan queda ajustado
  final bool flexible;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SpecialEvent({
    required this.id,
    required this.name,
    required this.amount,
    required this.month,
    this.category = EventCategory.other,
    this.flexible = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Retorna un DateTime aproximado del evento (día 15 del mes)
  DateTime get date {
    final parts = month.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), 15);
  }

  SpecialEvent copyWith({
    String? id,
    String? name,
    int? amount,
    String? month,
    EventCategory? category,
    bool? flexible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SpecialEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      category: category ?? this.category,
      flexible: flexible ?? this.flexible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, amount, month, category, flexible];
}
