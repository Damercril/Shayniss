import '../../../core/database/database_helper.dart';
import '../models/service.dart';

class ServiceRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<String> createService(Service service) async {
    return await _databaseHelper.createService(service);
  }

  Future<Service?> getService(String id) async {
    return await _databaseHelper.getService(id);
  }

  Future<List<Service>> getAllServices() async {
    return await _databaseHelper.getAllServices();
  }

  Future<bool> updateService(Service service) async {
    final rowsAffected = await _databaseHelper.updateService(service);
    return rowsAffected > 0;
  }

  Future<bool> deleteService(String id) async {
    final rowsAffected = await _databaseHelper.deleteService(id);
    return rowsAffected > 0;
  }
}
