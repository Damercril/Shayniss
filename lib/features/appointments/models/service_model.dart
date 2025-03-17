import '../exceptions/service_validation_exception.dart';

class ServiceModel {
  final String id;
  final String professionalId;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? category;
  final bool isActive;
  final String? imageUrl;
  final int bookingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.professionalId,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.category,
    required this.isActive,
    this.imageUrl,
    this.bookingCount = 0,
    required this.createdAt,
    required this.updatedAt,
  }) {
    _validate();
  }

  void _validate() {
    if (name.isEmpty) {
      throw ServiceValidationException('Le nom du service ne peut pas être vide');
    }
    if (price < 0) {
      throw ServiceValidationException('Le prix doit être positif ou nul');
    }
    if (durationMinutes < 0) {
      throw ServiceValidationException('La durée doit être positive ou nulle');
    }
    if (bookingCount < 0) {
      throw ServiceValidationException('Le nombre de réservations doit être positif ou nul');
    }
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    try {
      final name = json['name'] as String? ?? '';
      final price = (json['price'] as num?)?.toDouble() ?? 0.0;
      final durationMinutes = (json['duration_minutes'] as num?)?.toInt() ?? 0;
      final bookingCount = (json['booking_count'] as num?)?.toInt() ?? 0;

      final service = ServiceModel(
        id: json['id'] as String? ?? '',
        professionalId: json['professional_id'] as String? ?? '',
        name: name,
        description: json['description'] as String?,
        price: price,
        durationMinutes: durationMinutes,
        category: json['category'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        imageUrl: json['image_url'] as String?,
        bookingCount: bookingCount,
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );

      return service;
    } catch (e) {
      if (e is ServiceValidationException) {
        rethrow;
      }
      throw ServiceValidationException('Erreur lors de la création du service: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professional_id': professionalId,
      'name': name,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'category': category,
      'is_active': isActive,
      'image_url': imageUrl,
      'booking_count': bookingCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toClientJson() {
    return {
      'id': id,
      'professionalId': professionalId,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'category': category,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'bookingCount': bookingCount,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? professionalId,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? category,
    bool? isActive,
    String? imageUrl,
    int? bookingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    try {
      final newName = name ?? this.name;
      final newPrice = price ?? this.price;
      final newDurationMinutes = durationMinutes ?? this.durationMinutes;
      final newBookingCount = bookingCount ?? this.bookingCount;

      if (newName.isEmpty) {
        throw ServiceValidationException('Le nom du service ne peut pas être vide');
      }
      if (newPrice < 0) {
        throw ServiceValidationException('Le prix doit être positif ou nul');
      }
      if (newDurationMinutes < 0) {
        throw ServiceValidationException('La durée doit être positive ou nulle');
      }
      if (newBookingCount < 0) {
        throw ServiceValidationException('Le nombre de réservations doit être positif ou nul');
      }

      return ServiceModel(
        id: id ?? this.id,
        professionalId: professionalId ?? this.professionalId,
        name: newName,
        description: description ?? this.description,
        price: newPrice,
        durationMinutes: newDurationMinutes,
        category: category ?? this.category,
        isActive: isActive ?? this.isActive,
        imageUrl: imageUrl ?? this.imageUrl,
        bookingCount: newBookingCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
    } catch (e) {
      if (e is ServiceValidationException) {
        rethrow;
      }
      throw ServiceValidationException('Erreur lors de la mise à jour du service: ${e.toString()}');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          professionalId == other.professionalId &&
          name == other.name &&
          description == other.description &&
          price == other.price &&
          durationMinutes == other.durationMinutes &&
          category == other.category &&
          isActive == other.isActive &&
          imageUrl == other.imageUrl &&
          bookingCount == other.bookingCount;

  @override
  int get hashCode => Object.hash(
        id,
        professionalId,
        name,
        description,
        price,
        durationMinutes,
        category,
        isActive,
        imageUrl,
        bookingCount,
      );
}
