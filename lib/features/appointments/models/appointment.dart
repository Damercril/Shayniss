import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class Appointment {
  final String id;
  final String clientId;
  final String serviceId;
  final String? professionalId;
  final String? serviceName;
  final String? professionalName;
  final DateTime dateTime;
  final String? notes;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    String? id,
    required this.clientId,
    required this.serviceId,
    this.professionalId,
    this.serviceName,
    this.professionalName,
    required this.dateTime,
    this.notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? 'pending',
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get formattedDateTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final appointmentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (appointmentDate == today) {
      return "Aujourd'hui, ${DateFormat('HH:mm').format(dateTime)}";
    } else if (appointmentDate == tomorrow) {
      return "Demain, ${DateFormat('HH:mm').format(dateTime)}";
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'serviceId': serviceId,
      'professionalId': professionalId,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Pour la compatibilité avec Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'service_id': serviceId,
      'professional_id': professionalId,
      'date_time': dateTime.toIso8601String(),
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      clientId: map['clientId'],
      serviceId: map['serviceId'],
      professionalId: map['professionalId'],
      serviceName: map['serviceName'],
      professionalName: map['professionalName'],
      dateTime: DateTime.parse(map['dateTime']),
      notes: map['notes'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Pour la compatibilité avec Supabase
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      clientId: json['client_id'],
      serviceId: json['service_id'],
      professionalId: json['professional_id'],
      serviceName: json['service_name'],
      professionalName: json['professional_name'],
      dateTime: DateTime.parse(json['date_time']),
      notes: json['notes'],
      status: json['status'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Appointment copyWith({
    String? id,
    String? clientId,
    String? serviceId,
    String? professionalId,
    String? serviceName,
    String? professionalName,
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
      professionalId: professionalId ?? this.professionalId,
      serviceName: serviceName ?? this.serviceName,
      professionalName: professionalName ?? this.professionalName,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
