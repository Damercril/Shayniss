import 'package:flutter/material.dart';

enum PaymentMethod {
  cash,
  card,
  mobileMoney,
  transfer,
  paypal
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Espèces';
      case PaymentMethod.card:
        return 'Carte';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.transfer:
        return 'Virement';
      case PaymentMethod.paypal:
        return 'PayPal';
    }
  }
}

enum LocationType {
  salon,
  client
}

class BookingDetails {
  final String providerFirstName;
  final String providerLastName;
  final String serviceType;
  final String? servicePhotoUrl;
  final String? inspirationPhotoUrl;
  final int duration;
  final double price;
  final DateTime date;
  final TimeOfDay time;
  final bool isFlexibleTime;
  final LocationType locationType;
  final String? clientAddress;
  final String? salonAddress;
  final List<String> allergies;
  final List<String> preferences;
  final PaymentMethod paymentMethod;
  final bool acceptsPhotos;

  BookingDetails({
    required this.providerFirstName,
    required this.providerLastName,
    required this.serviceType,
    this.servicePhotoUrl,
    this.inspirationPhotoUrl,
    required this.duration,
    required this.price,
    required this.date,
    required this.time,
    required this.isFlexibleTime,
    required this.locationType,
    this.clientAddress,
    this.salonAddress,
    required this.allergies,
    required this.preferences,
    required this.paymentMethod,
    required this.acceptsPhotos,
  });

  double get finalPrice => acceptsPhotos ? price * 0.95 : price;

  Map<String, dynamic> toMap() {
    return {
      'providerFirstName': providerFirstName,
      'providerLastName': providerLastName,
      'serviceType': serviceType,
      'servicePhotoUrl': servicePhotoUrl,
      'inspirationPhotoUrl': inspirationPhotoUrl,
      'duration': duration,
      'price': price,
      'date': date.toIso8601String(),
      'time': {'hour': time.hour, 'minute': time.minute},
      'isFlexibleTime': isFlexibleTime,
      'locationType': locationType.toString(),
      'clientAddress': clientAddress,
      'salonAddress': salonAddress,
      'allergies': allergies,
      'preferences': preferences,
      'paymentMethod': paymentMethod.toString(),
      'acceptsPhotos': acceptsPhotos,
      'finalPrice': finalPrice,
    };
  }

  factory BookingDetails.fromMap(Map<String, dynamic> map) {
    return BookingDetails(
      providerFirstName: map['providerFirstName'],
      providerLastName: map['providerLastName'],
      serviceType: map['serviceType'],
      servicePhotoUrl: map['servicePhotoUrl'],
      inspirationPhotoUrl: map['inspirationPhotoUrl'],
      duration: map['duration'],
      price: map['price'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(hour: map['time']['hour'], minute: map['time']['minute']),
      isFlexibleTime: map['isFlexibleTime'],
      locationType: LocationType.values.firstWhere(
        (e) => e.toString() == map['locationType'],
      ),
      clientAddress: map['clientAddress'],
      salonAddress: map['salonAddress'],
      allergies: List<String>.from(map['allergies']),
      preferences: List<String>.from(map['preferences']),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == map['paymentMethod'],
      ),
      acceptsPhotos: map['acceptsPhotos'],
    );
  }
}
