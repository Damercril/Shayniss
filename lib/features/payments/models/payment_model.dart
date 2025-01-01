import 'package:flutter/material.dart';

class Payment {
  final String id;
  final String clientName;
  final String clientId;
  final double amount;
  final DateTime date;
  final String serviceName;
  final PaymentStatus status;
  final PaymentMethod method;

  Payment({
    required this.id,
    required this.clientName,
    required this.clientId,
    required this.amount,
    required this.date,
    required this.serviceName,
    required this.status,
    required this.method,
  });

  // Données de test
  static List<Payment> get samplePayments => [
        Payment(
          id: '1',
          clientName: 'Emma Laurent',
          clientId: 'client_1',
          amount: 75.0,
          date: DateTime.now().subtract(const Duration(days: 1)),
          serviceName: 'Coupe + Brushing',
          status: PaymentStatus.completed,
          method: PaymentMethod.card,
        ),
        Payment(
          id: '2',
          clientName: 'Sophie Martin',
          clientId: 'client_2',
          amount: 120.0,
          date: DateTime.now().subtract(const Duration(days: 2)),
          serviceName: 'Coloration complète',
          status: PaymentStatus.completed,
          method: PaymentMethod.cash,
        ),
        Payment(
          id: '3',
          clientName: 'Marie Dubois',
          clientId: 'client_3',
          amount: 45.0,
          date: DateTime.now().subtract(const Duration(days: 3)),
          serviceName: 'Manucure',
          status: PaymentStatus.pending,
          method: PaymentMethod.card,
        ),
        // Ajoutez plus de paiements de test ici...
      ];
}

enum PaymentStatus {
  completed,
  pending,
  failed,
  refunded;

  String get label {
    switch (this) {
      case PaymentStatus.completed:
        return 'Payé';
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.failed:
        return 'Échoué';
      case PaymentStatus.refunded:
        return 'Remboursé';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }
}

enum PaymentMethod {
  card,
  cash,
  transfer;

  String get label {
    switch (this) {
      case PaymentMethod.card:
        return 'Carte bancaire';
      case PaymentMethod.cash:
        return 'Espèces';
      case PaymentMethod.transfer:
        return 'Virement';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.cash:
        return Icons.payments;
      case PaymentMethod.transfer:
        return Icons.account_balance;
    }
  }
}

// Extension pour formater les dates
extension DateTimeExtension on DateTime {
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year}';
    }
  }
}
