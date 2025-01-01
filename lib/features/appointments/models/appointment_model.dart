import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum AppointmentStatus {
  pending,    // En attente de confirmation
  confirmed,  // Confirmé
  completed,  // Terminé
  cancelled,  // Annulé
  noShow;     // Client absent

  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'En attente';
      case AppointmentStatus.confirmed:
        return 'Confirmé';
      case AppointmentStatus.completed:
        return 'Terminé';
      case AppointmentStatus.cancelled:
        return 'Annulé';
      case AppointmentStatus.noShow:
        return 'Absent';
    }
  }

  Color get color {
    switch (this) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }
}

class Appointment {
  final String id;
  final String clientId;
  final String clientName;
  final DateTime dateTime;
  final Duration duration;
  final List<String> services;
  final double totalPrice;
  final String notes;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    String? id,
    required this.clientId,
    required this.clientName,
    required this.dateTime,
    required this.duration,
    required this.services,
    required this.totalPrice,
    this.notes = '',
    this.status = AppointmentStatus.pending,
    DateTime? createdAt,
    this.updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Appointment copyWith({
    String? clientId,
    String? clientName,
    DateTime? dateTime,
    Duration? duration,
    List<String>? services,
    double? totalPrice,
    String? notes,
    AppointmentStatus? status,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      services: services ?? this.services,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'dateTime': dateTime.toIso8601String(),
      'duration': duration.inMinutes,
      'services': services,
      'totalPrice': totalPrice,
      'notes': notes,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      dateTime: DateTime.parse(json['dateTime']),
      duration: Duration(minutes: json['duration']),
      services: List<String>.from(json['services']),
      totalPrice: json['totalPrice'].toDouble(),
      notes: json['notes'],
      status: AppointmentStatus.values[json['status']],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  bool get isPending => status == AppointmentStatus.pending;
  bool get isConfirmed => status == AppointmentStatus.confirmed;
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;
  bool get isNoShow => status == AppointmentStatus.noShow;

  bool get isUpcoming =>
      (isPending || isConfirmed) && dateTime.isAfter(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  String get formattedTime =>
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }

  String get formattedDate {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "Aujourd'hui";
    } else if (dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day) {
      return 'Demain';
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Hier';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    }
  }
}
