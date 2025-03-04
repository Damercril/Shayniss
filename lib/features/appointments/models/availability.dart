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
    if (recurrenceRule == null) return false;

    final rrule = RecurrenceRule.parse(recurrenceRule!);
    if (rrule == null) return false;

    // Vérifier si la date est dans la plage de récurrence
    if (rrule.until != null && dateTime.isAfter(rrule.until!)) {
      return false;
    }

    // Vérifier si l'heure est dans la plage horaire
    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    final startTimeOfDay = TimeOfDay.fromDateTime(startTime);
    final endTimeOfDay = TimeOfDay.fromDateTime(endTime);

    if (!_isTimeBetween(timeOfDay, startTimeOfDay, endTimeOfDay)) {
      return false;
    }

    // Vérifier la récurrence selon la fréquence
    switch (rrule.frequency) {
      case 'DAILY':
        if (rrule.interval != null) {
          final days = dateTime.difference(startTime).inDays;
          return days % rrule.interval! == 0;
        }
        return true;

      case 'WEEKLY':
        // Vérifier si le jour de la semaine est inclus
        final dayOfWeek = dateTime.weekday;
        if (rrule.byDay != null && !rrule.byDay!.contains(dayOfWeek)) {
          return false;
        }
        if (rrule.interval != null) {
          final weeks = dateTime.difference(startTime).inDays ~/ 7;
          return weeks % rrule.interval! == 0;
        }
        return true;

      case 'MONTHLY':
        if (rrule.byMonthDay != null) {
          // Vérifier le jour du mois
          return rrule.byMonthDay!.contains(dateTime.day);
        }
        if (rrule.byDay != null) {
          // Vérifier la position du jour dans le mois (ex: 2ème lundi)
          final weekOfMonth = (dateTime.day - 1) ~/ 7 + 1;
          final dayOfWeek = dateTime.weekday;
          return rrule.byDay!.any((day) => 
            day.weekday == dayOfWeek && day.position == weekOfMonth);
        }
        if (rrule.interval != null) {
          final months = (dateTime.year - startTime.year) * 12 + 
                        dateTime.month - startTime.month;
          return months % rrule.interval! == 0;
        }
        return true;

      default:
        return false;
    }
  }

  bool _isTimeBetween(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final now = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return now >= startMinutes && now <= endMinutes;
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
  final String frequency;
  final int? interval;
  final List<int>? byDay;
  final List<int>? byMonthDay;
  final DateTime? until;
  final int? count;

  RecurrenceRule({
    required this.frequency,
    this.interval,
    this.byDay,
    this.byMonthDay,
    this.until,
    this.count,
  });

  static RecurrenceRule? parse(String rrule) {
    final parts = rrule.split(';');
    final Map<String, String> params = {};
    
    for (var part in parts) {
      final keyValue = part.split('=');
      if (keyValue.length == 2) {
        params[keyValue[0]] = keyValue[1];
      }
    }

    if (!params.containsKey('FREQ')) return null;

    return RecurrenceRule(
      frequency: params['FREQ']!,
      interval: params['INTERVAL'] != null ? int.tryParse(params['INTERVAL']!) : null,
      byDay: params['BYDAY']?.split(',').map((day) {
        final match = RegExp(r'(-?\d+)?([A-Z]{2})').firstMatch(day);
        if (match != null) {
          final weekday = _weekdayFromString(match.group(2)!);
          return weekday;
        }
        return null;
      }).whereType<int>().toList(),
      byMonthDay: params['BYMONTHDAY']?.split(',').map(int.parse).toList(),
      until: params['UNTIL'] != null ? DateTime.parse(params['UNTIL']!) : null,
      count: params['COUNT'] != null ? int.parse(params['COUNT']!) : null,
    );
  }

  static int? _weekdayFromString(String day) {
    const days = {
      'MO': 1, 'TU': 2, 'WE': 3, 'TH': 4, 'FR': 5, 'SA': 6, 'SU': 7
    };
    return days[day];
  }
}

class WeekdayInMonth {
  final int weekday;
  final int position;

  WeekdayInMonth(this.weekday, this.position);
}
