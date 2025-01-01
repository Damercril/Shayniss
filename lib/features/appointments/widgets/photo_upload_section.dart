import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';

class PhotoUploadSection extends StatefulWidget {
  final Function(List<File>) onPhotosSelected;
  final List<File> initialPhotos;

  const PhotoUploadSection({
    super.key,
    required this.onPhotosSelected,
    this.initialPhotos = const [],
  });

  @override
  State<PhotoUploadSection> createState() => _PhotoUploadSectionState();
}

class _PhotoUploadSectionState extends State<PhotoUploadSection> {
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _photos.addAll(widget.initialPhotos);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _photos.add(File(image.path));
          widget.onPhotosSelected(_photos);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      widget.onPhotosSelected(_photos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1EA),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(8.w),
            children: [
              // Bouton d'ajout de photo
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_camera),
                            title: const Text('Prendre une photo'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Choisir depuis la galerie'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 100.w,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.primary,
                        size: 32.w,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Ajouter',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Liste des photos
              ..._photos.asMap().entries.map((entry) {
                final index = entry.key;
                final photo = entry.value;
                return Container(
                  width: 100.w,
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    image: DecorationImage(
                      image: FileImage(photo),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: InkWell(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
