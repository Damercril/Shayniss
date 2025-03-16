import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      debug: false,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static String? getCurrentUserId() {
    return client.auth.currentUser?.id;
  }

  static bool isAuthenticated() {
    return client.auth.currentUser != null;
  }

  // Clients
  Future<List<Map<String, dynamic>>> getAllClients() async {
    final response = await client
        .from('clients')
        .select()
        .order('lastName', ascending: true);
    return response;
  }

  Future<Map<String, dynamic>> getClient(String id) async {
    final response = await client
        .from('clients')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  Future<void> createClient(Map<String, dynamic> data) async {
    await client.from('clients').insert(data);
  }

  Future<void> updateClient(String id, Map<String, dynamic> updates) async {
    await client
        .from('clients')
        .update(updates)
        .eq('id', id);
  }

  Future<void> deleteClient(String id) async {
    await client
        .from('clients')
        .delete()
        .eq('id', id);
  }

  // Services
  Future<List<Map<String, dynamic>>> getAllServices() async {
    final response = await client
        .from('services')
        .select()
        .order('name', ascending: true);
    return response;
  }

  Future<Map<String, dynamic>> getService(String id) async {
    final response = await client
        .from('services')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  Future<void> createService(Map<String, dynamic> data) async {
    await client.from('services').insert(data);
  }

  Future<void> updateService(String id, Map<String, dynamic> updates) async {
    await client
        .from('services')
        .update(updates)
        .eq('id', id);
  }

  Future<void> deleteService(String id) async {
    await client
        .from('services')
        .delete()
        .eq('id', id);
  }

  // Appointments
  Future<List<Map<String, dynamic>>> getAppointmentsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await client
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
        .gte('dateTime', startOfDay.toIso8601String())
        .lt('dateTime', endOfDay.toIso8601String())
        .order('dateTime', ascending: true);
    return response;
  }

  Future<Map<String, dynamic>> getAppointment(String id) async {
    final response = await client
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
        .eq('id', id)
        .single();
    return response;
  }

  Future<void> createAppointment(Map<String, dynamic> data) async {
    await client.from('appointments').insert(data);
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> updates) async {
    await client
        .from('appointments')
        .update(updates)
        .eq('id', id);
  }

  Future<void> deleteAppointment(String id) async {
    await client
        .from('appointments')
        .delete()
        .eq('id', id);
  }

  // Availability operations
  Future<List<Map<String, dynamic>>> getAvailabilities(String professionalId) async {
    final response = await client
        .from('availabilities')
        .select()
        .eq('professionalId', professionalId)
        .order('startTime', ascending: true);
    return response;
  }

  Future<Map<String, dynamic>> getAvailability(String id) async {
    final response = await client
        .from('availabilities')
        .select()
        .eq('id', id)
        .single();
    return response;
  }

  Future<void> createAvailability(Map<String, dynamic> data) async {
    await client.from('availabilities').insert(data);
  }

  Future<void> updateAvailability(String id, Map<String, dynamic> updates) async {
    await client
        .from('availabilities')
        .update(updates)
        .eq('id', id);
  }

  Future<void> deleteAvailability(String id) async {
    await client
        .from('availabilities')
        .delete()
        .eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getAvailabilitiesForDateRange(
    String professionalId,
    DateTime start,
    DateTime end,
  ) async {
    final response = await client
        .from('availabilities')
        .select()
        .eq('professionalId', professionalId)
        .eq('isAvailable', true)
        .or('and(startTime.gte.${start.toIso8601String()},endTime.lte.${end.toIso8601String()}),isRecurring.eq.true')
        .order('startTime', ascending: true);
    return response;
  }
}
