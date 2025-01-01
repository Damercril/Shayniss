import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class ClientDetailsModal extends StatelessWidget {
  final String clientName;
  final String appointmentTime;
  final String service;
  final bool hasConfirmed;
  final bool hasDeposit;
  final bool hasPaid;

  const ClientDetailsModal({
    super.key,
    required this.clientName,
    required this.appointmentTime,
    required this.service,
    required this.hasConfirmed,
    required this.hasDeposit,
    required this.hasPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 24.h),
          _buildClientInfo(),
          SizedBox(height: 16.h),
          _buildStatusSection(),
          SizedBox(height: 24.h),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Détails du rendez-vous',
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

  Widget _buildClientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                clientName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$service - $appointmentTime',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        _buildStatusItem(
          'Confirmation',
          hasConfirmed,
          hasConfirmed ? 'Confirmé' : 'En attente',
          hasConfirmed ? Icons.check_circle : Icons.schedule,
          hasConfirmed ? AppColors.success : AppColors.warning,
        ),
        SizedBox(height: 8.h),
        _buildStatusItem(
          'Acompte',
          hasDeposit,
          hasDeposit ? 'Payé' : 'Non payé',
          hasDeposit ? Icons.payments : Icons.money_off,
          hasDeposit ? AppColors.success : AppColors.error,
        ),
        SizedBox(height: 8.h),
        _buildStatusItem(
          'Paiement',
          hasPaid,
          hasPaid ? 'Payé' : 'Non payé',
          hasPaid ? Icons.paid : Icons.payment,
          hasPaid ? AppColors.success : AppColors.error,
        ),
      ],
    );
  }

  Widget _buildStatusItem(
    String label,
    bool status,
    String statusText,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.text,
                ),
              ),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        if (!hasConfirmed)
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implémenter l'envoi de notification
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification de confirmation envoyée'),
                ),
              );
            },
            icon: const Icon(Icons.notification_add),
            label: const Text('Envoyer une notification de confirmation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        if (!hasConfirmed) SizedBox(height: 12.h),
        if (!hasPaid && !hasDeposit)
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implémenter la demande d'acompte
            },
            icon: const Icon(Icons.payment),
            label: const Text('Demander un acompte'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 48.h),
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
      ],
    );
  }
}
