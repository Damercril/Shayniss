import 'package:flutter/material.dart';

class ChatPreview {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatPreview({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  ChatPreview copyWith({
    String? id,
    String? name,
    String? avatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatPreview(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  // Données de test
  static List<ChatPreview> get samples => [
        ChatPreview(
          id: '1',
          name: 'Emma Laurent',
          avatar:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500',
          lastMessage: 'Je confirme mon rendez-vous pour demain à 14h',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
          unreadCount: 2,
          isOnline: true,
        ),
        ChatPreview(
          id: '2',
          name: 'Sophie Martin',
          avatar:
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500',
          lastMessage: 'Merci pour le soin, c\'était parfait !',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
          unreadCount: 0,
          isOnline: false,
        ),
        ChatPreview(
          id: '3',
          name: 'Marie Dubois',
          avatar:
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500',
          lastMessage: 'Est-ce que je peux décaler mon rendez-vous ?',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
          unreadCount: 1,
          isOnline: true,
        ),
        ChatPreview(
          id: '4',
          name: 'Julie Petit',
          avatar:
              'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=500',
          lastMessage: 'À bientôt !',
          lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
          unreadCount: 0,
          isOnline: false,
        ),
      ];
}
