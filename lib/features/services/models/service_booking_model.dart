import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceBooking {
  final String id;
  final String serviceName;
  final double price;
  final Duration duration;
  final String providerId;
  final bool homeService; // Service à domicile disponible
  final String? description;
  final List<String> photos;
  final String shareableLink; // Lien à partager

  ServiceBooking({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.duration,
    required this.providerId,
    this.homeService = false,
    this.description,
    this.photos = const [],
    required this.shareableLink,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceName': serviceName,
      'price': price,
      'duration': duration.inMinutes,
      'providerId': providerId,
      'homeService': homeService,
      'description': description,
      'photos': photos,
      'shareableLink': shareableLink,
    };
  }

  factory ServiceBooking.fromMap(Map<String, dynamic> map) {
    return ServiceBooking(
      id: map['id'] ?? '',
      serviceName: map['serviceName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      duration: Duration(minutes: map['duration'] ?? 60),
      providerId: map['providerId'] ?? '',
      homeService: map['homeService'] ?? false,
      description: map['description'],
      photos: List<String>.from(map['photos'] ?? []),
      shareableLink: map['shareableLink'] ?? '',
    );
  }
}

class BookingRequest {
  final String id;
  final String serviceId;
  final String clientName;
  final String clientPhone;
  final DateTime appointmentDateTime;
  final bool homeService;
  final String paymentMethod; // 'cash', 'card', 'online'
  final bool photoConsent;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;

  BookingRequest({
    required this.id,
    required this.serviceId,
    required this.clientName,
    required this.clientPhone,
    required this.appointmentDateTime,
    required this.homeService,
    required this.paymentMethod,
    required this.photoConsent,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': serviceId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'appointmentDateTime': Timestamp.fromDate(appointmentDateTime),
      'homeService': homeService,
      'paymentMethod': paymentMethod,
      'photoConsent': photoConsent,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BookingRequest.fromMap(Map<String, dynamic> map) {
    return BookingRequest(
      id: map['id'] ?? '',
      serviceId: map['serviceId'] ?? '',
      clientName: map['clientName'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      appointmentDateTime: (map['appointmentDateTime'] as Timestamp).toDate(),
      homeService: map['homeService'] ?? false,
      paymentMethod: map['paymentMethod'] ?? 'cash',
      photoConsent: map['photoConsent'] ?? false,
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
