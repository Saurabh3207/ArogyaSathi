import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/vital_event_model.dart';
import '../models/sync_status_model.dart';

class VitalEventRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(VitalEvent event) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      int result = await txn.insert('Vital_Events', event.toMap());
      await txn.insert('Sync_Status', SyncStatus(
        entityType: 'Vital_Events',
        entityId: event.eventId,
        operation: 'CREATE',
      ).toMap());
      return result;
    });
  }

  Future<int> update(VitalEvent event) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      int result = await txn.update(
        'Vital_Events',
        event.toMap(),
        where: 'event_id = ?',
        whereArgs: [event.eventId],
      );
      final existingSync = await txn.query(
        'Sync_Status',
        where: 'entity_id = ? AND sync_status = ?',
        whereArgs: [event.eventId, 'PENDING'],
      );
      if (existingSync.isEmpty) {
        await txn.insert('Sync_Status', SyncStatus(
          entityType: 'Vital_Events',
          entityId: event.eventId,
          operation: 'UPDATE',
        ).toMap());
      }
      return result;
    });
  }

  Future<List<VitalEvent>> getByPatient(String patientId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Vital_Events',
      where: 'patient_id = ? AND is_deleted = 0',
      whereArgs: [patientId],
    );
    return List.generate(maps.length, (i) {
      return VitalEvent.fromMap(maps[i]);
    });
  }
}
