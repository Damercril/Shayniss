import '../../../core/services/supabase_service.dart';
import '../models/service.dart';

class ServiceRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  Future<String> createService(Service service) async {
    await _supabaseService.createService(service.toMap());
    return service.id;
  }

  Future<Service?> getService(String id) async {
    try {
      final data = await _supabaseService.getService(id);
      return Service.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<Service>> getAllServices() async {
    try {
      final List<Map<String, dynamic>> data = await _supabaseService.getAllServices();
      return data.map((json) => Service.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateService(Service service) async {
    try {
      await _supabaseService.updateService(service.id, service.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteService(String id) async {
    try {
      await _supabaseService.deleteService(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Service>> getServicesByCategory(String category) async {
    try {
      final response = await _supabaseService.client
          .from('services')
          .select()
          .eq('category', category)
          .eq('isActive', true)
          .order('name', ascending: true);
      
      return (response as List).map((json) => Service.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Service>> searchServices(String query) async {
    try {
      final response = await _supabaseService.client
          .from('services')
          .select()
          .or('name.ilike.%$query%,category.ilike.%$query%,description.ilike.%$query%')
          .eq('isActive', true)
          .order('name', ascending: true);
      
      return (response as List).map((json) => Service.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getAllCategories() async {
    try {
      final response = await _supabaseService.client
          .from('services')
          .select('category')
          .eq('isActive', true)
          .order('category', ascending: true);
      
      return (response as List)
          .map((json) => json['category'] as String)
          .toSet() // Remove duplicates
          .toList();
    } catch (e) {
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

      await _supabaseService.updateService(serviceId, updates);
      return true;
    } catch (e) {
      return false;
    }
  }
}
