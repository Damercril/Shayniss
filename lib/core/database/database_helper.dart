import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/appointments/models/appointment.dart';
import '../../features/services/models/service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shayniss.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients(
        id TEXT PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE services(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        duration INTEGER NOT NULL,
        description TEXT,
        isActive INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE appointments(
        id TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        serviceId TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (serviceId) REFERENCES services (id),
        FOREIGN KEY (clientId) REFERENCES clients (id)
      )
    ''');
  }

  // Services CRUD operations
  Future<String> createService(Service service) async {
    final db = await instance.database;
    await db.insert('services', service.toMap());
    return service.id;
  }

  Future<Service?> getService(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Service.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Service>> getAllServices() async {
    final db = await instance.database;
    final result = await db.query('services', orderBy: 'name');
    return result.map((json) => Service.fromMap(json)).toList();
  }

  Future<int> updateService(Service service) async {
    final db = await instance.database;
    return db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(String id) async {
    final db = await instance.database;
    return await db.delete(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Appointments CRUD operations
  Future<String> createAppointment(Appointment appointment) async {
    final db = await instance.database;
    await db.insert('appointments', appointment.toMap());
    return appointment.id;
  }

  Future<Appointment?> getAppointment(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Appointment.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Appointment>> getAppointmentsByDate(DateTime date) async {
    final db = await instance.database;
    final startDate = DateTime(date.year, date.month, date.day).toIso8601String();
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59)
        .toIso8601String();

    final result = await db.query(
      'appointments',
      where: 'dateTime BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'dateTime ASC',
    );

    return result.map((json) => Appointment.fromMap(json)).toList();
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await instance.database;
    return db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> deleteAppointment(String id) async {
    final db = await instance.database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
