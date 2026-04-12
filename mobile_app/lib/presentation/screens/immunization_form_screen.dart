import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../data/local/database_helper.dart';

import '../../data/models/sync_status_model.dart';
import '../../generated/app_localizations.dart';

class ImmunizationFormScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const ImmunizationFormScreen({super.key, required this.patientId, required this.patientName});

  @override
  State<ImmunizationFormScreen> createState() => _ImmunizationFormScreenState();
}

class _ImmunizationFormScreenState extends State<ImmunizationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  List<Map<String, dynamic>> _records = [];
  
  final List<Map<String, String>> _vaccineSchedule = [
    {'name': 'BCG', 'age': 'At Birth'},
    {'name': 'Hepatitis B-0', 'age': 'At Birth'},
    {'name': 'OPV-0', 'age': 'At Birth'},
    {'name': 'OPV-1, 2, 3', 'age': '6, 10, 14 Weeks'},
    {'name': 'Pentavalent-1, 2, 3', 'age': '6, 10, 14 Weeks'},
    {'name': 'Rotavirus', 'age': '6, 10, 14 Weeks'},
    {'name': 'PCV', 'age': '6, 14 Weeks & 9 Months'},
    {'name': 'MR / Measles', 'age': '9-12 Months'},
    {'name': 'Vitamin A', 'age': '9 Months'},
    {'name': 'DPT Booster-1', 'age': '16-24 Months'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper().database;
      final result = await db.query('Immunization_Record', where: 'patient_id = ?', whereArgs: [widget.patientId]);
      setState(() {
        _records = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAdministered(String vaccineName) async {
    try {
      final db = await DatabaseHelper().database;
      final recordId = const Uuid().v4();
      final timestamp = DateTime.now().toIso8601String();

      await db.transaction((txn) async {
        await txn.insert('Immunization_Record', {
          'immunization_id': recordId,
          'patient_id': widget.patientId,
          'vaccine_name': vaccineName,
          'dose_number': 1,
          'date_administered': timestamp,
          'next_due_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'last_modified_at': timestamp,
          'is_deleted': 0,
        });

        await txn.insert('Sync_Status', SyncStatus(
          entityType: 'Immunization_Record',
          entityId: recordId,
          operation: 'CREATE',
        ).toMap());
      });

      _loadRecords();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$vaccineName recorded successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.childImmunization, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1D2939))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1D2939), size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryColor))
        : Column(
            children: [
              _buildChildHeader(primaryColor),
              _buildStatsRow(l10n),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _vaccineSchedule.length,
                  itemBuilder: (context, index) {
                    final vaccine = _vaccineSchedule[index];
                    final isDone = _records.any((r) => r['vaccine_name'] == vaccine['name']);
                    return _buildVaccineCard(vaccine['name']!, vaccine['age']!, isDone, primaryColor, l10n);
                  },
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildChildHeader(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: primaryColor.withValues(alpha: 0.05),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.child_care_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.patientName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1D2939))),
                Text("Immunization Status: Partially Vaccinated", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statItem(l10n.totalDue, "03", Colors.orange),
          _statItem(l10n.completed, "${_records.length}", const Color(0xFF27AE60)),
          _statItem(l10n.overdue, "01", Colors.redAccent),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF667085))),
      ],
    );
  }

  Widget _buildVaccineCard(String name, String age, bool isDone, Color primaryColor, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDone ? const Color(0xFFD1FAE5) : const Color(0xFFEAECF0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isDone ? const Color(0xFFD1FAE5) : const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
            child: Icon(isDone ? Icons.check_circle_rounded : Icons.vaccines_rounded, color: isDone ? const Color(0xFF10B981) : const Color(0xFF667085)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1D2939))),
                Text("${l10n.age}: $age", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
              ],
            ),
          ),
          if (!isDone) 
            TextButton(
              onPressed: () => _markAdministered(name),
              style: TextButton.styleFrom(backgroundColor: primaryColor.withValues(alpha: 0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(l10n.administer, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
            )
          else 
            Text(l10n.completed.toUpperCase(), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
        ],
      ),
    );
  }
}
