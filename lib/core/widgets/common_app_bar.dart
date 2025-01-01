import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../../features/messages/widgets/animated_message_badge.dart';
import '../../features/notifications/screens/notifications_screen.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? additionalActions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CommonAppBar({
    super.key,
    required this.title,
    this.additionalActions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.text,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
      actions: [
        ...(additionalActions ?? []),
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.text,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
        const AnimatedMessageBadge(),
        SizedBox(width: 8.w),
      ],
    );
  }
}
