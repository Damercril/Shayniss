import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'fr_FR');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR');
  
  /// Formate une date en format français (dd/MM/yyyy)
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }
  
  /// Formate une heure en format 24h (HH:mm)
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }
  
  /// Formate une date et heure (dd/MM/yyyy à HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }
  
  /// Formate une durée en minutes en format lisible (1h 30min)
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0) {
      return mins > 0 ? '${hours}h ${mins}min' : '${hours}h';
    } else {
      return '${mins}min';
    }
  }
  
  /// Formate une date relative (Aujourd'hui, Hier, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Aujourd\'hui à ${formatTime(date)}';
    } else if (dateOnly == yesterday) {
      return 'Hier à ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }
}
