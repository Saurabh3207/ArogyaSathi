import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/sync_status_model.dart';

class SyncRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Fetches all records that are pending synchronization.
  Future<List<SyncStatus>> getPendingSyncRecords() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Sync_Status',
      where: 'sync_status = ?',
      whereArgs: ['PENDING'],
    );

    return List.generate(maps.length, (i) {
      return SyncStatus.fromMap(maps[i]);
    });
  }

  /// Updates the status of a sync record to 'SYNCED'.
  Future<int> markAsSynced(String syncId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'Sync_Status',
      {'sync_status': 'SYNCED'},
      where: 'sync_id = ?',
      whereArgs: [syncId],
    );
  }

  /// Fetches the actual data for a pending record.
  /// This is a generic method to get the map of the entity being synced.
  Future<Map<String, dynamic>?> getEntityData(String entityType, String entityId) async {
    final db = await _dbHelper.database;
    String tableName = entityType; // Assuming table name matches entityType
    String idColumn = _getIdColumnName(entityType);

    final List<Map<String, dynamic>> results = await db.query(
      tableName,
      where: '$idColumn = ?',
      whereArgs: [entityId],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  String _getIdColumnName(String entityType) {
    switch (entityType) {
      case 'ASHA_Worker': return 'asha_id';
      case 'Household': return 'household_id';
      case 'Patient': return 'patient_id';
      case 'Health_Visit': return 'visit_id';
      case 'NCD_Screening': return 'screening_id';
      case 'Vital_Events': return 'event_id';
      case 'Immunization_Record': return 'immunization_id';
      case 'Camp_Event': return 'camp_id';
      default: return 'id';
    }
  }
}
