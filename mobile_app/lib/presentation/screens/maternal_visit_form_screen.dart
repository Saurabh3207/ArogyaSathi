import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/database_helper.dart';
import '../../data/repositories/asha_repository.dart';

import '../../data/models/sync_status_model.dart';

class MaternalVisitFormScreen extends StatefulWidget {
  final String patientName;
  final String? patientId; // Added patientId
  const MaternalVisitFormScreen({super.key, required this.patientName, this.patientId});

  @override
  State<MaternalVisitFormScreen> createState() => _MaternalVisitFormScreenState();
}

class _MaternalVisitFormScreenState extends State<MaternalVisitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _weightController = TextEditingController();
  final _hbController = TextEditingController();
  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();
  final _fundalHeightController = TextEditingController();
  final _fetalHeartRateController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedVisitType = 'Routine';
  bool _ifaDistributed = false;
  bool _calciumDistributed = false;
  final AshaRepository _ashaRepo = AshaRepository();

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Record ANC Visit", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientHeader(),
              const SizedBox(height: 24),
              _buildSectionTitle("Physical Vitals"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInputField("Weight (kg)", _weightController, Icons.monitor_weight_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInputField("HB (g/dL)", _hbController, Icons.bloodtype_outlined)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInputField("BP Systolic", _bpSystolicController, Icons.speed_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInputField("BP Diastolic", _bpDiastolicController, Icons.speed_outlined)),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Fetal Examination"),
              const SizedBox(height: 16),
              _buildInputField("Fundal Height (cm)", _fundalHeightController, Icons.straighten_rounded),
              const SizedBox(height: 16),
              _buildInputField("Fetal Heart Rate (bpm)", _fetalHeartRateController, Icons.favorite_rounded),
              const SizedBox(height: 24),
              _buildSectionTitle("Supplements Provided"),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text("IFA Tablets (Iron)"),
                value: _ifaDistributed,
                onChanged: (v) => setState(() => _ifaDistributed = v!),
                activeColor: primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text("Calcium Tablets"),
                value: _calciumDistributed,
                onChanged: (v) => setState(() => _calciumDistributed = v!),
                activeColor: primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Clinical Notes"),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter any observations...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitVisit,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: Text("SAVE VISIT RECORD", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFFFF5F5), child: Icon(Icons.pregnant_woman_rounded, color: Colors.redAccent)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.patientName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Visit Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF344054)));
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {String? suffix}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _submitVisit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final db = await DatabaseHelper().database;
      final profile = await _ashaRepo.getCurrentProfile();
      final ashaId = profile?['asha_id'] ?? 'OFFLINE-USER';
      
      final visitId = const Uuid().v4();
      final timestamp = DateTime.now().toIso8601String();

      await db.transaction((txn) async {
        // 1. Insert into Health_Visit
        await txn.insert('Health_Visit', {
          'visit_id': visitId,
          'patient_id': widget.patientId ?? 'MOCK-PATIENT-ID',
          'asha_id': ashaId,
          'visit_date': timestamp,
          'visit_type': _selectedVisitType ?? 'ANC',
          'health_observation': _notesController.text,
          'maternal_weight': double.tryParse(_weightController.text) ?? 0.0,
          'blood_pressure': "${_bpSystolicController.text}/${_bpDiastolicController.text}",
          'hb_level': double.tryParse(_hbController.text) ?? 0.0, // Added hb_level
          'supplements_given': "${_ifaDistributed ? 'IFA,' : ''}${_calciumDistributed ? 'Calcium' : ''}",
          'last_modified_at': timestamp,
          'is_deleted': 0,
        });

        // 2. Track in Sync_Status
        await txn.insert('Sync_Status', SyncStatus(
          entityType: 'Health_Visit',
          entityId: visitId,
          operation: 'CREATE',
        ).toMap());
      });

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save visit: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  bool _isSubmitting = false;

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60), size: 60),
            const SizedBox(height: 16),
            const Text("Visit Recorded", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text("Health visit has been successfully saved to the patient history.", textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
