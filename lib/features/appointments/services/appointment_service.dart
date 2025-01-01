import 'package:shared_preferences.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  static final AppointmentService _instance = AppointmentService._();
  static AppointmentService get instance => _instance;

  late final SharedPreferences _prefs;
  final String _appointmentsKey = 'appointments';
  List<Appointment> _appointments = [];

  AppointmentService._();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAppointments();
  }

  void _loadAppointments() {
    final appointmentsJson = _prefs.getStringList(_appointmentsKey) ?? [];
    _appointments = appointmentsJson
        .map((json) => Appointment.fromJson(Map<String, dynamic>.from(
            Map<String, dynamic>.from(json as Map))))
        .toList();
  }

  Future<void> _saveAppointments() async {
    final appointmentsJson =
        _appointments.map((appointment) => appointment.toJson()).toList();
    await _prefs.setStringList(_appointmentsKey,
        appointmentsJson.map((json) => json.toString()).toList());
  }

  Future<void> addAppointment(Appointment appointment) async {
    _appointments.add(appointment);
    await _saveAppointments();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final index = _appointments.indexWhere((a) => a.id == appointment.id);
    if (index != -1) {
      _appointments[index] = appointment;
      await _saveAppointments();
    }
  }

  Future<void> deleteAppointment(String id) async {
    _appointments.removeWhere((appointment) => appointment.id == id);
    await _saveAppointments();
  }

  Future<void> updateAppointmentStatus(
      String id, AppointmentStatus status) async {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await _saveAppointments();
    }
  }

  List<Appointment> getAppointments({
    DateTime? startDate,
    DateTime? endDate,
    AppointmentStatus? status,
    String? clientId,
  }) {
    return _appointments.where((appointment) {
      if (startDate != null && appointment.dateTime.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && appointment.dateTime.isAfter(endDate)) {
        return false;
      }
      if (status != null && appointment.status != status) {
        return false;
      }
      if (clientId != null && appointment.clientId != clientId) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    return _appointments
        .where((appointment) =>
            appointment.dateTime.isAfter(now) &&
            (appointment.isPending || appointment.isConfirmed))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Appointment> getTodayAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _appointments
        .where((appointment) =>
            appointment.dateTime.isAfter(today) &&
            appointment.dateTime.isBefore(tomorrow))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  bool isTimeSlotAvailable(DateTime dateTime, Duration duration) {
    final endTime = dateTime.add(duration);
    return !_appointments.any((appointment) {
      final appointmentEndTime =
          appointment.dateTime.add(appointment.duration);
      return (dateTime.isBefore(appointmentEndTime) &&
              endTime.isAfter(appointment.dateTime)) &&
          (appointment.isConfirmed || appointment.isPending);
    });
  }

  List<DateTime> getAvailableTimeSlots(
    DateTime date,
    Duration duration, {
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0),
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0),
    Duration interval = const Duration(minutes: 30),
  }) {
    final availableSlots = <DateTime>[];
    var currentTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    while (currentTime.add(duration).isBefore(endDateTime) ||
        currentTime.add(duration).isAtSameMomentAs(endDateTime)) {
      if (isTimeSlotAvailable(currentTime, duration)) {
        availableSlots.add(currentTime);
      }
      currentTime = currentTime.add(interval);
    }

    return availableSlots;
  }

  void dispose() {
    _appointments.clear();
  }
}
