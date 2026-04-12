import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/patient_model.dart';
import '../models/sync_status_model.dart';

class PatientRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Patient patient) async {
    final db = await _dbHelper.database;

    return await db.transaction((txn) async {
      // 1. Insert Patient
      int result = await txn.insert('Patient', patient.toMap());

      // 2. Track Sync Status
      await txn.insert('Sync_Status', SyncStatus(
        entityType: 'Patient',
        entityId: patient.patientId,
        operation: 'CREATE',
      ).toMap());

      return result;
    });
  }

  Future<int> update(Patient patient) async {
    final db = await _dbHelper.database;

    return await db.transaction((txn) async {
      // 1. Update Patient
      int result = await txn.update(
        'Patient',
        patient.toMap(),
        where: 'patient_id = ?',
        whereArgs: [patient.patientId],
      );

      // 2. Track Sync Status
      final existingSync = await txn.query(
        'Sync_Status',
        where: 'entity_id = ? AND sync_status = ?',
        whereArgs: [patient.patientId, 'PENDING'],
      );

      if (existingSync.isEmpty) {
        await txn.insert('Sync_Status', SyncStatus(
          entityType: 'Patient',
          entityId: patient.patientId,
          operation: 'UPDATE',
        ).toMap());
      }

      return result;
    });
  }

  Future<int> softDelete(String patientId) async {
    final db = await _dbHelper.database;
    final timestamp = DateTime.now().toIso8601String();

    return await db.transaction((txn) async {
      // 1. Mark as deleted
      int result = await txn.update(
        'Patient',
        {
          'is_deleted': 1,
          'last_modified_at': timestamp,
        },
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );

      // 2. Track Sync Status
      final existingSync = await txn.query(
        'Sync_Status',
        where: 'entity_id = ? AND sync_status = ?',
        whereArgs: [patientId, 'PENDING'],
      );

      if (existingSync.isEmpty) {
        await txn.insert('Sync_Status', SyncStatus(
          entityType: 'Patient',
          entityId: patientId,
          operation: 'SOFT_DELETE',
        ).toMap());
      } else {
        await txn.update(
          'Sync_Status',
          {'operation': 'SOFT_DELETE'},
          where: 'entity_id = ? AND sync_status = ?',
          whereArgs: [patientId, 'PENDING'],
        );
      }

      return result;
    });
  }

  Future<List<Patient>> getByHousehold(String householdId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Patient',
      where: 'household_id = ? AND is_deleted = 0',
      whereArgs: [householdId],
    );

    return List.generate(maps.length, (i) {
      return Patient.fromMap(maps[i]);
    });
  }

  Future<Patient?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Patient',
      where: 'patient_id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  Future<int> countTotal() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM Patient WHERE is_deleted = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Patient>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Patient',
      where: 'is_deleted = 0',
    );

    return List.generate(maps.length, (i) {
      return Patient.fromMap(maps[i]);
    });
  }
}
