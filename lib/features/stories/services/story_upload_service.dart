import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../core/services/base_storage_service.dart';
import 'story_database_service.dart';

class StoryUploadService {
  static final StoryUploadService _instance = StoryUploadService._internal();
  factory StoryUploadService() => _instance;
  StoryUploadService._internal();

  final BaseStorageService _storageService = BaseStorageService('stories');
  final StoryDatabaseService _storyService = StoryDatabaseService();

  Future<void> uploadStory({
    required String professionalId,
    required File file,
    required bool isVideo,
  }) async {
    try {
      // Générer un nom de fichier unique
      final extension = path.extension(file.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
      final filePath = '$professionalId/$fileName';

      // Upload du fichier vers Supabase Storage
      final url = await _storageService.uploadFile(
        file: file,
        path: filePath,
      );

      // Créer l'entrée dans la base de données
      await _storyService.createStory(
        professionalId: professionalId,
        url: url,
        type: isVideo ? 'video' : 'image',
      );
    } catch (e) {
      print('Error uploading story: $e');
      rethrow;
    }
  }

  Future<void> deleteStory(String professionalId, String url) async {
    try {
      // Extraire le chemin du fichier de l'URL
      final uri = Uri.parse(url);
      final filePath = uri.pathSegments.last;
      final fullPath = '$professionalId/$filePath';

      // Supprimer le fichier de Supabase Storage
      await _storageService.deleteFile(fullPath);
    } catch (e) {
      print('Error deleting story: $e');
      rethrow;
    }
  }
}
