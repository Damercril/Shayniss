import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import 'image_viewer.dart';

class ServiceImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final String? title;

  const ServiceImage({
    super.key,
    required this.imageUrl,
    this.width = 80,
    this.height = 80,
    this.borderRadius = 8,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewer(
              imageUrl: imageUrl,
              title: title ?? 'Image',
            ),
          ),
        );
      },
      child: Hero(
        tag: imageUrl,
        child: Container(
          width: width.w,
          height: height.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius.r),
            color: const Color(0xFFF5F1EA),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius.r),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildLoadingIndicator(),
              errorWidget: (context, url, error) => _buildPlaceholder(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF5F1EA),
      child: Icon(
        Icons.image_outlined,
        color: AppColors.primary,
        size: 32.w,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: const Color(0xFFF5F1EA),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
