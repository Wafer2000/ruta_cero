import 'package:equatable/equatable.dart';

/// Entidad de log de auditoría para tracking de cambios
class AuditEntry extends Equatable {
  final String id;
  final String entity;
  final String entityId;
  final String action;
  final String? description;
  final DateTime createdAt;

  const AuditEntry({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.action,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, entity, entityId, action, description, createdAt];
}
