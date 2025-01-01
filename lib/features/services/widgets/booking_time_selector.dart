import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';

class BookingTimeSelector extends StatefulWidget {
  final Function(DateTime date, DateTime time) onDateTimeSelected;

  const BookingTimeSelector({
    Key? key,
    required this.onDateTimeSelected,
  }) : super(key: key);

  @override
  State<BookingTimeSelector> createState() => _BookingTimeSelectorState();
}

class _BookingTimeSelectorState extends State<BookingTimeSelector> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _selectedTime;
  bool _isLoadingSlots = false;
  List<DateTime> _availableSlots = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendrier
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mois',
            },
            enabledDayPredicate: (day) {
              // Désactiver les jours passés et le dimanche
              return day.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
                  day.weekday != DateTime.sunday;
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedTime = null;
                _loadAvailableSlots(selectedDay);
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              disabledTextStyle: TextStyle(
                color: Colors.grey[300],
                decoration: TextDecoration.lineThrough,
              ),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Créneaux horaires
        if (_selectedDay != null) ...[
          if (_isLoadingSlots)
            const Center(child: CircularProgressIndicator())
          else if (_availableSlots.isEmpty)
            Center(
              child: Text(
                'Aucun créneau disponible pour cette date',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _availableSlots.map((slot) {
                final isSelected = _selectedTime != null &&
                    _selectedTime!.hour == slot.hour &&
                    _selectedTime!.minute == slot.minute;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTime = slot;
                    });
                    widget.onDateTimeSelected(_selectedDay!, slot);
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
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
                    child: Text(
                      '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ],
    );
  }

  Future<void> _loadAvailableSlots(DateTime date) async {
    setState(() {
      _isLoadingSlots = true;
    });

    try {
      // TODO: Charger les créneaux disponibles depuis Firebase
      await Future.delayed(const Duration(seconds: 1));

      // Exemple de créneaux
      final slots = <DateTime>[];
      final startHour = 9;
      final endHour = 18;
      final interval = const Duration(minutes: 30);

      for (var hour = startHour; hour < endHour; hour++) {
        for (var minute = 0; minute < 60; minute += interval.inMinutes) {
          slots.add(
            DateTime(
              date.year,
              date.month,
              date.day,
              hour,
              minute,
            ),
          );
        }
      }

      setState(() {
        _availableSlots = slots;
      });
    } finally {
      setState(() {
        _isLoadingSlots = false;
      });
    }
  }
}
