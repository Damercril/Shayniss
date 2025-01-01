import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/app_notification.dart';
import '../../navigation/services/navigation_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  static PushNotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  PushNotificationService._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialisation des notifications locales
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      final initialized = await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Gérer la notification quand l'app est en arrière-plan
          if (response.payload != null) {
            try {
              final notification = AppNotification.fromJson(
                jsonDecode(response.payload!),
              );
              // Gérer la navigation basée sur la notification
              _handleNotificationTap(notification);
            } catch (e) {
              debugPrint('Erreur lors du décodage de la notification: $e');
            }
          }
        },
      );

      if (initialized != null && initialized) {
        // Demander les permissions sur iOS
        await _requestPermissions();
        _isInitialized = true;
        debugPrint('Notifications initialisées avec succès');
      } else {
        debugPrint('Échec de l\'initialisation des notifications');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation des notifications: $e');
      // Ne pas définir _isInitialized à true en cas d'erreur
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (Theme.of(NavigationService.context).platform == TargetPlatform.iOS) {
        final plugin = _localNotifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        
        if (plugin != null) {
          await plugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      } else if (Theme.of(NavigationService.context).platform == TargetPlatform.android) {
        // Sur Android 13 et supérieur, les permissions sont gérées par le système
        final plugin = _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        
        if (plugin != null) {
          // Rien à faire ici car les permissions sont gérées dans les paramètres système
          debugPrint('Android: Les permissions sont gérées dans les paramètres système');
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la demande des permissions: $e');
    }
  }

  Future<void> showNotification(AppNotification notification) async {
    if (!_isInitialized) {
      debugPrint('Les notifications ne sont pas initialisées');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'shayniss_channel',
        'Shayniss Notifications',
        channelDescription: 'Notifications pour l\'application Shayniss',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.id.hashCode,
        notification.title,
        notification.body,
        details,
        payload: jsonEncode(notification.toJson()),
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'affichage de la notification: $e');
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    try {
      // TODO: Implémenter la navigation basée sur le type de notification
      debugPrint('Notification tapped: ${notification.title}');
    } catch (e) {
      debugPrint('Erreur lors du traitement du tap sur la notification: $e');
    }
  }

  Future<void> showTestNotification() async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Test de notification',
      body: 'Ceci est une notification de test',
      type: 'test',
      payload: {'test': 'data'},
    );

    await showNotification(notification);
  }
}
