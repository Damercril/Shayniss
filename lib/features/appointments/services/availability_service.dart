import '../models/availability.dart';
import '../repositories/availability_repository.dart';
import '../repositories/appointment_repository.dart';
import '../models/appointment.dart';

class AvailabilityService {
  static final AvailabilityService instance = AvailabilityService._();
  final AvailabilityRepository _availabilityRepository = AvailabilityRepository();
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  AvailabilityService._();

  // Vérifie si un créneau est disponible en tenant compte des rendez-vous existants
  Future<bool> isTimeSlotAvailable(
    String professionalId,
    DateTime start,
    DateTime end,
  ) async {
    // 1. Vérifier si le créneau est dans une plage de disponibilité
    final availabilities = await _availabilityRepository.getAvailabilitiesForDateRange(
      professionalId,
      start,
      end,
    );

    // Vérifier si au moins une disponibilité couvre ce créneau
    bool isInAvailabilitySlot = false;
    for (var availability in availabilities) {
      if (availability.isAvailableAt(start) && availability.isAvailableAt(end)) {
        isInAvailabilitySlot = true;
        break;
      }
    }

    if (!isInAvailabilitySlot) return false;

    // 2. Vérifier s'il n'y a pas de rendez-vous qui chevauche ce créneau
    final appointments = await _appointmentRepository.getAppointmentsByDateRange(start, end);
    
    return !appointments.any((appointment) {
      final appointmentStart = appointment.dateTime;
      final appointmentEnd = appointmentStart.add(Duration(minutes: appointment.duration));
      
      return (start.isBefore(appointmentEnd) && end.isAfter(appointmentStart));
    });
  }

  // Génère les créneaux disponibles pour une journée
  Future<List<DateTime>> getAvailableTimeSlots(
    String professionalId,
    DateTime date,
    int duration, // durée en minutes
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    // 1. Récupérer toutes les disponibilités pour cette journée
    final availabilities = await _availabilityRepository.getAvailabilitiesForDateRange(
      professionalId,
      start,
      end,
    );

    // 2. Récupérer tous les rendez-vous pour cette journée
    final appointments = await _appointmentRepository.getAppointmentsByDateRange(start, end);

    // Créer une liste de tous les créneaux possibles
    final List<DateTime> timeSlots = [];
    
    // Pour chaque disponibilité
    for (var availability in availabilities) {
      if (!availability.isAvailable) continue;

      // Déterminer l'heure de début et de fin pour cette journée
      DateTime slotStart;
      DateTime slotEnd;

      if (availability.isRecurring) {
        // Pour les disponibilités récurrentes, utiliser l'heure de la disponibilité
        // avec la date demandée
        slotStart = DateTime(
          date.year,
          date.month,
          date.day,
          availability.startTime.hour,
          availability.startTime.minute,
        );
        slotEnd = DateTime(
          date.year,
          date.month,
          date.day,
          availability.endTime.hour,
          availability.endTime.minute,
        );

        // Vérifier si cette date est incluse dans la récurrence
        if (!availability.isAvailableAt(slotStart)) {
          continue;
        }
      } else {
        // Pour les disponibilités non récurrentes, utiliser directement les dates
        slotStart = availability.startTime;
        slotEnd = availability.endTime;
      }

      // Générer les créneaux pour cette disponibilité
      var currentSlot = slotStart;
      while (currentSlot.add(Duration(minutes: duration)).isBefore(slotEnd) || 
             currentSlot.add(Duration(minutes: duration)).isAtSameMomentAs(slotEnd)) {
        
        // Vérifier si le créneau chevauche un rendez-vous existant
        bool isOverlapping = appointments.any((appointment) {
          final appointmentStart = appointment.dateTime;
          final appointmentEnd = appointmentStart.add(Duration(minutes: appointment.duration));
          
          return (currentSlot.isBefore(appointmentEnd) && 
                 currentSlot.add(Duration(minutes: duration)).isAfter(appointmentStart));
        });

        if (!isOverlapping) {
          timeSlots.add(currentSlot);
        }

        // Passer au créneau suivant
        currentSlot = currentSlot.add(Duration(minutes: duration));
      }
    }

    return timeSlots..sort();
  }

  // Crée une nouvelle disponibilité
  Future<void> createAvailability(Availability availability) async {
    await _availabilityRepository.createAvailability(availability);
  }

  // Met à jour une disponibilité existante
  Future<void> updateAvailability(Availability availability) async {
    await _availabilityRepository.updateAvailability(availability);
  }

  // Supprime une disponibilité
  Future<void> deleteAvailability(String availabilityId) async {
    await _availabilityRepository.deleteAvailability(availabilityId);
  }

  // Crée une disponibilité récurrente
  Future<void> createRecurringAvailability({
    required String professionalId,
    required DateTime startTime,
    required DateTime endTime,
    required String recurrenceRule,
    String? notes,
  }) async {
    final availability = Availability(
      professionalId: professionalId,
      startTime: startTime,
      endTime: endTime,
      isRecurring: true,
      recurrenceRule: recurrenceRule,
      notes: notes,
    );

    await createAvailability(availability);
  }

  // Exclut une date d'une disponibilité récurrente
  Future<void> excludeDate(String availabilityId, DateTime date) async {
    final availability = await _availabilityRepository.getAvailability(availabilityId);
    if (availability == null) return;

    final dateString = date.toIso8601String().split('T')[0];
    if (!availability.excludedDates.contains(dateString)) {
      final updatedAvailability = availability.copyWith(
        excludedDates: [...availability.excludedDates, dateString],
      );
      await updateAvailability(updatedAvailability);
    }
  }

  // Réintègre une date précédemment exclue
  Future<void> includeDate(String availabilityId, DateTime date) async {
    final availability = await _availabilityRepository.getAvailability(availabilityId);
    if (availability == null) return;

    final dateString = date.toIso8601String().split('T')[0];
    if (availability.excludedDates.contains(dateString)) {
      final updatedAvailability = availability.copyWith(
        excludedDates: availability.excludedDates.where((d) => d != dateString).toList(),
      );
      await updateAvailability(updatedAvailability);
    }
  }
}
