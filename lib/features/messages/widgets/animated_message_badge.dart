import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../services/message_service.dart';
import '../services/sound_service.dart';
import '../screens/messages_screen.dart';

class AnimatedMessageBadge extends StatefulWidget {
  const AnimatedMessageBadge({super.key});

  @override
  State<AnimatedMessageBadge> createState() => _AnimatedMessageBadgeState();
}

class _AnimatedMessageBadgeState extends State<AnimatedMessageBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  int _unreadCount = 0;
  int _previousUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.5),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _loadUnreadCount();
    MessageService.instance.addListener(_onUnreadCountChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    MessageService.instance.removeListener(_onUnreadCountChanged);
    super.dispose();
  }

  void _onUnreadCountChanged() {
    if (mounted) {
      setState(() {
        _previousUnreadCount = _unreadCount;
        _unreadCount = MessageService.instance.getUnreadCount();
        if (_unreadCount > _previousUnreadCount) {
          _controller.forward(from: 0);
          SoundService.instance.playMessageSound();
        }
      });
    }
  }

  void _loadUnreadCount() {
    setState(() {
      _unreadCount = MessageService.instance.getUnreadCount();
      _previousUnreadCount = _unreadCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.text,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MessagesScreen(),
              ),
            );
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8.w,
            top: 8.h,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.w,
                        minHeight: 16.w,
                      ),
                      child: Text(
                        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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
}
