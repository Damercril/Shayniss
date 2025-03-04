import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../services/appointment_details_service.dart';

class AppointmentStatusDialog extends StatelessWidget {
  final String appointmentId;
  final String currentStatus;

  const AppointmentStatusDialog({
    Key? key,
    required this.appointmentId,
    required this.currentStatus,
  }) : super(key: key);

  Future<void> _updateStatus(BuildContext context, String status) async {
    try {
      await AppointmentDetailsService.instance.updateAppointmentStatus(
        appointmentId,
        status,
      );
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Modifier le statut',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _StatusButton(
              title: 'Confirmer',
              color: Colors.green,
              isSelected: currentStatus == 'confirmed',
              onTap: () => _updateStatus(context, 'confirmed'),
            ),
            SizedBox(height: 8.h),
            _StatusButton(
              title: 'En attente',
              color: Colors.orange,
              isSelected: currentStatus == 'pending',
              onTap: () => _updateStatus(context, 'pending'),
            ),
            SizedBox(height: 8.h),
            _StatusButton(
              title: 'Annuler',
              color: Colors.red,
              isSelected: currentStatus == 'cancelled',
              onTap: () => _updateStatus(context, 'cancelled'),
            ),
            SizedBox(height: 8.h),
            _StatusButton(
              title: 'Terminé',
              color: Colors.blue,
              isSelected: currentStatus == 'completed',
              onTap: () => _updateStatus(context, 'completed'),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String title;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.title,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
