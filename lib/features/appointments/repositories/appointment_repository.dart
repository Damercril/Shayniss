import '../../../core/database/database_helper.dart';
import '../models/appointment.dart';

class AppointmentRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<String> createAppointment(Appointment appointment) async {
    return await _databaseHelper.createAppointment(appointment);
  }

  Future<Appointment?> getAppointment(String id) async {
    return await _databaseHelper.getAppointment(id);
  }

  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    return await _databaseHelper.getAppointmentsByDate(date);
  }

  Future<bool> updateAppointment(Appointment appointment) async {
    final rowsAffected = await _databaseHelper.updateAppointment(appointment);
    return rowsAffected > 0;
  }

  Future<bool> deleteAppointment(String id) async {
    final rowsAffected = await _databaseHelper.deleteAppointment(id);
    return rowsAffected > 0;
  }
}
