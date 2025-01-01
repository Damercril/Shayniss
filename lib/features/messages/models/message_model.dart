import 'dart:convert';

enum MessageType {
  text,
  image,
  file,
  audio,
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final MessageAttachment? attachment;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.attachment,
  });

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
    MessageAttachment? attachment,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      attachment: attachment ?? this.attachment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.index,
      'attachment': attachment?.toJson(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      type: MessageType.values[json['type'] ?? 0],
      attachment: json['attachment'] != null
          ? MessageAttachment.fromJson(json['attachment'])
          : null,
    );
  }
}

class MessageAttachment {
  final String id;
  final String type;
  final String url;
  final String? thumbnailUrl;
  final String? name;
  final int? size;
  final String? mimeType;
  final Duration? duration;

  MessageAttachment({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.name,
    this.size,
    this.mimeType,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'name': name,
      'size': size,
      'mimeType': mimeType,
      'duration': duration?.inMilliseconds,
    };
  }

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'],
      type: json['type'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      name: json['name'],
      size: json['size'],
      mimeType: json['mimeType'],
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
    );
  }
}

// Extension pour formater les dates
extension DateTimeExtension on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year}';
    }
  }

  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
