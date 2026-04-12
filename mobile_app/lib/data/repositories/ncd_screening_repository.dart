import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/ncd_screening_model.dart';
import '../models/sync_status_model.dart';

class NcdScreeningRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(NCDScreening screening) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      int result = await txn.insert('NCD_Screening', screening.toMap());
      await txn.insert('Sync_Status', SyncStatus(
        entityType: 'NCD_Screening',
        entityId: screening.screeningId,
        operation: 'CREATE',
      ).toMap());
      return result;
    });
  }

  Future<int> update(NCDScreening screening) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      int result = await txn.update(
        'NCD_Screening',
        screening.toMap(),
        where: 'screening_id = ?',
        whereArgs: [screening.screeningId],
      );
      final existingSync = await txn.query(
        'Sync_Status',
        where: 'entity_id = ? AND sync_status = ?',
        whereArgs: [screening.screeningId, 'PENDING'],
      );
      if (existingSync.isEmpty) {
        await txn.insert('Sync_Status', SyncStatus(
          entityType: 'NCD_Screening',
          entityId: screening.screeningId,
          operation: 'UPDATE',
        ).toMap());
      }
      return result;
    });
  }

  Future<List<NCDScreening>> getByPatient(String patientId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'NCD_Screening',
      where: 'patient_id = ? AND is_deleted = 0',
      whereArgs: [patientId],
    );
    return List.generate(maps.length, (i) {
      return NCDScreening.fromMap(maps[i]);
    });
  }
}
