import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/local/database_helper.dart';
import '../../data/services/sync_service.dart';

class SyncCenterScreen extends StatefulWidget {
  const SyncCenterScreen({super.key});

  @override
  State<SyncCenterScreen> createState() => _SyncCenterScreenState();
}

class _SyncCenterScreenState extends State<SyncCenterScreen> {
  List<Map<String, dynamic>> _pendingRecords = [];
  bool _isSyncing = false;
  bool _isLoading = true;

  String _lastSyncTime = "Never";

  @override
  void initState() {
    super.initState();
    _loadSyncMetadata();
    _loadPendingRecords();
  }

  Future<void> _loadSyncMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastSyncTime = prefs.getString('last_sync_timestamp') ?? "Never";
    });
  }

  Future<void> _loadPendingRecords() async {
    try {
      final db = await DatabaseHelper().database;
      final results = await db.rawQuery('''
        SELECT s.*, 
          CASE 
            WHEN s.entity_type = 'Patient' THEN (SELECT first_name FROM Patient WHERE patient_id = s.entity_id)
            WHEN s.entity_type = 'Household' THEN (SELECT head_of_family_name FROM Household WHERE household_id = s.entity_id)
            WHEN s.entity_type = 'NCD_Screening' THEN (SELECT p.first_name FROM Patient p JOIN NCD_Screening n ON p.patient_id = n.patient_id WHERE n.screening_id = s.entity_id)
            WHEN s.entity_type = 'Health_Visit' THEN (SELECT p.first_name FROM Patient p JOIN Health_Visit v ON p.patient_id = v.patient_id WHERE v.visit_id = s.entity_id)
            WHEN s.entity_type = 'Immunization_Record' THEN (SELECT p.first_name FROM Patient p JOIN Immunization_Record i ON p.patient_id = i.patient_id WHERE i.immunization_id = s.entity_id)
            WHEN s.entity_type = 'Vital_Events' THEN (SELECT p.first_name FROM Patient p JOIN Vital_Events v ON p.patient_id = v.patient_id WHERE v.event_id = s.entity_id)
            WHEN s.entity_type = 'Camp_Event' THEN (SELECT camp_type FROM Camp_Event WHERE camp_id = s.entity_id)
            ELSE 'System Record'
          END as display_name
        FROM Sync_Status s
        WHERE s.sync_status = 'PENDING'
        ORDER BY s.created_at DESC
      ''');
      
      setState(() {
        _pendingRecords = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading pending records: $e");
      setState(() {
        _isLoading = false;
        _pendingRecords = [];
      });
    }
  }

  Future<void> _startSync() async {
    setState(() => _isSyncing = true);
    try {
      await SyncService().syncPendingRecords();
      
      // Update last sync time
      final now = DateFormat('jm').format(DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_timestamp', "Today, $now");
      
      await _loadPendingRecords();
      setState(() {
        _lastSyncTime = "Today, $now";
      });

      if (mounted) {
        if (_pendingRecords.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("All records synced successfully!"), 
              backgroundColor: Color(0xFF27AE60),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Synced some records. ${_pendingRecords.length} still pending."), 
              backgroundColor: Colors.orangeAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sync Failed. Check Internet Connection."), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Sync Center", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D2939),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryColor))
        : Column(
            children: [
              _buildSyncStatusHeader(primaryColor),
              Expanded(
                child: _pendingRecords.isEmpty 
                  ? _buildAllSyncedState() 
                  : _buildPendingList(primaryColor),
              ),
            ],
          ),
      bottomNavigationBar: _pendingRecords.isEmpty ? null : _buildSyncButton(primaryColor),
    );
  }

  Widget _buildSyncStatusHeader(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.sync_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            _pendingRecords.isEmpty ? "All Data Secure" : "${_pendingRecords.length} Records to Sync",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Last successful sync: $_lastSyncTime",
            style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingList(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Text("PENDING QUEUE", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF667085), letterSpacing: 1.1)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _pendingRecords.length,
            itemBuilder: (context, index) {
              final record = _pendingRecords[index];
              final String time = record['created_at'] != null 
                  ? DateFormat('hh:mm a').format(DateTime.parse(record['created_at']))
                  : "Just now";
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: Row(
                  children: [
                    _getIconForType(record['entity_type']),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record['display_name'] ?? record['entity_type'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1D2939))),
                          Text("${record['entity_type']} • ${record['operation']}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(time, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF98A2B3))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFFFF9EB), borderRadius: BorderRadius.circular(6)),
                          child: const Text("PENDING", style: TextStyle(color: Color(0xFFB54708), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getIconForType(String type) {
    IconData icon;
    Color color;
    if (type == 'Patient') {
      icon = Icons.person_rounded;
      color = const Color(0xFF2E90FA);
    } else if (type == 'Household') {
      icon = Icons.home_rounded;
      color = const Color(0xFFF79009);
    } else {
      icon = Icons.assignment_rounded;
      color = const Color(0xFF667085);
    }
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildAllSyncedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Color(0xFFF0FFF4), shape: BoxShape.circle),
            child: const Icon(Icons.verified_rounded, size: 64, color: Color(0xFF27AE60)),
          ),
          const SizedBox(height: 24),
          Text("System Synced", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1D2939))),
          const SizedBox(height: 8),
          Text("All your offline records are up to date.", style: GoogleFonts.poppins(color: const Color(0xFF667085))),
        ],
      ),
    );
  }

  Widget _buildSyncButton(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _isSyncing ? null : _startSync,
          icon: _isSyncing 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
          label: Text(_isSyncing ? "SYNCING DATA..." : "SYNC ALL RECORDS", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
