import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import 'time_slots_grid.dart';

class TimeSlotSelectionDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Duration serviceDuration;

  const TimeSlotSelectionDialog({
    Key? key,
    required this.selectedDate,
    required this.serviceDuration,
  }) : super(key: key);

  @override
  State<TimeSlotSelectionDialog> createState() => _TimeSlotSelectionDialogState();
}

class _TimeSlotSelectionDialogState extends State<TimeSlotSelectionDialog> {
  DateTime? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 0.9.sw,
        height: 0.7.sh,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // En-tête
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choisir un horaire',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Pour le ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Grille des créneaux
            Expanded(
              child: FutureBuilder<List<DateTime>>(
                future: _getAvailableTimeSlots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return TimeSlotsGrid(
                    selectedDate: widget.selectedDate,
                    availableSlots: snapshot.data ?? [],
                    selectedSlot: _selectedSlot,
                    onSlotSelected: (slot) {
                      setState(() {
                        _selectedSlot = slot;
                      });
                    },
                  );
                },
              ),
            ),

            // Bouton de validation
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSlot != null
                    ? () => Navigator.pop(context, _selectedSlot)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Valider',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<DateTime>> _getAvailableTimeSlots() async {
    // TODO: Récupérer les vrais créneaux disponibles depuis le service
    await Future.delayed(const Duration(seconds: 1));

    final List<DateTime> slots = [];
    final startTime = TimeOfDay(hour: 9, minute: 0);
    final endTime = TimeOfDay(hour: 18, minute: 0);
    final interval = const Duration(minutes: 30);

    var currentTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      endTime.hour,
      endTime.minute,
    );

    while (currentTime.add(widget.serviceDuration).isBefore(endDateTime) ||
        currentTime.add(widget.serviceDuration).isAtSameMomentAs(endDateTime)) {
      // TODO: Vérifier si le créneau est vraiment disponible
      slots.add(currentTime);
      currentTime = currentTime.add(interval);
    }

    return slots;
  }
}
