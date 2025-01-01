import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PermissionHandler {
  static Future<bool> requestCameraPermission(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final result = await picker.pickImage(source: ImageSource.camera);
      if (result == null) return false;
      return true;
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission requise'),
          content: const Text(
            'Pour prendre des photos, l\'application a besoin d\'accéder à votre appareil photo. '
            'Veuillez autoriser l\'accès dans les paramètres de votre appareil.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
  }

  static Future<bool> requestGalleryPermission(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final result = await picker.pickImage(source: ImageSource.gallery);
      if (result == null) return false;
      return true;
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission requise'),
          content: const Text(
            'Pour accéder à vos photos, l\'application a besoin d\'accéder à votre galerie. '
            'Veuillez autoriser l\'accès dans les paramètres de votre appareil.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
  }
}
