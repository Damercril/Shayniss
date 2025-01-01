import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../services/message_service.dart';
import '../screens/messages_screen.dart';

class MessageBadge extends StatefulWidget {
  const MessageBadge({super.key});

  @override
  State<MessageBadge> createState() => _MessageBadgeState();
}

class _MessageBadgeState extends State<MessageBadge> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    MessageService.instance.addListener(_onUnreadCountChanged);
  }

  @override
  void dispose() {
    MessageService.instance.removeListener(_onUnreadCountChanged);
    super.dispose();
  }

  void _onUnreadCountChanged() {
    if (mounted) {
      setState(() {
        _unreadCount = MessageService.instance.getUnreadCount();
      });
    }
  }

  void _loadUnreadCount() {
    setState(() {
      _unreadCount = MessageService.instance.getUnreadCount();
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
      ],
    );
  }
}
