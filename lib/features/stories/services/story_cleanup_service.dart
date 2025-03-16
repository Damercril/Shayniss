import 'dart:async';
import 'story_database_service.dart';
import 'story_upload_service.dart';
import '../models/story.dart';

class StoryCleanupService {
  static final StoryCleanupService _instance = StoryCleanupService._internal();
  factory StoryCleanupService() => _instance;

  StoryCleanupService._internal();

  final StoryDatabaseService _databaseService = StoryDatabaseService();
  final StoryUploadService _uploadService = StoryUploadService();
  Timer? _cleanupTimer;

  void startPeriodicCleanup() {
    // Nettoyer immédiatement au démarrage
    _cleanupExpiredStories();

    // Planifier un nettoyage toutes les heures
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _cleanupExpiredStories(),
    );
  }

  void stopPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  Future<void> _cleanupExpiredStories() async {
    try {
      // Supprimer les stories expirées de la base de données
      await _databaseService.deleteExpiredStories();
    } catch (e) {
      print('Error cleaning up expired stories: $e');
    }
  }

  Future<void> cleanupStoriesForProfessional(String professionalId) async {
    try {
      final stories = await _databaseService.getStoriesByProfessionalId(professionalId);
      
      for (final story in stories) {
        if (story.isExpired) {
          await _uploadService.deleteStory(story);
        }
      }
    } catch (e) {
      print('Error cleaning up stories for professional $professionalId: $e');
    }
  }
}
