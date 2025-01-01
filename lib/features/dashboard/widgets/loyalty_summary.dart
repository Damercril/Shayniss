import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../loyalty/models/loyalty_program.dart';

class LoyaltySummary extends StatelessWidget {
  const LoyaltySummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Programme fidélité',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {
                  // TODO: Ouvrir les paramètres de fidélité
                },
                color: Colors.grey,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildLevelStat(
                '🥉',
                'Bronze',
                '12',
                'clients',
              ),
              _buildLevelStat(
                '🥈',
                'Argent',
                '8',
                'clients',
              ),
              _buildLevelStat(
                '🥇',
                'Or',
                '5',
                'clients',
              ),
              _buildLevelStat(
                '💎',
                'Platine',
                '2',
                'clients',
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star_outline,
                  color: AppColors.primary,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '3 clients peuvent passer au niveau supérieur',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 16.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelStat(
    String icon,
    String level,
    String count,
    String label,
  ) {
    Color backgroundColor;
    Color borderColor;
    
    switch (level.toLowerCase()) {
      case 'bronze':
        backgroundColor = const Color(0xFFCD7F32).withOpacity(0.1);
        borderColor = const Color(0xFFCD7F32);
        break;
      case 'argent':
        backgroundColor = const Color(0xFFC0C0C0).withOpacity(0.1);
        borderColor = const Color(0xFFC0C0C0);
        break;
      case 'or':
        backgroundColor = const Color(0xFFFFD700).withOpacity(0.1);
        borderColor = const Color(0xFFFFD700);
        break;
      case 'platine':
        backgroundColor = const Color(0xFFE5E4E2).withOpacity(0.1);
        borderColor = const Color(0xFFE5E4E2);
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        borderColor = Colors.grey;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 20.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            count,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          Text(
            level,
            style: TextStyle(
              fontSize: 12.sp,
              color: borderColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
