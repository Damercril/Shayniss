import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/appointment.dart';

class AppointmentRepository {
  final SupabaseClient _client = SupabaseService.client;
  static const String _table = 'appointments';

  Future<String> createAppointment(Appointment appointment) async {
    try {
      final response = await _client
          .from(_table)
          .insert(appointment.toMap())
          .select()
          .single();

      return appointment.id;
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }

  Future<Appointment?> getAppointment(String id) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .single();

      return Appointment.fromMap(response);
    } catch (e) {
      print('Error getting appointment: $e');
      return null;
    }
  }

  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .gte('dateTime', date.toIso8601String())
          .lt('dateTime', date.add(Duration(days: 1)).toIso8601String())
          .order('dateTime', ascending: true);

      return (response as List)
          .map((json) => Appointment.fromMap(json))
          .toList();
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }

  Future<bool> updateAppointment(Appointment appointment) async {
    try {
      await _client
          .from(_table)
          .update(appointment.toMap())
          .eq('id', appointment.id);

      return true;
    } catch (e) {
      print('Error updating appointment: $e');
      return false;
    }
  }

  Future<bool> deleteAppointment(String id) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting appointment: $e');
      return false;
    }
  }

  Future<List<Appointment>> getAppointmentsByDateRange(DateTime start, DateTime end) async {
    try {
      final response = await _client
          .from(_table)
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

      return (response as List)
          .map((json) => Appointment.fromMap(json))
          .toList();
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }

  Future<List<Appointment>> getClientAppointments(String clientId) async {
    try {
      final response = await _client
          .from(_table)
          .select('''
            *,
            services (
              name,
              duration
            )
          ''')
          .eq('clientId', clientId)
          .order('dateTime', ascending: false);

      return (response as List)
          .map((json) => Appointment.fromMap(json))
          .toList();
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }
}
