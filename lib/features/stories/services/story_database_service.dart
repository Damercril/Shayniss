import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/base_database_service.dart';
import '../models/story.dart';

class StoryDatabaseService extends BaseDatabaseService<Story> {
  static final StoryDatabaseService _instance = StoryDatabaseService._internal();
  factory StoryDatabaseService() => _instance;
  StoryDatabaseService._internal() : super('stories');

  @override
  Story fromJson(Map<String, dynamic> json) => Story.fromJson(json);

  Future<List<Story>> getStoriesByProfessionalId(String professionalId) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('professional_id', professionalId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((story) => fromJson(story))
          .where((story) => !story.isExpired)
          .toList();
    } catch (e) {
      print('Error getting stories: $e');
      return [];
    }
  }

  Future<void> createStory({
    required String professionalId,
    required String url,
    required String type,
  }) async {
    try {
      final expiresAt = DateTime.now().add(const Duration(hours: 24));
      
      await client.from(tableName).insert({
        'professional_id': professionalId,
        'url': url,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'seen': false,
        'views': 0,
      });
    } catch (e) {
      print('Error creating story: $e');
      rethrow;
    }
  }

  Future<void> markStorySeen(String storyId) async {
    try {
      await client
          .from(tableName)
          .update({'seen': true})
          .eq('id', storyId);
    } catch (e) {
      print('Error marking story as seen: $e');
      rethrow;
    }
  }

  Future<void> incrementViews(String storyId) async {
    try {
      await client.rpc(
        'increment_story_views',
        params: {'story_id': storyId},
      );
    } catch (e) {
      print('Error incrementing story views: $e');
      rethrow;
    }
  }

  Future<void> deleteExpiredStories() async {
    try {
      final now = DateTime.now().toIso8601String();
      await client
          .from(tableName)
          .delete()
          .lt('expires_at', now);
    } catch (e) {
      print('Error deleting expired stories: $e');
      rethrow;
    }
  }
}
