import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../models/availability.dart';
import '../models/appointment.dart';

class WeekViewCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final List<Availability> availabilities;
  final List<Appointment> appointments;
  final Function(DateTime)? onTimeSlotTap;
  final double hourHeight;
  final double dayWidth;

  const WeekViewCalendar({
    Key? key,
    required this.selectedDate,
    required this.availabilities,
    required this.appointments,
    this.onTimeSlotTap,
    this.hourHeight = 60.0,
    this.dayWidth = 100.0,
  }) : super(key: key);

  @override
  State<WeekViewCalendar> createState() => _WeekViewCalendarState();
}

class _WeekViewCalendarState extends State<WeekViewCalendar> {
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController;
  late DateTime _startOfWeek;
  final double _timeColumnWidth = 60.0;

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _horizontalScrollController = ScrollController();
    _startOfWeek = _getStartOfWeek(widget.selectedDate);
    
    // Scroll to 8 AM by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verticalScrollController.jumpTo(8 * widget.hourHeight);
    });
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  List<Widget> _buildTimeColumn() {
    return List.generate(24, (hour) {
      return SizedBox(
        height: widget.hourHeight,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            '$hour:00',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDayHeader(DateTime date) {
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    final isSelected = date.year == widget.selectedDate.year &&
        date.month == widget.selectedDate.month &&
        date.day == widget.selectedDate.day;

    return Container(
      width: widget.dayWidth,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
          right: BorderSide(color: Colors.grey[300]!),
        ),
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      ),
      child: Column(
        children: [
          Text(
            ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'][date.weekday - 1],
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isToday ? AppColors.primary : null,
            ),
          ),
          Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: isToday ? FontWeight.bold : null,
              color: isToday ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(DateTime date, int hour) {
    final timeSlotStart = DateTime(date.year, date.month, date.day, hour);
    final timeSlotEnd = timeSlotStart.add(const Duration(hours: 1));

    // Trouver les disponibilités pour ce créneau
    final slotAvailabilities = widget.availabilities.where((a) => 
      a.isAvailableAt(timeSlotStart));

    // Trouver les rendez-vous pour ce créneau
    final slotAppointments = widget.appointments.where((a) {
      final appointmentEnd = a.dateTime.add(Duration(minutes: a.duration));
      return a.dateTime.isBefore(timeSlotEnd) && 
             appointmentEnd.isAfter(timeSlotStart) &&
             a.dateTime.day == date.day;
    });

    return GestureDetector(
      onTap: () {
        if (widget.onTimeSlotTap != null) {
          widget.onTimeSlotTap!(timeSlotStart);
        }
      },
      child: Container(
        width: widget.dayWidth,
        height: widget.hourHeight,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
            right: BorderSide(color: Colors.grey[300]!),
          ),
          color: slotAvailabilities.isNotEmpty 
              ? AppColors.primary.withOpacity(0.1)
              : null,
        ),
        child: Stack(
          children: [
            ...slotAppointments.map((appointment) {
              final topOffset = (appointment.dateTime.minute / 60) * widget.hourHeight;
              final height = (appointment.duration / 60) * widget.hourHeight;
              
              return Positioned(
                top: topOffset,
                left: 2,
                right: 2,
                height: height,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    border: Border.all(color: AppColors.secondary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.clientName,
                        style: TextStyle(
                          fontSize: 10.sp,
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
                            fontSize: 8.sp,
                            color: AppColors.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-têtes des jours
        Row(
          children: [
            SizedBox(width: _timeColumnWidth),
            Expanded(
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (index) {
                    final date = _startOfWeek.add(Duration(days: index));
                    return _buildDayHeader(date);
                  }),
                ),
              ),
            ),
          ],
        ),
        // Grille des créneaux horaires
        Expanded(
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne des heures
                SizedBox(
                  width: _timeColumnWidth,
                  child: Column(
                    children: _buildTimeColumn(),
                  ),
                ),
                // Grille des créneaux
                Expanded(
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(7, (dayIndex) {
                        final date = _startOfWeek.add(Duration(days: dayIndex));
                        return Column(
                          children: List.generate(24, (hour) {
                            return _buildTimeSlot(date, hour);
                          }),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
