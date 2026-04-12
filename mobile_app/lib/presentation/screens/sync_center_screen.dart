import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _loadPendingRecords();
  }

  Future<void> _loadPendingRecords() async {
    final db = await DatabaseHelper().database;
    final results = await db.query('Sync_Status', where: "sync_status = 'PENDING'");
    setState(() {
      _pendingRecords = results;
      _isLoading = false;
    });
  }

  Future<void> _startSync() async {
    setState(() => _isSyncing = true);
    try {
      await SyncService().syncData();
      await _loadPendingRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sync Successful"), backgroundColor: Color(0xFF27AE60)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sync Failed. Check Internet."), backgroundColor: Colors.redAccent),
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Sync Center", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildSyncHeader(primaryColor),
              Expanded(
                child: _pendingRecords.isEmpty 
                  ? _buildAllSyncedState() 
                  : _buildPendingList(),
              ),
              _buildHistorySection(),
            ],
          ),
      bottomNavigationBar: _pendingRecords.isEmpty ? null : Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          onPressed: _isSyncing ? null : _startSync,
          icon: _isSyncing 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
          label: Text(_isSyncing ? "SYNCING..." : "SYNC ALL RECORDS", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
        ),
      ),
    );
  }

  Widget _buildSyncHeader(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_sync_rounded, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            _pendingRecords.isEmpty ? "System Up-to-Date" : "${_pendingRecords.length} Records to Sync",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Last successful sync: Today, ${DateFormat('jm').format(DateTime.now())}",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _pendingRecords.length,
      itemBuilder: (context, index) {
        final record = _pendingRecords[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFFF4ED), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.description_rounded, color: Color(0xFFD35400)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record['entity_type'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text("Operation: ${record['operation']}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.pending_actions_rounded, color: Colors.amber),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllSyncedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, size: 80, color: Color(0xFF27AE60)),
          const SizedBox(height: 16),
          Text("All data is synced!", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50))),
          Text("Your offline records match the cloud server.", style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recent Activity", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildHistoryTile("Successful Push", "24 Records", "10:30 AM", true),
          _buildHistoryTile("Database Cleanup", "System", "09:00 AM", true),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(String title, String details, String time, bool success) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.history_rounded, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            Text(details, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
          ])),
          Text(time, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
