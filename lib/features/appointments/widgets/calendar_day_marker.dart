import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/availability.dart';

class CalendarDayMarker extends StatelessWidget {
  final List<Availability> availabilities;
  final DateTime date;

  const CalendarDayMarker({
    Key? key,
    required this.availabilities,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasAvailabilities = availabilities.any((a) => a.isAvailableAt(date));
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: hasAvailabilities ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          if (hasAvailabilities)
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
