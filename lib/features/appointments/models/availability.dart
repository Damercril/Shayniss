import 'package:uuid/uuid.dart';

class Availability {
  final String id;
  final String professionalId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isRecurring;
  final String? recurrenceRule; // Format iCal RRULE
  final List<String> excludedDates; // Dates exclues de la récurrence
  final bool isAvailable;
  final String? notes;

  Availability({
    String? id,
    required this.professionalId,
    required this.startTime,
    required this.endTime,
    this.isRecurring = false,
    this.recurrenceRule,
    List<String>? excludedDates,
    this.isAvailable = true,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        excludedDates = excludedDates ?? [];

  // Vérifie si un créneau est disponible pour une date donnée
  bool isAvailableAt(DateTime dateTime) {
    if (!isAvailable) return false;
    
    // Vérifier si la date est exclue
    if (excludedDates.contains(dateTime.toIso8601String().split('T')[0])) {
      return false;
    }

    // Pour les disponibilités non récurrentes
    if (!isRecurring) {
      return dateTime.isAfter(startTime) && dateTime.isBefore(endTime);
    }

    // Pour les disponibilités récurrentes
    // TODO: Implémenter la logique de récurrence avec le RRULE
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'professionalId': professionalId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule,
      'excludedDates': excludedDates,
      'isAvailable': isAvailable,
      'notes': notes,
    };
  }

  factory Availability.fromMap(Map<String, dynamic> map) {
    return Availability(
      id: map['id'],
      professionalId: map['professionalId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      isRecurring: map['isRecurring'] ?? false,
      recurrenceRule: map['recurrenceRule'],
      excludedDates: List<String>.from(map['excludedDates'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      notes: map['notes'],
    );
  }

  Availability copyWith({
    String? id,
    String? professionalId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isRecurring,
    String? recurrenceRule,
    List<String>? excludedDates,
    bool? isAvailable,
    String? notes,
  }) {
    return Availability(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      excludedDates: excludedDates ?? this.excludedDates,
      isAvailable: isAvailable ?? this.isAvailable,
      notes: notes ?? this.notes,
    );
  }
}

class RecurrenceRule {
  static String daily({int? interval, DateTime? until, int? count}) {
    final List<String> parts = ['FREQ=DAILY'];
    if (interval != null) parts.add('INTERVAL=$interval');
    if (until != null) parts.add('UNTIL=${_formatDate(until)}');
    if (count != null) parts.add('COUNT=$count');
    return parts.join(';');
  }

  static String weekly({
    int? interval,
    List<int>? byDayOfWeek, // 1 = Monday, 7 = Sunday
    DateTime? until,
    int? count,
  }) {
    final List<String> parts = ['FREQ=WEEKLY'];
    if (interval != null) parts.add('INTERVAL=$interval');
    if (byDayOfWeek != null && byDayOfWeek.isNotEmpty) {
      final days = byDayOfWeek.map((day) => _getDayName(day)).join(',');
      parts.add('BYDAY=$days');
    }
    if (until != null) parts.add('UNTIL=${_formatDate(until)}');
    if (count != null) parts.add('COUNT=$count');
    return parts.join(';');
  }

  static String _formatDate(DateTime date) {
    return date.toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.')[0] + 'Z';
  }

  static String _getDayName(int day) {
    const days = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    return days[(day - 1) % 7];
  }
}
