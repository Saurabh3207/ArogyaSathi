import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';

class AshaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'ASHA_Worker',
      where: 'is_deleted = 0',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> saveProfile(Map<String, dynamic> workerData) async {
    final db = await _dbHelper.database;
    await db.insert(
      'ASHA_Worker',
      workerData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> logout() async {
    final db = await _dbHelper.database;
    await db.delete('ASHA_Worker'); // For now, clear all to logout
  }
}
