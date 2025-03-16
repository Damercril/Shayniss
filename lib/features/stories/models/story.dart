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
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  Story({
    required this.id,
    required this.professionalId,
    required this.url,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    this.seen = false,
    this.views = 0,
    this.thumbnailUrl,
  });

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isVideo => type == 'video';

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return 'À l\'instant';
    }
  }

  Story copyWith({
    String? id,
    String? professionalId,
    String? url,
    String? type,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? seen,
    int? views,
    String? thumbnailUrl,
  }) {
    return Story(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      url: url ?? this.url,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      seen: seen ?? this.seen,
      views: views ?? this.views,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
