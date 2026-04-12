import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/health_visit_model.dart';
import '../models/sync_status_model.dart';

class HealthVisitRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(HealthVisit visit) async {
    final db = await _dbHelper.database;

    return await db.transaction((txn) async {
      int result = await txn.insert('Health_Visit', visit.toMap());

      await txn.insert('Sync_Status', SyncStatus(
        entityType: 'Health_Visit',
        entityId: visit.visitId,
        operation: 'CREATE',
      ).toMap());

      return result;
    });
  }

  Future<int> update(HealthVisit visit) async {
    final db = await _dbHelper.database;

    return await db.transaction((txn) async {
      int result = await txn.update(
        'Health_Visit',
        visit.toMap(),
        where: 'visit_id = ?',
        whereArgs: [visit.visitId],
      );

      final existingSync = await txn.query(
        'Sync_Status',
        where: 'entity_id = ? AND sync_status = ?',
        whereArgs: [visit.visitId, 'PENDING'],
      );

      if (existingSync.isEmpty) {
        await txn.insert('Sync_Status', SyncStatus(
          entityType: 'Health_Visit',
          entityId: visit.visitId,
          operation: 'UPDATE',
        ).toMap());
      }

      return result;
    });
  }

  Future<List<HealthVisit>> getByPatient(String patientId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Health_Visit',
      where: 'patient_id = ? AND is_deleted = 0',
      whereArgs: [patientId],
    );

    return List.generate(maps.length, (i) {
      return HealthVisit.fromMap(maps[i]);
    });
  }
}
