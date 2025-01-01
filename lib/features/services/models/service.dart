import 'package:uuid/uuid.dart';

class Service {
  final String id;
  final String name;
  final String category;
  final double price;
  final int duration; // in minutes
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> photoUrls; // URLs des photos du service
  final String? mainPhotoUrl; // Photo principale du service

  Service({
    String? id,
    required this.name,
    required this.category,
    required this.price,
    required this.duration,
    this.description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? photoUrls,
    this.mainPhotoUrl,
  })  : id = id ?? const Uuid().v4(),
        isActive = isActive ?? true,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        photoUrls = photoUrls ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'duration': duration,
      'description': description,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'photoUrls': photoUrls,
      'mainPhotoUrl': mainPhotoUrl,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'].toDouble(),
      duration: map['duration'],
      description: map['description'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      mainPhotoUrl: map['mainPhotoUrl'],
    );
  }

  Service copyWith({
    String? name,
    String? category,
    double? price,
    int? duration,
    String? description,
    bool? isActive,
    List<String>? photoUrls,
    String? mainPhotoUrl,
  }) {
    return Service(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      photoUrls: photoUrls ?? this.photoUrls,
      mainPhotoUrl: mainPhotoUrl ?? this.mainPhotoUrl,
    );
  }
}
