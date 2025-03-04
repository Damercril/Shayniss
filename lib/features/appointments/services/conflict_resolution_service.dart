import 'package:flutter/material.dart';
import '../models/availability.dart';
import '../models/appointment.dart';
import '../../services/models/service.dart';
import 'availability_service.dart';
import 'appointment_service.dart';

class TimeSlotSuggestion {
  final DateTime startTime;
  final DateTime endTime;
  final double score; // Score de pertinence (0-1)
  final String reason;

  const TimeSlotSuggestion({
    required this.startTime,
    required this.endTime,
    required this.score,
    required this.reason,
  });
}

class ConflictResolutionService {
  static final ConflictResolutionService instance = ConflictResolutionService._();
  
  ConflictResolutionService._();

  // Trouve les créneaux alternatifs disponibles
  Future<List<TimeSlotSuggestion>> findAlternativeTimeSlots({
    required String professionalId,
    required DateTime preferredDate,
    required Service service,
    int maxSuggestions = 5,
    int maxDaysRange = 7,
  }) async {
    final suggestions = <TimeSlotSuggestion>[];
    final startDate = preferredDate.subtract(const Duration(days: 1));
    final endDate = preferredDate.add(Duration(days: maxDaysRange));

    // Récupérer toutes les disponibilités pour la période
    final availabilities = await AvailabilityService.instance
        .getAvailabilitiesByDateRange(professionalId, startDate, endDate);

    // Récupérer tous les rendez-vous pour la période
    final appointments = await AppointmentService.instance
        .getAppointmentsByDateRange(professionalId, startDate, endDate);

    // Pour chaque jour dans la plage
    for (var date = startDate;
         date.isBefore(endDate);
         date = date.add(const Duration(days: 1))) {
      
      // Pour chaque disponibilité ce jour-là
      for (final availability in availabilities) {
        if (!availability.isAvailableAt(date)) continue;

        final startOfDay = DateTime(
          date.year,
          date.month,
          date.day,
          availability.startTime.hour,
          availability.startTime.minute,
        );
        
        final endOfDay = DateTime(
          date.year,
          date.month,
          date.day,
          availability.endTime.hour,
          availability.endTime.minute,
        );

        // Vérifier chaque créneau possible dans la disponibilité
        for (var time = startOfDay;
             time.isBefore(endOfDay.subtract(Duration(minutes: service.duration)));
             time = time.add(const Duration(minutes: 15))) {
          
          final potentialEndTime = time.add(Duration(minutes: service.duration));
          
          // Vérifier s'il y a des conflits avec d'autres rendez-vous
          bool hasConflict = false;
          for (final appointment in appointments) {
            final appointmentEnd = appointment.dateTime
                .add(Duration(minutes: appointment.duration));
            
            if ((appointment.dateTime.isAfter(time) &&
                 appointment.dateTime.isBefore(potentialEndTime)) ||
                (appointmentEnd.isAfter(time) &&
                 appointmentEnd.isBefore(potentialEndTime)) ||
                (appointment.dateTime.isBefore(time) &&
                 appointmentEnd.isAfter(potentialEndTime))) {
              hasConflict = true;
              break;
            }
          }

          if (!hasConflict) {
            // Calculer un score de pertinence
            double score = 1.0;
            String reason = 'Créneau disponible';

            // Réduire le score selon la distance avec la date préférée
            final daysDifference = date.difference(preferredDate).inDays.abs();
            score -= (daysDifference * 0.1); // -0.1 par jour d'écart

            // Réduire le score pour les créneaux très tôt ou très tard
            if (time.hour < 9) {
              score -= 0.2;
              reason = 'Créneau matinal disponible';
            } else if (time.hour >= 17) {
              score -= 0.2;
              reason = 'Créneau de fin de journée disponible';
            }

            // Bonus pour les créneaux en milieu de journée
            if (time.hour >= 10 && time.hour <= 16) {
              score += 0.1;
              reason = 'Créneau idéal en milieu de journée';
            }

            // Ajouter la suggestion si le score est positif
            if (score > 0) {
              suggestions.add(TimeSlotSuggestion(
                startTime: time,
                endTime: potentialEndTime,
                score: score,
                reason: reason,
              ));
            }
          }
        }
      }
    }

    // Trier par score et limiter le nombre de suggestions
    suggestions.sort((a, b) => b.score.compareTo(a.score));
    return suggestions.take(maxSuggestions).toList();
  }

  // Vérifie si un créneau peut être déplacé
  Future<bool> canRescheduleAppointment(
    Appointment appointment,
    DateTime newDateTime,
  ) async {
    final newEndTime = newDateTime.add(Duration(minutes: appointment.duration));

    // Vérifier la disponibilité du professionnel
    final isAvailable = await AvailabilityService.instance.isTimeSlotAvailable(
      appointment.professionalId,
      newDateTime,
      newEndTime,
    );

    if (!isAvailable) return false;

    // Vérifier les conflits avec d'autres rendez-vous
    final appointments = await AppointmentService.instance
        .getAppointmentsByDateRange(
          appointment.professionalId,
          newDateTime,
          newEndTime,
        );

    for (final otherAppointment in appointments) {
      if (otherAppointment.id == appointment.id) continue;

      final otherEndTime = otherAppointment.dateTime
          .add(Duration(minutes: otherAppointment.duration));

      if ((otherAppointment.dateTime.isAfter(newDateTime) &&
           otherAppointment.dateTime.isBefore(newEndTime)) ||
          (otherEndTime.isAfter(newDateTime) &&
           otherEndTime.isBefore(newEndTime)) ||
          (otherAppointment.dateTime.isBefore(newDateTime) &&
           otherEndTime.isAfter(newEndTime))) {
        return false;
      }
    }

    return true;
  }

  // Trouve le meilleur créneau pour un rendez-vous déplacé
  Future<TimeSlotSuggestion?> findBestReschedulingSlot(
    Appointment appointment,
    DateTime preferredDate,
  ) async {
    final service = await ServiceController().getServiceById(appointment.serviceId);
    if (service == null) return null;

    final suggestions = await findAlternativeTimeSlots(
      professionalId: appointment.professionalId,
      preferredDate: preferredDate,
      service: service,
      maxSuggestions: 1,
    );

    return suggestions.isNotEmpty ? suggestions.first : null;
  }

  // Vérifie les conflits potentiels pour une période donnée
  Future<List<Appointment>> findConflictingAppointments(
    String professionalId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final appointments = await AppointmentService.instance
        .getAppointmentsByDateRange(professionalId, startTime, endTime);

    return appointments.where((appointment) {
      final appointmentEnd = appointment.dateTime
          .add(Duration(minutes: appointment.duration));

      return (appointment.dateTime.isAfter(startTime) &&
              appointment.dateTime.isBefore(endTime)) ||
             (appointmentEnd.isAfter(startTime) &&
              appointmentEnd.isBefore(endTime)) ||
             (appointment.dateTime.isBefore(startTime) &&
              appointmentEnd.isAfter(endTime));
    }).toList();
  }
}
