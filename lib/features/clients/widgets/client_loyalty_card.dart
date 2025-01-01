import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../loyalty/screens/loyalty_screen.dart';
import '../../loyalty/models/loyalty_program.dart';

class ClientLoyaltyCard extends StatelessWidget {
  final String clientId;
  final String clientName;

  const ClientLoyaltyCard({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Récupérer les vrais points de fidélité
    final loyaltyPoints = LoyaltyPoints(
      clientId: clientId,
      points: 250,
      currentLevel: silverLevel,
      pointsToNextLevel: goldLevel.requiredPoints - 250,
      lastUpdated: DateTime.now(),
    );

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoyaltyScreen(
                clientId: clientId,
                clientName: clientName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    loyaltyPoints.currentLevel.icon ?? '',
                    style: TextStyle(
                      fontSize: 24.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau ${loyaltyPoints.currentLevel.name}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${loyaltyPoints.points} points',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: loyaltyPoints.points /
                            loyaltyPoints.currentLevel.requiredPoints,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 4.h,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
