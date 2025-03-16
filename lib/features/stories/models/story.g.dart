// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Story _$StoryFromJson(Map<String, dynamic> json) => Story(
      id: json['id'] as String,
      professionalId: json['professional_id'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      seen: json['seen'] as bool? ?? false,
      views: (json['views'] as num?)?.toInt() ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );

Map<String, dynamic> _$StoryToJson(Story instance) => <String, dynamic>{
      'id': instance.id,
      'professional_id': instance.professionalId,
      'url': instance.url,
      'type': instance.type,
      'created_at': instance.createdAt.toIso8601String(),
      'expires_at': instance.expiresAt.toIso8601String(),
      'seen': instance.seen,
      'views': instance.views,
      'thumbnail_url': instance.thumbnailUrl,
    };
