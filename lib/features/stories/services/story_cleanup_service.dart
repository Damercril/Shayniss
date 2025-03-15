import 'dart:async';
import 'story_database_service.dart';

class StoryCleanupService {
  static final StoryCleanupService _instance = StoryCleanupService._internal();
  factory StoryCleanupService() => _instance;
  StoryCleanupService._internal();

  final StoryDatabaseService _storyService = StoryDatabaseService();
  Timer? _cleanupTimer;

  void startCleanupScheduler() {
    // Nettoyer les stories expirées toutes les heures
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _cleanupExpiredStories(),
    );
  }

  void stopCleanupScheduler() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  Future<void> _cleanupExpiredStories() async {
    try {
      await _storyService.deleteExpiredStories();
    } catch (e) {
      print('Error during story cleanup: $e');
    }
  }
}
