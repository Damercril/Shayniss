import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BaseStorageService {
  final String _bucket;
  final SupabaseClient _client = Supabase.instance.client;
  static const _uuid = Uuid();

  BaseStorageService(this._bucket);

  Future<String> uploadFile(
    File file, {
    String? bucket,
    String? customPath,
  }) async {
    try {
      final fileExtension = path.extension(file.path);
      final fileName = customPath ?? '${_uuid.v4()}$fileExtension';
      final bytes = await file.readAsBytes();

      final String targetBucket = bucket ?? _bucket;
      
      await _client
          .storage
          .from(targetBucket)
          .uploadBinary(fileName, bytes);

      return _client
          .storage
          .from(targetBucket)
          .getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(
    String fileUrl, {
    String? bucket,
  }) async {
    try {
      final uri = Uri.parse(fileUrl);
      final fileName = path.basename(uri.path);
      final String targetBucket = bucket ?? _bucket;

      await _client
          .storage
          .from(targetBucket)
          .remove([fileName]);
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }
}
