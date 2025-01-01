import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class TimeSlotsGrid extends StatelessWidget {
  final DateTime selectedDate;
  final List<DateTime> availableSlots;
  final DateTime? selectedSlot;
  final Function(DateTime) onSlotSelected;

  const TimeSlotsGrid({
    Key? key,
    required this.selectedDate,
    required this.availableSlots,
    required this.onSlotSelected,
    this.selectedSlot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (availableSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48.w,
              color: Colors.grey,
            ),
            SizedBox(height: 8.h),
            Text(
              'Aucun créneau disponible',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: availableSlots.length,
      itemBuilder: (context, index) {
        final slot = availableSlots[index];
        final isSelected = selectedSlot != null &&
            slot.hour == selectedSlot!.hour &&
            slot.minute == selectedSlot!.minute;

        return InkWell(
          onTap: () => onSlotSelected(slot),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
