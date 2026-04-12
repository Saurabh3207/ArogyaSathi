import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/database_helper.dart';
import '../../data/repositories/asha_repository.dart';

class CampManagementScreen extends StatefulWidget {
  const CampManagementScreen({super.key});

  @override
  State<CampManagementScreen> createState() => _CampManagementScreenState();
}

class _CampManagementScreenState extends State<CampManagementScreen> {
  final List<Map<String, dynamic>> _camps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCamps();
  }

  Future<void> _loadCamps() async {
    final db = await DatabaseHelper().database;
    final results = await db.query('Camp_Event', where: 'is_deleted = 0', orderBy: 'camp_date DESC');
    setState(() {
      _camps.clear();
      _camps.addAll(results);
      _isLoading = false;
    });
  }

  Future<void> _addCamp() async {
    final asha = await AshaRepository().getCurrentProfile();
    final db = await DatabaseHelper().database;
    final campId = const Uuid().v4();

    await db.insert('Camp_Event', {
      'camp_id': campId,
      'asha_id': asha?['asha_id'] ?? 'ASHA-001',
      'camp_type': 'Immunization Camp',
      'camp_date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'location': 'Primary School Hall',
      'last_modified_at': DateTime.now().toIso8601String(),
      'is_deleted': 0,
    });
    
    _loadCamps();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      appBar: AppBar(
        title: Text("Health Camps", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _camps.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _camps.length,
              itemBuilder: (context, index) => _buildCampCard(_camps[index]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCamp,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text("Schedule Camp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No camps scheduled", style: GoogleFonts.poppins(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCampCard(Map<String, dynamic> camp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFF4ED), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.campaign_rounded, color: Color(0xFFD35400)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(camp['camp_type'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(camp['location'], style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          Text(camp['camp_date'].toString().split('T').first, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF27AE60))),
        ],
      ),
    );
  }
}
