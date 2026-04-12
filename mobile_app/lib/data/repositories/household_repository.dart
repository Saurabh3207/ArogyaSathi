import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/household_model.dart';
import '../models/sync_status_model.dart';

class HouseholdRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insert(Household household) async {
    final db = await _dbHelper.database;
    
    return await db.transaction((txn) async {
      // 1. Insert Household
      int result = await txn.insert('Household', household.toMap());

      // 2. Track Sync Status
      await txn.insert('Sync_Status', SyncStatus(
        entityType: 'Household',
        entityId: household.householdId,
        operation: 'CREATE',
      ).toMap());

      return result;
    });
  }

  Future<int> update(Household household) async {
    final db = await _dbHelper.database;

    return await db.transaction((txn) async {
      // 1. Update Household
      int result = await txn.update(
        'Household',
        household.toMap(),
        where: 'household_id = ?',
        whereArgs: [household.householdId],
      );

      // 2. Track Sync Status
      final existingSync = await txn.query(
        'Sync_Status',
        where: 'entity_id = ? AND sync_status = ?',
        whereArgs: [household.householdId, 'PENDING'],
      );

      if (existingSync.isEmpty) {
        await txn.insert('Sync_Status', SyncStatus(
          entityType: 'Household',
          entityId: household.householdId,
          operation: 'UPDATE',
        ).toMap());
      }

      return result;
    });
  }

  Future<int> softDelete(String householdId) async {
    final db = await _dbHelper.database;
    final timestamp = DateTime.now().toIso8601String();

    return await db.transaction((txn) async {
      // 1. Mark as deleted
      int result = await txn.update(
        'Household',
        {
          'is_deleted': 1,
          'last_modified_at': timestamp,
        },
        where: 'household_id = ?',
        whereArgs: [householdId],
      );

      // 2. Track Sync Status
      final existingSync = await txn.query(
        'Sync_Status',
        where: 'entity_id = ? AND sync_status = ?',
        whereArgs: [householdId, 'PENDING'],
      );

      if (existingSync.isEmpty) {
        await txn.insert('Sync_Status', SyncStatus(
          entityType: 'Household',
          entityId: householdId,
          operation: 'SOFT_DELETE',
        ).toMap());
      } else {
        await txn.update(
          'Sync_Status',
          {'operation': 'SOFT_DELETE'},
          where: 'entity_id = ? AND sync_status = ?',
          whereArgs: [householdId, 'PENDING'],
        );
      }

      return result;
    });
  }

  Future<List<Household>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Household',
      where: 'is_deleted = 0',
    );

    return List.generate(maps.length, (i) {
      return Household.fromMap(maps[i]);
    });
  }

  Future<Household?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Household',
      where: 'household_id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Household.fromMap(maps.first);
    }
    return null;
  }

  Future<int> countTotal() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM Household WHERE is_deleted = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
