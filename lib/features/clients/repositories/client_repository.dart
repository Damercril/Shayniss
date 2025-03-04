import '../../../core/services/supabase_service.dart';
import '../models/client.dart';

class ClientRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  Future<String> createClient(Client client) async {
    await _supabaseService.createClient(client.toMap());
    return client.id;
  }

  Future<Client?> getClient(String id) async {
    try {
      final data = await _supabaseService.getClient(id);
      return Client.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<Client>> getAllClients() async {
    final List<Map<String, dynamic>> data = await _supabaseService.getAllClients();
    return data.map((json) => Client.fromMap(json)).toList();
  }

  Future<bool> updateClient(Client client) async {
    try {
      await _supabaseService.updateClient(client.id, client.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteClient(String id) async {
    try {
      await _supabaseService.deleteClient(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Client>> searchClients(String query) async {
    try {
      final response = await _supabaseService.client
          .from('clients')
          .select()
          .or('firstName.ilike.%$query%,lastName.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%')
          .order('lastName', ascending: true);
      
      return (response as List).map((json) => Client.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
