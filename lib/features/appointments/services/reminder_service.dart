import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/appointment.dart';
import 'appointment_details_service.dart';

class ReminderService {
  static final ReminderService instance = ReminderService._();
  final AppointmentDetailsService _detailsService = AppointmentDetailsService.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  Timer? _dailyCheckTimer;

  ReminderService._() {
    _initializeNotifications();
    _startDailyCheck();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  void _startDailyCheck() {
    // Vérifier les rendez-vous tous les jours à minuit
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = nextMidnight.difference(now);

    // Premier check après le délai jusqu'à minuit
    Timer(timeUntilMidnight, () {
      _checkAndSendReminders();
      
      // Ensuite, check toutes les 24 heures
      _dailyCheckTimer = Timer.periodic(
        const Duration(hours: 24),
        (_) => _checkAndSendReminders(),
      );
    });
  }

  Future<void> _checkAndSendReminders() async {
    await _detailsService.scheduleReminders();
  }

  Future<void> scheduleReminder(Appointment appointment) async {
    final details = await _detailsService.getAppointmentDetails(appointment);
    
    // Calculer le moment du rappel (24h avant le rendez-vous)
    final scheduledDate = appointment.dateTime.subtract(const Duration(days: 1));
    
    // Ne pas envoyer de rappel si le rendez-vous est dans moins de 24h
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      appointment.id.hashCode,
      'Rappel de rendez-vous',
      'Vous avez rendez-vous demain à ${appointment.dateTime.hour}:${appointment.dateTime.minute} '
      'pour ${details['serviceName']}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'appointments',
          'Rappels de rendez-vous',
          channelDescription: 'Notifications pour les rappels de rendez-vous',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String appointmentId) async {
    await _notifications.cancel(appointmentId.hashCode);
  }

  void dispose() {
    _dailyCheckTimer?.cancel();
  }
}
