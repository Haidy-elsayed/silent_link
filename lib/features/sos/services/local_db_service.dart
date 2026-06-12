import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sos_request_model.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'silent_link.db');

    return await openDatabase(
      path,
      version: 4, // ⬆️ رفعنا الـ version
      onCreate: _createTable,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // FIX: بدل ما نعمل DROP ونخسر الداتا
          // بنضيف الـ column الناقصة بس
          try {
            await db.execute(
              'ALTER TABLE sos_requests ADD COLUMN ClientRequestId TEXT',
            );
          } catch (_) {
            // لو الـ column موجودة أصلاً → ignore
          }
        }
      },
    );
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sos_requests (
        SosId TEXT,
        EmergencyType TEXT NOT NULL,
        InjuryType TEXT NOT NULL,
        State TEXT NOT NULL,
        Severity TEXT NOT NULL,
        Latitude REAL NOT NULL,
        Longitude REAL NOT NULL,
        LocationName TEXT NOT NULL,
        Organization TEXT NOT NULL,
        Country TEXT NOT NULL,
        RequestedByUserId TEXT NOT NULL,
        Name TEXT NOT NULL,
        Phone TEXT NOT NULL,
        DeliveryMethod TEXT NOT NULL,
        CreatedAt TEXT NOT NULL PRIMARY KEY,
        ClientRequestId TEXT
      )
    ''');
  }

  // ===========================
  // INSERT
  // ===========================
  Future<void> insertSosRequest(SosRequestModel request) async {
    final db = await database;
    await db.insert(
      'sos_requests',
      _toMap(request),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===========================
  // READ
  // ===========================
  Future<SosRequestModel?> getLatestPendingRequest() async {
    final db = await database;
    final result = await db.query(
      'sos_requests',
      where: 'State = ? OR State = ? OR State = ?',
      whereArgs: ['pending', 'pending_connection', 'forwarded_bluetooth'],
      orderBy: 'CreatedAt DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return _fromMap(result.first);
  }

  Future<List<SosRequestModel>> getReceivedBluetoothRequests() async {
    final db = await database;
    final result = await db.query(
      'sos_requests',
      where: 'State = ? OR State = ?',
      whereArgs: ['received_bluetooth', 'forwarded_bluetooth'],
    );
    return result.map((row) => _fromMap(row)).toList();
  }

  Future<List<SosRequestModel>> getMyPendingRequests() async {
    final db = await database;
    final result = await db.query(
      'sos_requests',
      where: 'State = ? OR State = ?',
      whereArgs: ['pending', 'pending_connection'],
      orderBy: 'CreatedAt ASC',
    );
    return result.map((row) => _fromMap(row)).toList();
  }

  Future<List<SosRequestModel>> getPendingRequests() async {
    final db = await database;
    final result = await db.query(
      'sos_requests',
      where: 'State = ? OR State = ? OR State = ?',
      whereArgs: ['pending', 'pending_connection', 'received_bluetooth'],
      orderBy: 'CreatedAt DESC',
    );
    return result.map((row) => _fromMap(row)).toList();
  }

  Future<List<SosRequestModel>> getAllRequests() async {
    final db = await database;
    final result = await db.query(
      'sos_requests',
      orderBy: 'CreatedAt DESC',
    );
    return result.map((row) => _fromMap(row)).toList();
  }

  Future<SosRequestModel?> getRequestBySosId(String sosId) async {
    final db = await database;
    final result = await db.query(
      'sos_requests',
      where: 'SosId = ?',
      whereArgs: [sosId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return _fromMap(result.first);
  }

  Future<SosRequestModel?> getRequestByCreatedAt(String createdAt) async {
    final db = await database;
    final result = await db.query(
      'sos_requests',
      where: 'CreatedAt = ?',
      whereArgs: [createdAt],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return _fromMap(result.first);
  }

  // ===========================
  // UPDATE
  // ===========================
  Future<void> updateSosId(String createdAt, String sosId) async {
    final db = await database;
    await db.update(
      'sos_requests',
      {'SosId': sosId},
      where: 'CreatedAt = ?',
      whereArgs: [createdAt],
    );
  }

  Future<void> updateState(String sosId, String newState) async {
    final db = await database;
    await db.update(
      'sos_requests',
      {'State': newState},
      where: 'SosId = ?',
      whereArgs: [sosId],
    );
  }

  Future<void> updateStateBySosIdOrCreatedAt({
    required String? sosId,
    required String createdAt,
    required String newState,
  }) async {
    final db = await database;
    if (sosId != null && sosId.isNotEmpty) {
      await db.update(
        'sos_requests',
        {'State': newState},
        where: 'SosId = ?',
        whereArgs: [sosId],
      );
    } else {
      await db.update(
        'sos_requests',
        {'State': newState},
        where: 'CreatedAt = ?',
        whereArgs: [createdAt],
      );
    }
  }

  Future<void> updateDeliveryMethod(String sosId, String method) async {
    final db = await database;
    await db.update(
      'sos_requests',
      {'DeliveryMethod': method},
      where: 'SosId = ?',
      whereArgs: [sosId],
    );
  }

  // ===========================
  // DELETE
  // ===========================
  Future<void> deleteRequest(String sosId) async {
    final db = await database;
    await db.delete(
      'sos_requests',
      where: 'SosId = ?',
      whereArgs: [sosId],
    );
  }

  Future<void> clearDelivered() async {
    final db = await database;
    await db.delete(
      'sos_requests',
      where: 'State = ?',
      whereArgs: ['delivered'],
    );
  }

  // ===========================
  // Helpers
  // ===========================
  Map<String, dynamic> _toMap(SosRequestModel r) {
    return {
      'SosId': r.sosId,
      'EmergencyType': r.emergencyType,
      'InjuryType': r.injuryType,
      'State': r.state,
      'Severity': r.severity,
      'Latitude': r.latitude,
      'Longitude': r.longitude,
      'LocationName': r.locationName,
      'Organization': r.organization,
      'Country': r.country,
      'RequestedByUserId': r.requestedByUserId,
      'Name': r.name,
      'Phone': r.phone,
      'DeliveryMethod': r.deliveryMethod,
      'CreatedAt': r.createdAt.toIso8601String(),
      'ClientRequestId': r.clientRequestId,
    };
  }

  SosRequestModel _fromMap(Map<String, dynamic> map) {
    return SosRequestModel(
      sosId: map['SosId'],
      emergencyType: map['EmergencyType'],
      injuryType: map['InjuryType'],
      state: map['State'],
      severity: map['Severity'],
      latitude: map['Latitude'],
      longitude: map['Longitude'],
      locationName: map['LocationName'],
      organization: map['Organization'],
      country: map['Country'],
      requestedByUserId: map['RequestedByUserId'],
      name: map['Name'],
      phone: map['Phone'],
      deliveryMethod: map['DeliveryMethod'],
      createdAt: DateTime.parse(map['CreatedAt']),
      clientRequestId: map['ClientRequestId']?.toString(),
    );
  }
}