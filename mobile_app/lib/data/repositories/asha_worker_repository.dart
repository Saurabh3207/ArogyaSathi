import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/asha_worker_model.dart';
import '../models/sync_status_model.dart';

class AshaWorkerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(AshaWorker worker) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      int result = await txn.insert('ASHA_Worker', worker.toMap());
      
      await txn.insert('Sync_Status', SyncStatus(
        entityType: 'ASHA_Worker',
        entityId: worker.ashaId,
        operation: 'CREATE',
      ).toMap());
      
      return result;
    });
  }

  Future<int> update(AshaWorker worker) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      int result = await txn.update(
        'ASHA_Worker',
        worker.toMap(),
        where: 'asha_id = ?',
        whereArgs: [worker.ashaId],
      );

      final existingSync = await txn.query(
        'Sync_Status',
        where: 'entity_id = ? AND sync_status = ?',
        whereArgs: [worker.ashaId, 'PENDING'],
      );

      if (existingSync.isEmpty) {
        await txn.insert('Sync_Status', SyncStatus(
          entityType: 'ASHA_Worker',
          entityId: worker.ashaId,
          operation: 'UPDATE',
        ).toMap());
      }
      
      return result;
    });
  }

  Future<AshaWorker?> getWorker() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ASHA_Worker',
      where: 'is_deleted = 0',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return AshaWorker.fromMap(maps.first);
    }
    return null;
  }

  Future<void> logout() async {
    final db = await _dbHelper.database;
    await db.update(
      'ASHA_Worker',
      {'auth_token': null, 'session_expiry': null},
    );
  }
}
