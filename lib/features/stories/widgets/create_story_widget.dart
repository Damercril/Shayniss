import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../services/story_upload_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_overlay.dart';

class CreateStoryWidget extends StatefulWidget {
  final String professionalId;
  final VoidCallback? onStoryCreated;

  const CreateStoryWidget({
    super.key,
    required this.professionalId,
    this.onStoryCreated,
  });

  @override
  State<CreateStoryWidget> createState() => _CreateStoryWidgetState();
}

class _CreateStoryWidgetState extends State<CreateStoryWidget> {
  final StoryUploadService _uploadService = StoryUploadService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickAndUploadMedia(ImageSource source, bool isVideo) async {
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(
              source: source,
              maxDuration: const Duration(seconds: 30),
            )
          : await _picker.pickImage(
              source: source,
              imageQuality: 85,
              maxWidth: 1080,
              maxHeight: 1920,
            );

      if (file == null) return;

      setState(() => _isLoading = true);

      await _uploadService.uploadStory(
        professionalId: widget.professionalId,
        file: File(file.path),
        isVideo: isVideo,
      );

      widget.onStoryCreated?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du téléchargement de la story : $e',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(
                'Prendre une photo',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadMedia(ImageSource.camera, false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                'Choisir une photo',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadMedia(ImageSource.gallery, false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(
                'Enregistrer une vidéo',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadMedia(ImageSource.camera, true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: Text(
                'Choisir une vidéo',
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadMedia(ImageSource.gallery, true);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: GestureDetector(
            onTap: _showMediaPicker,
            child: Column(
              children: [
                Container(
                  width: 68.w,
                  height: 68.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.primary,
                      size: 32.sp,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Nouvelle story',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading) const LoadingOverlay(),
      ],
    );
  }
}
