import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/client.dart';

class ClientRepository {
  final SupabaseClient _client = SupabaseService.client;
  static const String _table = 'clients';

  Future<String> createClient(Client client) async {
    try {
      final response = await _client
          .from(_table)
          .insert(client.toMap())
          .select()
          .single();

      return response['id'];
    } catch (e) {
      print('Error creating client: $e');
      rethrow;
    }
  }

  Future<Client?> getClient(String id) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .single();

      return Client.fromMap(response);
    } catch (e) {
      print('Error getting client: $e');
      return null;
    }
  }

  Future<List<Client>> getAllClients() async {
    try {
      final response = await _client
          .from(_table)
          .select();

      return (response as List)
          .map((json) => Client.fromMap(json))
          .toList();
    } catch (e) {
      print('Error getting all clients: $e');
      return [];
    }
  }

  Future<bool> updateClient(Client client) async {
    try {
      await _client
          .from(_table)
          .update(client.toMap())
          .eq('id', client.id);

      return true;
    } catch (e) {
      print('Error updating client: $e');
      return false;
    }
  }

  Future<bool> deleteClient(String id) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting client: $e');
      return false;
    }
  }

  Future<List<Client>> searchClients(String query) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .or('firstName.ilike.%$query%,lastName.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%')
          .order('lastName', ascending: true);

      return (response as List)
          .map((json) => Client.fromMap(json))
          .toList();
    } catch (e) {
      print('Error searching clients: $e');
      return [];
    }
  }
}
