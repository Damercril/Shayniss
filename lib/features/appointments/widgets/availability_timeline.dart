import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../models/availability.dart';
import '../models/appointment.dart';

class AvailabilityTimeline extends StatelessWidget {
  final DateTime date;
  final List<Availability> availabilities;
  final List<Appointment> appointments;
  final double hourHeight;
  final Function(DateTime)? onTimeSlotTap;

  const AvailabilityTimeline({
    Key? key,
    required this.date,
    required this.availabilities,
    required this.appointments,
    this.hourHeight = 60.0,
    this.onTimeSlotTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            height: hourHeight * 24,
            child: Stack(
              children: [
                // Lignes des heures
                ...List.generate(24, (hour) {
                  return Positioned(
                    top: hour * hourHeight,
                    left: 0,
                    right: 0,
                    child: _buildHourLine(hour),
                  );
                }),

                // Disponibilités
                ...availabilities.map((availability) {
                  if (!availability.isAvailableAt(date)) return const SizedBox();
                  
                  final startHour = availability.startTime.hour + 
                                  availability.startTime.minute / 60;
                  final endHour = availability.endTime.hour + 
                                availability.endTime.minute / 60;
                  
                  return Positioned(
                    top: startHour * hourHeight,
                    left: 50,
                    right: 0,
                    height: (endHour - startHour) * hourHeight,
                    child: _buildAvailabilitySlot(availability),
                  );
                }),

                // Rendez-vous
                ...appointments.map((appointment) {
                  final startHour = appointment.dateTime.hour + 
                                  appointment.dateTime.minute / 60;
                  final duration = appointment.duration / 60;
                  
                  return Positioned(
                    top: startHour * hourHeight,
                    left: 50,
                    right: 0,
                    height: duration * hourHeight,
                    child: _buildAppointmentSlot(appointment),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHourLine(int hour) {
    return Container(
      height: 1,
      color: Colors.grey.withOpacity(0.2),
      margin: EdgeInsets.only(left: 40.w),
      child: Row(
        children: [
          Container(
            width: 40.w,
            padding: EdgeInsets.only(right: 8.w),
            child: Text(
              '$hour:00',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySlot(Availability availability) {
    return GestureDetector(
      onTap: () {
        if (onTimeSlotTap != null) {
          onTimeSlotTap!(availability.startTime);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: availability.notes != null && availability.notes!.isNotEmpty
            ? Padding(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  availability.notes!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildAppointmentSlot(Appointment appointment) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.2),
        border: Border.all(
          color: AppColors.secondary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.clientName,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (appointment.serviceName != null)
              Text(
                appointment.serviceName!,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.secondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
