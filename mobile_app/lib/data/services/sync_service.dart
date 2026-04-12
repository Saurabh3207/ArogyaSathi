import 'dart:convert';
import 'package:http/http.dart' as http;
import '../local/database_helper.dart';

class SyncService {
  final String _baseUrl = 'https://arogyasathi-api.onrender.com'; // Replace with actual backend URL
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> syncData() async {
    final db = await _dbHelper.database;

    // 1. Get all pending sync operations
    final List<Map<String, dynamic>> pendingSyncs = await db.query(
      'Sync_Status',
      where: 'sync_status = ?',
      whereArgs: ['PENDING'],
    );

    if (pendingSyncs.isEmpty) return;

    for (var syncItem in pendingSyncs) {
      final String entityType = syncItem['entity_type'];
      final String entityId = syncItem['entity_id'];
      final String operation = syncItem['operation'];
      final String syncId = syncItem['sync_id'];

      try {
        // 2. Fetch the actual data for the entity
        final List<Map<String, dynamic>> entityData = await db.query(
          entityType,
          where: _getIdColumnName(entityType) + ' = ?',
          whereArgs: [entityId],
        );

        if (entityData.isEmpty) {
          // If data is missing locally, we can't sync it. Mark as failed or skip.
          continue;
        }

        // 3. Send to API
        final bool success = await _sendToApi(entityType, operation, entityData.first);

        if (success) {
          // 4. Update sync status to SYNCED
          await db.update(
            'Sync_Status',
            {'sync_status': 'SYNCED'},
            where: 'sync_id = ?',
            whereArgs: [syncId],
          );
        }
      } catch (e) {
        print("Sync failed for $entityType $entityId: $e");
      }
    }
  }

  String _getIdColumnName(String entityType) {
    switch (entityType) {
      case 'Household': return 'household_id';
      case 'Patient': return 'patient_id';
      case 'Health_Visit': return 'visit_id';
      case 'NCD_Screening': return 'screening_id';
      case 'Immunization_Record': return 'immunization_id';
      case 'Camp_Event': return 'camp_id';
      case 'Vital_Events': return 'event_id';
      default: return 'id';
    }
  }

  Future<bool> _sendToApi(String entityType, String operation, Map<String, dynamic> data) async {
    final String endpoint = '/api/sync/${entityType.toLowerCase()}';
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'operation': operation,
          'data': data,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
