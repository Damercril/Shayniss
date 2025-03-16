import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/story.dart';
import '../services/story_database_service.dart';
import 'story_viewer.dart';
import 'create_story_widget.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/theme/app_colors.dart';

class StoryList extends StatefulWidget {
  final String professionalId;
  final bool canCreate;

  const StoryList({
    super.key,
    required this.professionalId,
    this.canCreate = false,
  });

  @override
  State<StoryList> createState() => _StoryListState();
}

class _StoryListState extends State<StoryList> {
  final StoryDatabaseService _storyService = StoryDatabaseService();
  List<Story>? _stories;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    try {
      final stories = await _storyService.getStoriesByProfessionalId(widget.professionalId);
      if (mounted) {
        setState(() {
          _stories = stories;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stories: $e');
      if (mounted) {
        setState(() {
          _stories = [];
          _isLoading = false;
        });
      }
    }
  }

  void _openStoryViewer(int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: StoryViewer(
            stories: _stories!,
            initialIndex: index,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingOverlay();
    }

    if (_stories == null || _stories!.isEmpty && !widget.canCreate) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: widget.canCreate ? (_stories?.length ?? 0) + 1 : _stories?.length ?? 0,
        itemBuilder: (context, index) {
          if (widget.canCreate && index == 0) {
            return CreateStoryWidget(
              professionalId: widget.professionalId,
              onStoryCreated: _loadStories,
            );
          }

          final storyIndex = widget.canCreate ? index - 1 : index;
          final story = _stories![storyIndex];
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () => _openStoryViewer(storyIndex),
              child: Column(
                children: [
                  Container(
                    width: 68.w,
                    height: 68.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: !story.seen
                          ? LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      border: story.seen
                          ? Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 2,
                            )
                          : null,
                    ),
                    padding: EdgeInsets.all(2.w),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(2.w),
                      child: ClipOval(
                        child: story.type == 'video' && story.thumbnailUrl != null
                            ? Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: story.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: 12.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : CachedNetworkImage(
                                imageUrl: story.url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    story.timeAgo,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
