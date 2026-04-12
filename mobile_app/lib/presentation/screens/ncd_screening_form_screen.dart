import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/database_helper.dart';

class NCDScreeningFormScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const NCDScreeningFormScreen({super.key, required this.patientId, required this.patientName});

  @override
  State<NCDScreeningFormScreen> createState() => _NCDScreeningFormScreenState();
}

class _NCDScreeningFormScreenState extends State<NCDScreeningFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _sugarController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Symptoms
  final List<String> _symptoms = ["Excessive Thirst", "Frequent Urination", "Blurred Vision", "Slow Healing Wounds", "Chest Pain"];
  final Set<String> _selectedSymptoms = {};

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _sugarController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String _calculateBMIRisk() {
    double? h = double.tryParse(_heightController.text);
    double? w = double.tryParse(_weightController.text);
    if (h == null || w == null || h == 0) return "N/A";
    double bmi = w / ((h / 100) * (h / 100));
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  Future<void> _saveScreening() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final db = await DatabaseHelper().database;
      final screeningId = const Uuid().v4();
      final timestamp = DateTime.now().toIso8601String();

      String bpRisk = (int.tryParse(_systolicController.text) ?? 0) > 140 ? 'High' : 'Normal';
      String sugarRisk = (int.tryParse(_sugarController.text) ?? 0) > 200 ? 'High' : 'Normal';

      await db.transaction((txn) async {
        await txn.insert('NCD_Screening', {
          'screening_id': screeningId,
          'patient_id': widget.patientId,
          'screening_date': timestamp,
          'hypertension_risk': bpRisk,
          'diabetes_risk': sugarRisk,
          'cancer_screening_status': 'Pending',
          'last_modified_at': timestamp,
          'is_deleted': 0,
        });
        await txn.insert('Sync_Status', {
          'sync_id': const Uuid().v4(),
          'entity_type': 'NCD_Screening',
          'entity_id': screeningId,
          'operation': 'CREATE',
          'sync_status': 'PENDING',
        });
      });
      _showSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60), size: 60),
            const SizedBox(height: 16),
            Text("Screening Recorded", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text("NCD screening for ${widget.patientName} has been saved locally.", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD35400), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("NCD Screening", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1D2939))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1D2939), size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientBanner(primaryColor),
              const SizedBox(height: 24),
              _sectionHeader("Vital Statistics", Icons.monitor_heart_rounded),
              Row(
                children: [
                  Expanded(child: _buildCustomField("Systolic", "120", _systolicController, suffix: "mmHg")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCustomField("Diastolic", "80", _diastolicController, suffix: "mmHg")),
                ],
              ),
              const SizedBox(height: 16),
              _buildCustomField("Blood Sugar (RBS)", "140", _sugarController, suffix: "mg/dL"),
              const SizedBox(height: 24),
              _sectionHeader("Physical Markers", Icons.accessibility_new_rounded),
              Row(
                children: [
                  Expanded(child: _buildCustomField("Height", "cm", _heightController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCustomField("Weight", "kg", _weightController)),
                ],
              ),
              const SizedBox(height: 24),
              _sectionHeader("Risk Indicators", Icons.warning_amber_rounded),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptoms.map((s) => FilterChip(
                  label: Text(s, style: GoogleFonts.poppins(fontSize: 12, color: _selectedSymptoms.contains(s) ? Colors.white : const Color(0xFF344054))),
                  selected: _selectedSymptoms.contains(s),
                  onSelected: (v) => setState(() => v ? _selectedSymptoms.add(s) : _selectedSymptoms.remove(s)),
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: const Color(0xFFF2F4F7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
                )).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveScreening,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("SUBMIT SCREENING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientBanner(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor.withOpacity(0.1))),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: primaryColor, child: const Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.patientName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1D2939))),
              Text("Screening Age: 30+ Years", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF344054)),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF344054))),
        ],
      ),
    );
  }

  Widget _buildCustomField(String label, String hint, TextEditingController controller, {String? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF667085))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            suffixStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEAECF0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD35400), width: 1.5)),
          ),
        ),
      ],
    );
  }
}
