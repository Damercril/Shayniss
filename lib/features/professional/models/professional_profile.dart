class ProfessionalProfile {
  final String id;
  final String username; // Identifiant unique @
  final String fullName;
  final String email;
  final String phoneNumber;
  final String profilePicture;
  final String bio;
  final List<Service> services;
  final List<Review> reviews;
  final double rating;
  final BusinessHours businessHours;
  final Location location;
  final List<String> certificates;
  final List<String> portfolioImages;
  final bool isVerified;
  final Map<String, dynamic> statistics; // Pour les analyses et statistiques

  ProfessionalProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    required this.bio,
    required this.services,
    required this.reviews,
    required this.rating,
    required this.businessHours,
    required this.location,
    required this.certificates,
    required this.portfolioImages,
    required this.isVerified,
    required this.statistics,
  });

  factory ProfessionalProfile.fromJson(Map<String, dynamic> json) {
    // Implémentation de la conversion JSON
    return ProfessionalProfile(
      // ... conversion des champs
    );
  }

  Map<String, dynamic> toJson() {
    // Implémentation de la conversion vers JSON
    return {
      // ... conversion des champs
    };
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
