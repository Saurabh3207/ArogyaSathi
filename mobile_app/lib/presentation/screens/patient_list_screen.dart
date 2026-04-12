import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/patient_repository.dart';
import '../../data/models/patient_model.dart';
import 'visit_history_screen.dart';
import 'immunization_form_screen.dart';
import '../../data/local/database_helper.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/sync_status_model.dart';

class PatientListScreen extends StatefulWidget {
  final String householdId;
  final String householdName;

  const PatientListScreen({
    super.key,
    required this.householdId,
    required this.householdName,
  });

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final PatientRepository _repository = PatientRepository();
  List<Patient> _allMembers = [];
  List<Patient> _filteredMembers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final allPatients = await _repository.getAll();
      setState(() {
        _allMembers = allPatients.where((p) => p.householdId == widget.householdId).toList();
        _filteredMembers = _allMembers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterMembers(String query) {
    setState(() {
      _filteredMembers = _allMembers
          .where((m) => m.firstName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  int _calculateAge(String dobString) {
    try {
      DateFormat format = DateFormat("dd/MM/yyyy");
      DateTime dob = format.parse(dobString);
      return DateTime.now().year - dob.year;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Family Members", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1D2939))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1D2939), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildHouseholdInfo(primaryColor),
          _buildSearchHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : _filteredMembers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredMembers.length,
                        itemBuilder: (context, index) => _buildMemberCard(_filteredMembers[index], primaryColor),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/patient_registration', arguments: {'householdId': widget.householdId, 'householdName': widget.householdName});
          _loadMembers();
        },
        backgroundColor: const Color(0xFF27AE60),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text("ADD MEMBER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHouseholdInfo(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.home_work_rounded, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Household of", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
                Text(widget.householdName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1D2939))),
              ],
            ),
          ),
          Column(
            children: [
              Text(_allMembers.length.toString(), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
              Text("Members", style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF667085))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(16)),
        child: TextField(
          controller: _searchController,
          onChanged: _filterMembers,
          decoration: InputDecoration(
            hintText: "Search member name",
            hintStyle: GoogleFonts.poppins(color: const Color(0xFF98A2B3), fontSize: 14),
            icon: const Icon(Icons.search_rounded, color: Color(0xFF667085)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(Patient member, Color primaryColor) {
    int age = _calculateAge(member.dateOfBirth);
    bool isFemale = member.gender == 'Female';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: member.isHighRisk == 1 ? Colors.redAccent.withValues(alpha: 0.3) : const Color(0xFFEAECF0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isFemale ? const Color(0xFFFFF0F3) : const Color(0xFFEBF5FF),
          child: Icon(isFemale ? Icons.woman_rounded : Icons.man_rounded, color: isFemale ? Colors.pinkAccent : Colors.blueAccent),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(member.firstName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1D2939))),
            ),
            if (member.isHighRisk == 1)
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _buildBadge(member.gender, isFemale ? Colors.pink : Colors.blue),
                const SizedBox(width: 8),
                _buildBadge("$age Years", Colors.grey[700]!),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF667085)),
          onSelected: (val) => _handleAction(val, member, age),
          itemBuilder: (context) => [
            if (age < 5) _buildPopupItem('immunization', Icons.vaccines_rounded, "Immunization"),
            if (isFemale && age >= 15 && age <= 49) _buildPopupItem('anc', Icons.pregnant_woman_rounded, "ANC Visit"),
            if (age >= 30) _buildPopupItem('ncd', Icons.health_and_safety_rounded, "NCD Screening"),
            _buildPopupItem('history', Icons.history_rounded, "View History"),
            const PopupMenuDivider(),
            _buildPopupItem('delete', Icons.delete_outline_rounded, "Remove Member", color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label, {Color? color}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? const Color(0xFF344054)),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: color ?? const Color(0xFF344054))),
        ],
      ),
    );
  }

  void _handleAction(String action, Patient patient, int age) async {
    switch (action) {
      case 'immunization':
        Navigator.push(context, MaterialPageRoute(builder: (context) => ImmunizationFormScreen(patientId: patient.patientId, patientName: patient.firstName)));
        break;
      case 'anc':
        Navigator.pushNamed(context, '/maternal-visit', arguments: {'patientId': patient.patientId, 'patientName': patient.firstName});
        break;
      case 'ncd':
        Navigator.pushNamed(context, '/ncd_screening', arguments: {'patientId': patient.patientId, 'patientName': patient.firstName});
        break;
      case 'history':
        Navigator.push(context, MaterialPageRoute(builder: (context) => VisitHistoryScreen(patientId: patient.patientId, patientName: patient.firstName, visitType: 'General')));
        break;
      case 'delete':
        _showDeleteDialog(patient);
        break;
    }
  }

  void _showDeleteDialog(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Remove Member?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to remove ${patient.firstName}? This action will be synced to the cloud.", style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCEL", style: GoogleFonts.poppins(color: const Color(0xFF667085)))),
          TextButton(
            onPressed: () async {
              final db = await DatabaseHelper().database;
              await db.transaction((txn) async {
                await txn.update('Patient', {'is_deleted': 1}, where: 'patient_id = ?', whereArgs: [patient.patientId]);
                await txn.insert('Sync_Status', SyncStatus(
                  entityType: 'Patient',
                  entityId: patient.patientId,
                  operation: 'DELETE',
                ).toMap());
              });
              Navigator.pop(context);
              _loadMembers();
            },
            child: Text("REMOVE", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No family members found", style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
