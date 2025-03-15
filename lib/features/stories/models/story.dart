import 'package:json_annotation/json_annotation.dart';

part 'story.g.dart';

@JsonSerializable()
class Story {
  final String id;
  @JsonKey(name: 'professional_id')
  final String professionalId;
  final String url;
  final String type;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;
  final bool seen;
  final int views;

  Story({
    required this.id,
    required this.professionalId,
    required this.url,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    this.seen = false,
    this.views = 0,
  });

  bool get isVideo => type == 'video';
  bool get isImage => type == 'image';
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
  Map<String, dynamic> toJson() => _$StoryToJson(this);
}
