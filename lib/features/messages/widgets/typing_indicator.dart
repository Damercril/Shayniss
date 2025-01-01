import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class TypingIndicator extends StatefulWidget {
  final bool isTyping;

  const TypingIndicator({
    super.key,
    required this.isTyping,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _dotAnimations = List.generate(3, (index) {
      final begin = index * 0.2;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            begin,
            begin + 0.4,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTyping) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'En train d\'écrire',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(width: 4.w),
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _dotAnimations[index],
              builder: (context, child) {
                return Container(
                  width: 4.w,
                  height: 4.w,
                  margin: EdgeInsets.only(right: index < 2 ? 2.w : 0),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(
                      0.3 + (_dotAnimations[index].value * 0.7),
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
