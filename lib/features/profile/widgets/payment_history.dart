import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../payments/models/transaction.dart';
import 'package:intl/intl.dart';

class PaymentHistory extends StatelessWidget {
  const PaymentHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historique des paiements',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Afficher tous les paiements
                },
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5, // Afficher les 5 derniers paiements
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          itemBuilder: (context, index) {
            // Données de test
            final transactions = [
              {
                'date': DateTime.now().subtract(const Duration(days: 1)),
                'amount': 65.0,
                'clientName': 'Emma Laurent',
                'services': ['Coupe + Brushing'],
                'status': TransactionStatus.completed,
                'method': PaymentMethod.card,
              },
              {
                'date': DateTime.now().subtract(const Duration(days: 2)),
                'amount': 120.0,
                'clientName': 'Sophie Martin',
                'services': ['Coloration', 'Coupe'],
                'status': TransactionStatus.completed,
                'method': PaymentMethod.cash,
              },
              {
                'date': DateTime.now().subtract(const Duration(days: 3)),
                'amount': 45.0,
                'clientName': 'Marie Dubois',
                'services': ['Brushing'],
                'status': TransactionStatus.completed,
                'method': PaymentMethod.bankTransfer,
              },
              {
                'date': DateTime.now().subtract(const Duration(days: 4)),
                'amount': 85.0,
                'clientName': 'Julie Bernard',
                'services': ['Mèches', 'Coupe'],
                'status': TransactionStatus.pending,
                'method': PaymentMethod.bankTransfer,
              },
              {
                'date': DateTime.now().subtract(const Duration(days: 5)),
                'amount': 55.0,
                'clientName': 'Léa Petit',
                'services': ['Coupe'],
                'status': TransactionStatus.completed,
                'method': PaymentMethod.card,
              },
            ];

            final transaction = transactions[index];
            final status = transaction['status'] as TransactionStatus;
            final method = transaction['method'] as PaymentMethod;

            return ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              leading: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: _getMethodColor(method).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getMethodIcon(method),
                  color: _getMethodColor(method),
                  size: 20.w,
                ),
              ),
              title: Text(
                '€${(transaction['amount'] as double).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['clientName'] as String,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    (transaction['services'] as List).join(', '),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd MMM').format(transaction['date'] as DateTime),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return Colors.blue;
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.bankTransfer:
        return Colors.purple;
    }
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.cash:
        return Icons.payments_outlined;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.refunded:
        return Colors.grey;
    }
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return 'Payé';
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.failed:
        return 'Échoué';
      case TransactionStatus.refunded:
        return 'Remboursé';
    }
  }
}
