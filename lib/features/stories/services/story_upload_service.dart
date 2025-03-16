import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../core/services/base_storage_service.dart';
import 'story_database_service.dart';
import '../models/story.dart';

class StoryUploadService {
  final BaseStorageService _storageService = BaseStorageService('stories');
  final StoryDatabaseService _databaseService = StoryDatabaseService();

  Future<Story> uploadStory({
    required String professionalId,
    required File file,
    required bool isVideo,
  }) async {
    final String fileExtension = path.extension(file.path).toLowerCase();
    String? thumbnailUrl;

    if (isVideo) {
      if (!_isValidVideoExtension(fileExtension)) {
        throw Exception('Format vidéo non supporté. Utilisez MP4, MOV ou AVI.');
      }

      // Générer une miniature pour la vidéo
      final thumbnailFile = await _generateVideoThumbnail(file);
      if (thumbnailFile != null) {
        thumbnailUrl = await _storageService.uploadFile(
          File(thumbnailFile),
          bucket: 'thumbnails',
        );
      }
    } else {
      if (!_isValidImageExtension(fileExtension)) {
        throw Exception('Format image non supporté. Utilisez JPG, JPEG ou PNG.');
      }
    }

    // Uploader le fichier principal
    final url = await _storageService.uploadFile(file);

    // Créer l'entrée dans la base de données
    return await _databaseService.createStory(
      professionalId: professionalId,
      url: url,
      type: isVideo ? 'video' : 'image',
      thumbnailUrl: thumbnailUrl,
    );
  }

  Future<String?> _generateVideoThumbnail(File videoFile) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 75,
      );
      return thumbnailPath;
    } catch (e) {
      print('Error generating video thumbnail: $e');
      return null;
    }
  }

  bool _isValidImageExtension(String extension) {
    return ['.jpg', '.jpeg', '.png'].contains(extension);
  }

  bool _isValidVideoExtension(String extension) {
    return ['.mp4', '.mov', '.avi'].contains(extension);
  }

  Future<void> deleteStory(Story story) async {
    try {
      // Supprimer le fichier principal
      await _storageService.deleteFile(story.url);

      // Supprimer la miniature si elle existe
      if (story.thumbnailUrl != null) {
        await _storageService.deleteFile(
          story.thumbnailUrl!,
          bucket: 'thumbnails',
        );
      }

      // Supprimer l'entrée de la base de données
      await _databaseService.deleteStory(story.id);
    } catch (e) {
      print('Error deleting story: $e');
      rethrow;
    }
  }
}
