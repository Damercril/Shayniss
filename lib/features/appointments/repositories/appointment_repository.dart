import '../../../core/services/supabase_service.dart';
import '../models/appointment.dart';

class AppointmentRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  Future<String> createAppointment(Appointment appointment) async {
    await _supabaseService.createAppointment(appointment.toMap());
    return appointment.id;
  }

  Future<Appointment?> getAppointment(String id) async {
    try {
      final data = await _supabaseService.getAppointment(id);
      return Appointment.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    try {
      final List<Map<String, dynamic>> data = await _supabaseService.getAppointmentsByDate(date);
      return data.map((json) => Appointment.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateAppointment(Appointment appointment) async {
    try {
      await _supabaseService.updateAppointment(appointment.id, appointment.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAppointment(String id) async {
    try {
      await _supabaseService.deleteAppointment(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Appointment>> getAppointmentsByDateRange(DateTime start, DateTime end) async {
    try {
      final response = await _supabaseService.client
          .from('appointments')
          .select('''
            *,
            clients (
              firstName,
              lastName,
              phone
            ),
            services (
              name,
              duration
            )
          ''')
          .gte('dateTime', start.toIso8601String())
          .lt('dateTime', end.toIso8601String())
          .order('dateTime', ascending: true);
      
      return (response as List).map((json) => Appointment.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Appointment>> getClientAppointments(String clientId) async {
    try {
      final response = await _supabaseService.client
          .from('appointments')
          .select('''
            *,
            services (
              name,
              duration
            )
          ''')
          .eq('clientId', clientId)
          .order('dateTime', ascending: false);
      
      return (response as List).map((json) => Appointment.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
