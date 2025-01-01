import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class AppointmentDatePicker extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay) onTimeSelected;

  const AppointmentDatePicker({
    super.key,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  State<AppointmentDatePicker> createState() => _AppointmentDatePickerState();
}

class _AppointmentDatePickerState extends State<AppointmentDatePicker> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final List<String> quickTimes = [
    '09:00',
    '10:30',
    '14:00',
    '15:30',
    '17:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24.h),
          _buildDateSelector(),
          SizedBox(height: 24.h),
          _buildTimeSelector(),
          SizedBox(height: 24.h),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Choisir date et heure',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(14, (index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = date.day == selectedDate.day &&
                  date.month == selectedDate.month &&
                  date.year == selectedDate.year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                  widget.onDateSelected(date);
                },
                child: Container(
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : const Color(0xFFF5F1EA),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('E', 'fr_FR').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textLight,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    // Générer les créneaux horaires de 9h à 19h par intervalles de 30 minutes
    List<String> generateTimeSlots() {
      List<String> slots = [];
      for (int hour = 9; hour < 19; hour++) {
        slots.add('${hour.toString().padLeft(2, '0')}:00');
        slots.add('${hour.toString().padLeft(2, '0')}:30');
      }
      return slots;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heure',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 300.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1EA),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: GridView.builder(
            padding: EdgeInsets.all(12.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            itemCount: generateTimeSlots().length,
            itemBuilder: (context, index) {
              final time = generateTimeSlots()[index];
              final timeComponents = time.split(':');
              final compareTime = TimeOfDay(
                hour: int.parse(timeComponents[0]),
                minute: int.parse(timeComponents[1]),
              );
              final isSelected = selectedTime.hour == compareTime.hour &&
                  selectedTime.minute == compareTime.minute;

              // Vérifier si le créneau est dans le passé
              final now = TimeOfDay.now();
              final isPast = selectedDate.year == DateTime.now().year &&
                  selectedDate.month == DateTime.now().month &&
                  selectedDate.day == DateTime.now().day &&
                  (compareTime.hour < now.hour ||
                      (compareTime.hour == now.hour &&
                          compareTime.minute < now.minute));

              return GestureDetector(
                onTap: isPast
                    ? null
                    : () {
                        setState(() {
                          selectedTime = compareTime;
                        });
                        widget.onTimeSelected(compareTime);
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              const Color(0xFFF9F6F0),
                            ],
                          ),
                  ),
                  child: Center(
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isPast
                            ? AppColors.textLight.withOpacity(0.5)
                            : isSelected
                                ? Colors.white
                                : AppColors.text,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
        if (selectedTime != TimeOfDay.now())
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.primary,
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Rendez-vous à ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () {
        // Combine date and time
        final DateTime dateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        widget.onDateSelected(dateTime);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 48.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: const Text('Confirmer'),
    );
  }
}
