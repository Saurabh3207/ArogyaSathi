import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/immunization_record_model.dart';
import '../models/sync_status_model.dart';

class ImmunizationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(ImmunizationRecord record) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      int result = await txn.insert('Immunization_Record', record.toMap());
      await txn.insert('Sync_Status', SyncStatus(
        entityType: 'Immunization_Record',
        entityId: record.immunizationId,
        operation: 'CREATE',
      ).toMap());
      return result;
    });
  }

  Future<int> update(ImmunizationRecord record) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      int result = await txn.update(
        'Immunization_Record',
        record.toMap(),
        where: 'immunization_id = ?',
        whereArgs: [record.immunizationId],
      );
      final existingSync = await txn.query(
        'Sync_Status',
        where: 'entity_id = ? AND sync_status = ?',
        whereArgs: [record.immunizationId, 'PENDING'],
      );
      if (existingSync.isEmpty) {
        await txn.insert('Sync_Status', SyncStatus(
          entityType: 'Immunization_Record',
          entityId: record.immunizationId,
          operation: 'UPDATE',
        ).toMap());
      }
      return result;
    });
  }

  Future<List<ImmunizationRecord>> getByPatient(String patientId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Immunization_Record',
      where: 'patient_id = ? AND is_deleted = 0',
      whereArgs: [patientId],
    );
    return List.generate(maps.length, (i) {
      return ImmunizationRecord.fromMap(maps[i]);
    });
  }
}
