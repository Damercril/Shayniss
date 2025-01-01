import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';

class ServicePhotosGallery extends StatefulWidget {
  final List<String> photoUrls;
  final String? mainPhotoUrl;
  final Function(String)? onMainPhotoSelected;
  final bool isEditable;

  const ServicePhotosGallery({
    Key? key,
    required this.photoUrls,
    this.mainPhotoUrl,
    this.onMainPhotoSelected,
    this.isEditable = false,
  }) : super(key: key);

  @override
  State<ServicePhotosGallery> createState() => _ServicePhotosGalleryState();
}

class _ServicePhotosGalleryState extends State<ServicePhotosGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photoUrls.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Affichage principal
        Container(
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Galerie de photos
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: widget.photoUrls.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showFullScreenImage(context, index),
                      child: CachedNetworkImage(
                        imageUrl: widget.photoUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surface,
                          child: Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 32.w,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Indicateurs de navigation
              if (widget.photoUrls.length > 1)
                Positioned(
                  bottom: 8.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.photoUrls.length,
                      (index) => Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              // Boutons de navigation
              if (widget.photoUrls.length > 1) ...[
                Positioned(
                  left: 8.w,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 32.w,
                      ),
                      onPressed: _currentIndex > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  right: 8.w,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 32.w,
                      ),
                      onPressed: _currentIndex < widget.photoUrls.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                    ),
                  ),
                ),
              ],
              // Bouton pour définir comme photo principale
              if (widget.isEditable)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: IconButton(
                    icon: Icon(
                      widget.photoUrls[_currentIndex] == widget.mainPhotoUrl
                          ? Icons.star
                          : Icons.star_border,
                      color: widget.photoUrls[_currentIndex] == widget.mainPhotoUrl
                          ? AppColors.primary
                          : Colors.white,
                    ),
                    onPressed: () {
                      widget.onMainPhotoSelected?.call(widget.photoUrls[_currentIndex]);
                    },
                  ),
                ),
            ],
          ),
        ),
        // Miniatures
        if (widget.photoUrls.length > 1)
          Container(
            height: 60.h,
            margin: EdgeInsets.only(top: 8.h),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.photoUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 60.w,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: _currentIndex == index
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: CachedNetworkImage(
                        imageUrl: widget.photoUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.textLight.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48.w,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8.h),
            Text(
              'Aucune photo',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: widget.photoUrls.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.photoUrls[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
