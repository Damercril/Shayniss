import 'package:flutter/material.dart';
import '../models/availability.dart';
import '../models/appointment.dart';
import 'availability_service.dart';
import 'appointment_service.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String>? conflicts;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.conflicts,
  });

  static ValidationResult success() => const ValidationResult(isValid: true);
  
  static ValidationResult error(String message, [List<String>? conflicts]) => 
    ValidationResult(isValid: false, errorMessage: message, conflicts: conflicts);
}

class ValidationService {
  static final ValidationService instance = ValidationService._();
  
  ValidationService._();

  // Validation des horaires de base
  ValidationResult validateTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
    final start = DateTime(2024, 1, 1, startTime.hour, startTime.minute);
    final end = DateTime(2024, 1, 1, endTime.hour, endTime.minute);

    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      return ValidationResult.error(
        'L\'heure de fin doit être après l\'heure de début'
      );
    }

    // Vérifier si la durée est d'au moins 15 minutes
    final duration = end.difference(start).inMinutes;
    if (duration < 15) {
      return ValidationResult.error(
        'La durée minimale d\'une disponibilité est de 15 minutes'
      );
    }

    return ValidationResult.success();
  }

  // Validation d'une nouvelle disponibilité
  Future<ValidationResult> validateNewAvailability(
    String professionalId,
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
    {String? excludeAvailabilityId}
  ) async {
    // Valider les horaires de base
    final timeValidation = validateTimeRange(startTime, endTime);
    if (!timeValidation.isValid) {
      return timeValidation;
    }

    // Vérifier les chevauchements avec d'autres disponibilités
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    final existingAvailabilities = await AvailabilityService.instance
        .getAvailabilities(professionalId);

    final conflicts = <String>[];
    
    for (final availability in existingAvailabilities) {
      // Ignorer la disponibilité en cours de modification
      if (excludeAvailabilityId != null && 
          availability.id == excludeAvailabilityId) {
        continue;
      }

      if (availability.isAvailableAt(startDateTime) ||
          availability.isAvailableAt(endDateTime.subtract(const Duration(minutes: 1)))) {
        conflicts.add(
          '${availability.startTime.hour}:${availability.startTime.minute.toString().padLeft(2, '0')} - '
          '${availability.endTime.hour}:${availability.endTime.minute.toString().padLeft(2, '0')}'
        );
      }
    }

    if (conflicts.isNotEmpty) {
      return ValidationResult.error(
        'Cette disponibilité chevauche d\'autres créneaux :',
        conflicts,
      );
    }

    // Vérifier les chevauchements avec les rendez-vous
    final appointments = await AppointmentService.instance
        .getAppointmentsByDateRange(professionalId, startDateTime, endDateTime);

    final appointmentConflicts = <String>[];
    
    for (final appointment in appointments) {
      final appointmentEnd = appointment.dateTime.add(
        Duration(minutes: appointment.duration)
      );

      if ((appointment.dateTime.isAfter(startDateTime) &&
           appointment.dateTime.isBefore(endDateTime)) ||
          (appointmentEnd.isAfter(startDateTime) &&
           appointmentEnd.isBefore(endDateTime)) ||
          (appointment.dateTime.isBefore(startDateTime) &&
           appointmentEnd.isAfter(endDateTime))) {
        appointmentConflicts.add(
          '${appointment.clientName} - '
          '${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}'
        );
      }
    }

    if (appointmentConflicts.isNotEmpty) {
      return ValidationResult.error(
        'Cette disponibilité chevauche des rendez-vous existants :',
        appointmentConflicts,
      );
    }

    return ValidationResult.success();
  }

  // Validation d'un nouveau rendez-vous
  Future<ValidationResult> validateNewAppointment(
    String professionalId,
    DateTime dateTime,
    int duration,
    {String? excludeAppointmentId}
  ) async {
    if (duration < 15) {
      return ValidationResult.error(
        'La durée minimale d\'un rendez-vous est de 15 minutes'
      );
    }

    final endDateTime = dateTime.add(Duration(minutes: duration));

    // Vérifier si le créneau est disponible
    final isAvailable = await AvailabilityService.instance.isTimeSlotAvailable(
      professionalId,
      dateTime,
      endDateTime,
    );

    if (!isAvailable) {
      return ValidationResult.error(
        'Ce créneau n\'est pas disponible'
      );
    }

    // Vérifier les chevauchements avec d'autres rendez-vous
    final appointments = await AppointmentService.instance
        .getAppointmentsByDateRange(professionalId, dateTime, endDateTime);

    final conflicts = <String>[];
    
    for (final appointment in appointments) {
      // Ignorer le rendez-vous en cours de modification
      if (excludeAppointmentId != null && 
          appointment.id == excludeAppointmentId) {
        continue;
      }

      final appointmentEnd = appointment.dateTime.add(
        Duration(minutes: appointment.duration)
      );

      if ((appointment.dateTime.isAfter(dateTime) &&
           appointment.dateTime.isBefore(endDateTime)) ||
          (appointmentEnd.isAfter(dateTime) &&
           appointmentEnd.isBefore(endDateTime)) ||
          (appointment.dateTime.isBefore(dateTime) &&
           appointmentEnd.isAfter(endDateTime))) {
        conflicts.add(
          '${appointment.clientName} - '
          '${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}'
        );
      }
    }

    if (conflicts.isNotEmpty) {
      return ValidationResult.error(
        'Ce rendez-vous chevauche d\'autres rendez-vous :',
        conflicts,
      );
    }

    return ValidationResult.success();
  }

  // Validation des règles de récurrence
  ValidationResult validateRecurrenceRule(String rule) {
    if (rule.isEmpty) {
      return ValidationResult.success();
    }

    try {
      final parts = rule.split(';');
      final freq = parts.firstWhere(
        (p) => p.startsWith('FREQ='),
        orElse: () => '',
      );

      if (freq.isEmpty) {
        return ValidationResult.error(
          'La règle de récurrence doit spécifier une fréquence (FREQ)'
        );
      }

      final validFreqs = ['DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];
      final freqValue = freq.split('=')[1];
      
      if (!validFreqs.contains(freqValue)) {
        return ValidationResult.error(
          'Fréquence invalide. Valeurs possibles : ${validFreqs.join(", ")}'
        );
      }

      // Valider INTERVAL si présent
      final interval = parts.firstWhere(
        (p) => p.startsWith('INTERVAL='),
        orElse: () => '',
      );

      if (interval.isNotEmpty) {
        final intervalValue = int.tryParse(interval.split('=')[1]);
        if (intervalValue == null || intervalValue < 1) {
          return ValidationResult.error(
            'L\'intervalle doit être un nombre entier positif'
          );
        }
      }

      // Valider UNTIL si présent
      final until = parts.firstWhere(
        (p) => p.startsWith('UNTIL='),
        orElse: () => '',
      );

      if (until.isNotEmpty) {
        final untilValue = until.split('=')[1];
        if (!RegExp(r'^\d{8}T\d{6}Z$').hasMatch(untilValue)) {
          return ValidationResult.error(
            'Format de date de fin invalide. Format attendu : YYYYMMDDTHHMMSSZ'
          );
        }
      }

      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error(
        'Format de règle de récurrence invalide'
      );
    }
  }
}
