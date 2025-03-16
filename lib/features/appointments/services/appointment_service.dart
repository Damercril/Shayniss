import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment.dart';

class AppointmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Appointment>> getUpcomingAppointments() async {
    try {
      final response = await _supabase
          .from('appointments')
          .select('''
            *,
            professionals:professional_id (
              name
            ),
            services:service_id (
              name
            )
          ''')
          .eq('status', 'confirmed')
          .gte('date_time', DateTime.now().toIso8601String())
          .order('date_time', ascending: true)
          .limit(5);

      return (response as List).map((data) {
        // Fusionner les données du professionnel et du service
        final Map<String, dynamic> appointment = {
          ...data,
          'professional_name': data['professionals']['name'],
          'service_name': data['services']['name'],
        };
        return Appointment.fromJson(appointment);
      }).toList();
    } catch (e) {
      print('Error getting upcoming appointments: $e');
      return [];
    }
  }

  Future<bool> createAppointment(Appointment appointment) async {
    try {
      await _supabase.from('appointments').insert(appointment.toJson());
      return true;
    } catch (e) {
      print('Error creating appointment: $e');
      return false;
    }
  }

  Future<bool> updateAppointment(Appointment appointment) async {
    try {
      await _supabase
          .from('appointments')
          .update(appointment.toJson())
          .eq('id', appointment.id);
      return true;
    } catch (e) {
      print('Error updating appointment: $e');
      return false;
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      await _supabase
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('id', appointmentId);
      return true;
    } catch (e) {
      print('Error cancelling appointment: $e');
      return false;
    }
  }
}
