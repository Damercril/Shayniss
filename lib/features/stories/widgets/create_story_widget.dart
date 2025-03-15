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
    Key? key,
    required this.professionalId,
    this.onStoryCreated,
  }) : super(key: key);

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
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);

      if (file == null) return;

      setState(() {
        _isLoading = true;
      });

      await _uploadService.uploadStory(
        professionalId: widget.professionalId,
        file: File(file.path),
        isVideo: isVideo,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Story publiée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onStoryCreated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la publication : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadMedia(ImageSource.camera, false);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choisir une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadMedia(ImageSource.gallery, false);
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Enregistrer une vidéo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadMedia(ImageSource.camera, true);
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('Choisir une vidéo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadMedia(ImageSource.gallery, true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 85.w,
          margin: EdgeInsets.only(right: 16.w),
          child: Column(
            children: [
              GestureDetector(
                onTap: _showMediaPicker,
                child: Container(
                  width: 85.w,
                  height: 85.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32.sp,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Nouvelle story',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: LoadingOverlay(),
          ),
      ],
    );
  }
}
