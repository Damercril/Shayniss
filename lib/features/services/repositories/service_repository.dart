import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/service.dart';

class ServiceRepository {
  final SupabaseClient _client = SupabaseService.client;
  static const String _table = 'services';

  Future<String> createService(Service service) async {
    try {
      final response = await _client
          .from(_table)
          .insert(service.toMap())
          .select()
          .single();

      return response['id'];
    } catch (e) {
      print('Error creating service: $e');
      rethrow;
    }
  }

  Future<Service?> getService(String id) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .single();

      return Service.fromMap(response);
    } catch (e) {
      print('Error getting service: $e');
      return null;
    }
  }

  Future<List<Service>> getAllServices() async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Service.fromMap(json))
          .toList();
    } catch (e) {
      print('Error getting all services: $e');
      return [];
    }
  }

  Future<bool> updateService(Service service) async {
    try {
      await _client
          .from(_table)
          .update(service.toMap())
          .eq('id', service.id);

      return true;
    } catch (e) {
      print('Error updating service: $e');
      return false;
    }
  }

  Future<bool> deleteService(String id) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  Future<List<Service>> getServicesByCategory(String category) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('category', category)
          .eq('isActive', true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Service.fromMap(json))
          .toList();
    } catch (e) {
      print('Error getting services by category: $e');
      return [];
    }
  }

  Future<List<Service>> searchServices(String query) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .or('name.ilike.%$query%,category.ilike.%$query%,description.ilike.%$query%')
          .eq('isActive', true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Service.fromMap(json))
          .toList();
    } catch (e) {
      print('Error searching services: $e');
      return [];
    }
  }

  Future<List<String>> getAllCategories() async {
    try {
      final response = await _client
          .from(_table)
          .select('category')
          .eq('isActive', true)
          .order('category', ascending: true);

      return (response as List)
          .map((json) => json['category'] as String)
          .toSet() // Remove duplicates
          .toList();
    } catch (e) {
      print('Error getting all categories: $e');
      return [];
    }
  }

  Future<bool> updateServicePhotos(String serviceId, List<String> photoUrls, {String? mainPhotoUrl}) async {
    try {
      final updates = {
        'photoUrls': photoUrls,
        if (mainPhotoUrl != null) 'mainPhotoUrl': mainPhotoUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _client
          .from(_table)
          .update(updates)
          .eq('id', serviceId);

      return true;
    } catch (e) {
      print('Error updating service photos: $e');
      return false;
    }
  }
}
