import 'package:uuid/uuid.dart';

class Appointment {
  final String id;
  final String clientId;
  final String serviceId;
  final DateTime dateTime;
  final String? notes;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    String? id,
    required this.clientId,
    required this.serviceId,
    required this.dateTime,
    this.notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? 'pending',
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'serviceId': serviceId,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      clientId: map['clientId'],
      serviceId: map['serviceId'],
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Appointment copyWith({
    String? id,
    String? clientId,
    String? serviceId,
    DateTime? dateTime,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      serviceId: serviceId ?? this.serviceId,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
