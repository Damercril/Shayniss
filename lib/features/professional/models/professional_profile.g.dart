// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professional_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfessionalProfile _$ProfessionalProfileFromJson(Map<String, dynamic> json) =>
    ProfessionalProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      description: json['description'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      coverPictureUrl: json['coverPictureUrl'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$ProfessionalProfileToJson(
        ProfessionalProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'description': instance.description,
      'profilePictureUrl': instance.profilePictureUrl,
      'coverPictureUrl': instance.coverPictureUrl,
      'categories': instance.categories,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isAvailable': instance.isAvailable,
      'status': instance.status,
    };
