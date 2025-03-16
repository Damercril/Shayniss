import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/story.dart';

class StoryDatabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'stories';

  Future<List<Story>> getStoriesByProfessionalId(String professionalId) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('professional_id', professionalId)
          .gte('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Story.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting stories: $e');
      rethrow;
    }
  }

  Future<void> markAsSeen(String storyId) async {
    try {
      await _client
          .from(_table)
          .update({'seen': true})
          .eq('id', storyId);
    } catch (e) {
      print('Error marking story as seen: $e');
      rethrow;
    }
  }

  Future<void> incrementViews(String storyId) async {
    try {
      await _client
          .rpc('increment_story_views', params: {'story_id': storyId});
    } catch (e) {
      print('Error incrementing story views: $e');
      rethrow;
    }
  }

  Future<void> deleteExpiredStories() async {
    try {
      await _client
          .from(_table)
          .delete()
          .lt('expires_at', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error deleting expired stories: $e');
      rethrow;
    }
  }

  Future<Story> createStory({
    required String professionalId,
    required String url,
    required String type,
    String? thumbnailUrl,
  }) async {
    try {
      final expiresAt = DateTime.now().add(const Duration(hours: 24));
      
      final response = await _client
          .from(_table)
          .insert({
            'professional_id': professionalId,
            'url': url,
            'type': type,
            'thumbnail_url': thumbnailUrl,
            'expires_at': expiresAt.toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Story.fromJson(response);
    } catch (e) {
      print('Error creating story: $e');
      rethrow;
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', storyId);
    } catch (e) {
      print('Error deleting story: $e');
      rethrow;
    }
  }
}
