import 'package:flutter/material.dart';

enum NotificationType {
  appointment,
  loyalty,
  marketing,
  system;

  String get label {
    switch (this) {
      case NotificationType.appointment:
        return 'Rendez-vous';
      case NotificationType.loyalty:
        return 'Fidélité';
      case NotificationType.marketing:
        return 'Promotion';
      case NotificationType.system:
        return 'Système';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.loyalty:
        return Icons.star;
      case NotificationType.marketing:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.appointment:
        return Colors.blue;
      case NotificationType.loyalty:
        return Colors.purple;
      case NotificationType.marketing:
        return Colors.orange;
      case NotificationType.system:
        return Colors.grey;
    }
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? date,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  // Méthodes de sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
      'data': data,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      date: DateTime.parse(json['date'] as String),
      type: NotificationType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      isRead: json['isRead'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  // Données de test
  static List<AppNotification> get samples => [
        AppNotification(
          id: '1',
          title: 'Rappel de rendez-vous',
          message:
              'Votre rendez-vous avec Emma Laurent est prévu demain à 14h00.',
          date: DateTime.now().add(const Duration(days: 1)),
          type: NotificationType.appointment,
          data: {
            'appointmentId': 'apt_123',
            'clientId': 'client_456',
            'time': '14:00',
          },
        ),
        AppNotification(
          id: '2',
          title: 'Points fidélité',
          message:
              'Félicitations ! Vous avez atteint le niveau Silver. Profitez de 5% de réduction sur vos prochains services.',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          type: NotificationType.loyalty,
          data: {
            'oldLevel': 'bronze',
            'newLevel': 'silver',
            'points': 500,
          },
        ),
        AppNotification(
          id: '3',
          title: 'Offre spéciale',
          message:
              '-20% sur tous les soins du visage pendant une semaine ! Profitez-en vite.',
          date: DateTime.now().subtract(const Duration(days: 1)),
          type: NotificationType.marketing,
          data: {
            'promoCode': 'BEAUTY20',
            'validUntil': DateTime.now().add(const Duration(days: 7)),
          },
        ),
        AppNotification(
          id: '4',
          title: 'Mise à jour système',
          message:
              'Une nouvelle version de l\'application est disponible. Mettez à jour pour profiter des dernières fonctionnalités.',
          date: DateTime.now().subtract(const Duration(days: 2)),
          type: NotificationType.system,
        ),
      ];
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

  String get formattedDateTime {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year} à ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
