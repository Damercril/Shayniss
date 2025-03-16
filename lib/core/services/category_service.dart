import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/service_category.dart';

class CategoryService {
  final SupabaseClient _client = SupabaseService.client;
  static const String _categoriesTable = 'service_categories';
  static const String _imagesTable = 'service_images';

  Future<List<ServiceCategory>> getAllCategories() async {
    try {
      final response = await _client
          .from(_categoriesTable)
          .select()
          .order('name', ascending: true);
      
      return List<ServiceCategory>.from(
        response.map((json) => ServiceCategory.fromJson(json)),
      );
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  Future<List<String>> getImagesByCategory(String category) async {
    try {
      final response = await _client
          .from(_imagesTable)
          .select('url')
          .eq('category', category.toLowerCase())
          .order('created_at', ascending: true);
      
      return List<String>.from(
        response.map((image) => image['url'] as String),
      );
    } catch (e) {
      print('Error getting images for category $category: $e');
      return [];
    }
  }

  Future<List<String>> getRandomServiceImages({int count = 3}) async {
    try {
      final response = await _client
          .from(_imagesTable)
          .select('url')
          .limit(count)
          .order('RANDOM()');
      
      return List<String>.from(
        response.map((image) => image['url'] as String),
      );
    } catch (e) {
      print('Error getting random images: $e');
      return [];
    }
  }
}
