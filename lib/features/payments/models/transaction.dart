import 'package:uuid/uuid.dart';

enum TransactionStatus {
  pending,
  completed,
  failed,
  refunded
}

enum PaymentMethod {
  card,
  cash,
  bankTransfer
}

class Transaction {
  final String id;
  final String clientId;
  final String clientName;
  final double amount;
  final DateTime date;
  final List<String> services;
  final TransactionStatus status;
  final PaymentMethod paymentMethod;
  final String? invoiceUrl;
  final String? stripePaymentId;

  Transaction({
    String? id,
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.date,
    required this.services,
    required this.status,
    required this.paymentMethod,
    this.invoiceUrl,
    this.stripePaymentId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'amount': amount,
      'date': date.toIso8601String(),
      'services': services.join(','),
      'status': status.toString(),
      'paymentMethod': paymentMethod.toString(),
      'invoiceUrl': invoiceUrl,
      'stripePaymentId': stripePaymentId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      clientId: map['clientId'],
      clientName: map['clientName'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      services: map['services'].split(','),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == map['paymentMethod'],
      ),
      invoiceUrl: map['invoiceUrl'],
      stripePaymentId: map['stripePaymentId'],
    );
  }
}
