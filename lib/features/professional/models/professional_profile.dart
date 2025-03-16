import 'package:json_annotation/json_annotation.dart';

part 'professional_profile.g.dart';

@JsonSerializable()
class ProfessionalProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? description;
  final String? profilePictureUrl;
  final String? coverPictureUrl;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final String? status;

  ProfessionalProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.description,
    this.profilePictureUrl,
    this.coverPictureUrl,
    this.categories = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.status,
  });

  factory ProfessionalProfile.fromJson(Map<String, dynamic> json) =>
      _$ProfessionalProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfessionalProfileToJson(this);

  ProfessionalProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? description,
    String? profilePictureUrl,
    String? coverPictureUrl,
    List<String>? categories,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    String? status,
  }) {
    return ProfessionalProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      description: description ?? this.description,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      coverPictureUrl: coverPictureUrl ?? this.coverPictureUrl,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
    );
  }
}

class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration; // en minutes
  final List<String> images;
  final List<String> categories;
  final bool isAvailable;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.images,
    required this.categories,
    required this.isAvailable,
  });
}

class Review {
  final String id;
  final String userId;
  final String professionalId;
  final double rating;
  final String textContent;
  final String? videoUrl;
  final String? audioUrl;
  final DateTime createdAt;
  final bool isVerifiedBooking;
  final Map<String, String> answers; // Réponses au questionnaire

  Review({
    required this.id,
    required this.userId,
    required this.professionalId,
    required this.rating,
    required this.textContent,
    this.videoUrl,
    this.audioUrl,
    required this.createdAt,
    required this.isVerifiedBooking,
    required this.answers,
  });
}

class BusinessHours {
  final Map<String, List<TimeSlot>> weeklySchedule;

  BusinessHours({required this.weeklySchedule});
}

class TimeSlot {
  final DateTime start;
  final DateTime end;

  TimeSlot({required this.start, required this.end});
}

class Location {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String postalCode;
  final String country;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
  });
}
