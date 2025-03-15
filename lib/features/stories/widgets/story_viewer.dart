import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../models/story.dart';
import '../../../core/theme/app_colors.dart';
import '../../professional/models/professional_profile.dart';
import '../../professional/services/professional_service.dart';
import '../../appointments/widgets/booking_form_modal.dart';
import '../services/story_database_service.dart';

class StoryViewer extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewer({
    Key? key,
    required this.stories,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late int _currentIndex;
  final Duration _storyDuration = const Duration(seconds: 5);
  final ProfessionalService _professionalService = ProfessionalService();
  final StoryDatabaseService _storyService = StoryDatabaseService();
  Map<String, ProfessionalProfile?> _professionals = {};
  Map<String, VideoPlayerController?> _videoControllers = {};
  Set<String> _viewedStories = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });
    _loadProfessionals();
    _initializeCurrentVideo();
    _startStoryTimer();
    _markStoryViewed(widget.stories[_currentIndex].id);
  }

  Future<void> _loadProfessionals() async {
    for (var story in widget.stories) {
      if (!_professionals.containsKey(story.professionalId)) {
        final professional = await _professionalService.getProfessionalById(story.professionalId);
        if (mounted) {
          setState(() {
            _professionals[story.professionalId] = professional;
          });
        }
      }
    }
  }

  Future<void> _initializeCurrentVideo() async {
    final story = widget.stories[_currentIndex];
    if (story.isVideo) {
      await _initializeVideoController(story);
    }
  }

  Future<void> _initializeVideoController(Story story) async {
    if (_videoControllers[story.id] == null && story.isVideo) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(story.url));
      _videoControllers[story.id] = controller;
      await controller.initialize();
      if (mounted) {
        setState(() {});
        controller.play();
        _progressController.duration = controller.value.duration;
      }
    }
  }

  Future<void> _markStoryViewed(String storyId) async {
    if (!_viewedStories.contains(storyId)) {
      _viewedStories.add(storyId);
      await _storyService.markStorySeen(storyId);
      await _storyService.incrementViews(storyId);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    for (var controller in _videoControllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }

  void _startStoryTimer() {
    _progressController.forward(from: 0.0);
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.stories.length,
              onPageChanged: (index) async {
                final oldController = _videoControllers[widget.stories[_currentIndex].id];
                oldController?.pause();

                setState(() {
                  _currentIndex = index;
                });

                final newStory = widget.stories[index];
                if (newStory.isVideo) {
                  await _initializeVideoController(newStory);
                }
                _progressController.duration = newStory.isVideo
                    ? _videoControllers[newStory.id]!.value.duration
                    : _storyDuration;
                _progressController.forward(from: 0.0);
                _markStoryViewed(newStory.id);
              },
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                final professional = _professionals[story.professionalId];
                final videoController = _videoControllers[story.id];
                return Stack(
                  children: [
                    // Story content
                    Center(
                      child: story.isVideo && videoController != null
                          ? AspectRatio(
                              aspectRatio: videoController.value.aspectRatio,
                              child: VideoPlayer(videoController),
                            )
                          : Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: story.url,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 48.sp,
                                ),
                              ),
                            ),
                    ),
                    // Progress bar
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16.h,
                      left: 16.w,
                      right: 16.w,
                      child: Row(
                        children: widget.stories.asMap().entries.map((entry) {
                          return Expanded(
                            child: Container(
                              height: 3.h,
                              margin: EdgeInsets.symmetric(horizontal: 2.w),
                              child: AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  return LinearProgressIndicator(
                                    value: entry.key == _currentIndex
                                        ? _progressController.value
                                        : entry.key < _currentIndex
                                            ? 1.0
                                            : 0.0,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Professional info and booking button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 32.h,
                      left: 16.w,
                      right: 16.w,
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: professional?.profilePictureUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: professional!.profilePictureUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.person),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.person),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: Icon(Icons.person),
                                    ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  professional?.name ?? 'Chargement...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (professional?.city != null)
                                      Text(
                                        professional!.city!,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.remove_red_eye_outlined,
                                      color: Colors.white.withOpacity(0.8),
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${story.views}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (professional != null)
                            Container(
                              height: 36.h,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => BookingFormModal(
                                      professional: professional,
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.r),
                                  ),
                                ),
                                child: Text(
                                  'Réserver',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Close button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16.h,
                      right: 16.w,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
