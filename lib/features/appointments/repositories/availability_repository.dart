import '../../../core/services/supabase_service.dart';
import '../models/availability.dart';

class AvailabilityRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  Future<List<Availability>> getAvailabilities(String professionalId) async {
    try {
      final List<Map<String, dynamic>> data = await _supabaseService.getAvailabilities(professionalId);
      return data.map((json) => Availability.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Availability?> getAvailability(String id) async {
    try {
      final data = await _supabaseService.getAvailability(id);
      return Availability.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<String> createAvailability(Availability availability) async {
    await _supabaseService.createAvailability(availability.toMap());
    return availability.id;
  }

  Future<bool> updateAvailability(Availability availability) async {
    try {
      await _supabaseService.updateAvailability(availability.id, availability.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAvailability(String id) async {
    try {
      await _supabaseService.deleteAvailability(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Availability>> getAvailabilitiesForDateRange(
    String professionalId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final List<Map<String, dynamic>> data = await _supabaseService.getAvailabilitiesForDateRange(
        professionalId,
        start,
        end,
      );
      return data.map((json) => Availability.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Vérifie si un créneau est disponible
  Future<bool> isTimeSlotAvailable(
    String professionalId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final availabilities = await getAvailabilitiesForDateRange(
        professionalId,
        start,
        end,
      );

      // Vérifie si au moins une disponibilité couvre entièrement le créneau demandé
      return availabilities.any((availability) =>
          availability.isAvailable &&
          availability.isAvailableAt(start) &&
          availability.isAvailableAt(end));
    } catch (e) {
      return false;
    }
  }
}
