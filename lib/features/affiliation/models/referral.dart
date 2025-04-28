import 'package:shayniss/core/models/base_model.dart';

class Referral extends BaseModel {
  final String id;
  final String clientId;
  final String professionalId;
  final String? bookingId;
  final double amount;
  final double commissionRate;
  final double commissionAmount;
  final bool isPaid;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Referral({
    required this.id,
    required this.clientId,
    required this.professionalId,
    this.bookingId,
    required this.amount,
    required this.commissionRate,
    required this.commissionAmount,
    required this.isPaid,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      professionalId: json['professional_id'] as String,
      bookingId: json['booking_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      commissionRate: (json['commission_rate'] as num).toDouble(),
      commissionAmount: (json['commission_amount'] as num).toDouble(),
      isPaid: json['is_paid'] as bool,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'professional_id': professionalId,
      'booking_id': bookingId,
      'amount': amount,
      'commission_rate': commissionRate,
      'commission_amount': commissionAmount,
      'is_paid': isPaid,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Referral copyWith({
    String? id,
    String? clientId,
    String? professionalId,
    String? bookingId,
    double? amount,
    double? commissionRate,
    double? commissionAmount,
    bool? isPaid,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Referral(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      professionalId: professionalId ?? this.professionalId,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
