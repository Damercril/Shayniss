import '../../../core/database/database_helper.dart';
import '../models/client.dart';

class ClientRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<String> createClient(Client client) async {
    final db = await _databaseHelper.database;
    await db.insert('clients', client.toMap());
    return client.id;
  }

  Future<Client?> getClient(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Client.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Client>> getAllClients() async {
    final db = await _databaseHelper.database;
    final result = await db.query('clients', orderBy: 'firstName, lastName');
    return result.map((json) => Client.fromMap(json)).toList();
  }

  Future<bool> updateClient(Client client) async {
    final db = await _databaseHelper.database;
    final rowsAffected = await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
    return rowsAffected > 0;
  }

  Future<bool> deleteClient(String id) async {
    final db = await _databaseHelper.database;
    final rowsAffected = await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

  Future<List<Client>> searchClients(String query) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'clients',
      where: 'firstName LIKE ? OR lastName LIKE ? OR email LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'firstName, lastName',
    );
    return result.map((json) => Client.fromMap(json)).toList();
  }
}
