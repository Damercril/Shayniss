import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/story.dart';
import '../services/story_database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_overlay.dart';

class StoryViewer extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;
  final VoidCallback? onClose;

  const StoryViewer({
    super.key,
    required this.stories,
    required this.initialIndex,
    this.onClose,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  final StoryDatabaseService _storyService = StoryDatabaseService();
  
  int _currentIndex = 0;
  bool _isLoading = false;
  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });

    _loadStory(widget.stories[_currentIndex]);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _videoController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadStory(Story story) async {
    setState(() => _isLoading = true);

    try {
      if (!story.seen) {
        await _storyService.markAsSeen(story.id);
      }

      if (story.isVideo) {
        _videoController?.dispose();
        _videoController = VideoPlayerController.network(story.url);
        await _videoController!.initialize();
        _videoController!.play();
        _videoController!.addListener(() {
          if (_videoController!.value.position >= _videoController!.value.duration) {
            _nextStory();
          }
        });
      } else {
        _progressController.forward(from: 0);
      }
    } catch (e) {
      print('Error loading story: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onClose?.call();
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

  void _onTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;

    if (dx < screenWidth / 3) {
      _previousStory();
    } else if (dx > 2 * screenWidth / 3) {
      _nextStory();
    } else {
      setState(() {
        _isPaused = true;
        _progressController.stop();
        _videoController?.pause();
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPaused = false;
      _progressController.forward();
      _videoController?.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _loadStory(widget.stories[index]);
              },
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (story.isVideo && _videoController != null)
                      VideoPlayer(_videoController!)
                    else
                      CachedNetworkImage(
                        imageUrl: story.url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.black,
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.h,
              left: 0,
              right: 0,
              child: Row(
                children: List.generate(
                  widget.stories.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: LinearProgressIndicator(
                        value: index == _currentIndex
                            ? _progressController.value
                            : index < _currentIndex
                                ? 1
                                : 0,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16.h,
              right: 16.w,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: widget.onClose,
              ),
            ),
            if (_isPaused)
              Center(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 48.sp,
                  ),
                ),
              ),
            if (_isLoading) const LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}
