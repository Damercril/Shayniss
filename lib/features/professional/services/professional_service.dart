import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/base_database_service.dart';
import '../models/professional_profile.dart';

class ProfessionalService extends BaseDatabaseService<ProfessionalProfile> {
  static final ProfessionalService _instance = ProfessionalService._internal();
  factory ProfessionalService() => _instance;

  ProfessionalService._internal() : super('professionals');

  @override
  ProfessionalProfile fromJson(Map<String, dynamic> json) => ProfessionalProfile.fromJson(json);

  @override
  Map<String, dynamic> toJson(ProfessionalProfile profile) => profile.toJson();

  Future<ProfessionalProfile?> getProfileById(String id) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('id', id)
          .single();

      if (response == null) return null;
      return fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error getting professional profile: $e');
      return null;
    }
  }

  Future<List<ProfessionalProfile>> searchProfessionals({
    String? query,
    String? category,
    double? maxDistance,
    double? maxPrice,
    double? minRating,
  }) async {
    try {
      var request = client.from(tableName).select();

      if (query != null && query.isNotEmpty) {
        request = request.textSearch('name', query);
      }

      if (category != null) {
        request = request.eq('category', category);
      }

      if (minRating != null) {
        request = request.gte('rating', minRating);
      }

      final response = await request;

      return (response as List)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching professionals: $e');
      return [];
    }
  }

  Future<void> updateProfile(ProfessionalProfile profile) async {
    try {
      await client
          .from(tableName)
          .update(toJson(profile))
          .eq('id', profile.id);
    } catch (e) {
      print('Error updating professional profile: $e');
      rethrow;
    }
  }
}
