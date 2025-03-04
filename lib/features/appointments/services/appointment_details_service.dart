import '../models/appointment.dart';
import '../repositories/appointment_repository.dart';
import '../../clients/repositories/client_repository.dart';
import '../../services/repositories/service_repository.dart';

class AppointmentDetailsService {
  static final AppointmentDetailsService instance = AppointmentDetailsService._();
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  final ClientRepository _clientRepository = ClientRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();

  AppointmentDetailsService._();

  Future<Map<String, dynamic>> getAppointmentDetails(Appointment appointment) async {
    final client = await _clientRepository.getClient(appointment.clientId);
    final service = await _serviceRepository.getService(appointment.serviceId);

    return {
      'clientName': client != null ? '${client.firstName} ${client.lastName}' : 'Client inconnu',
      'serviceName': service?.name ?? 'Service inconnu',
      'servicePrice': service?.price ?? 0.0,
      'serviceDuration': service?.duration ?? 0,
    };
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    final appointment = await _appointmentRepository.getAppointment(appointmentId);
    if (appointment != null) {
      final updatedAppointment = appointment.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await _appointmentRepository.updateAppointment(updatedAppointment);
    }
  }

  Future<void> sendAppointmentReminder(Appointment appointment) async {
    final details = await getAppointmentDetails(appointment);
    final client = await _clientRepository.getClient(appointment.clientId);
    
    if (client?.email != null) {
      // TODO: Implémenter l'envoi d'email
      print('Envoi du rappel par email à ${client!.email}');
    }
    
    if (client?.phone != null) {
      // TODO: Implémenter l'envoi de SMS
      print('Envoi du rappel par SMS au ${client!.phone}');
    }
  }

  Future<void> scheduleReminders() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    // Récupérer les rendez-vous de demain
    final appointments = await _appointmentRepository.getAppointmentsByDateRange(
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59),
    );

    // Envoyer les rappels pour chaque rendez-vous
    for (final appointment in appointments) {
      if (appointment.status == 'confirmed') {
        await sendAppointmentReminder(appointment);
      }
    }
  }
}
