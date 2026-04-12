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
  final _randomSugarController = TextEditingController();
  final _fastingSugarController = TextEditingController();

  // Symptoms
  bool _hasExcessiveThirst = false;
  bool _hasFrequentUrination = false;
  bool _hasBlurredVision = false;
  bool _isSmoker = false;

  Future<void> _saveScreening() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final db = await DatabaseHelper().database;
      final screeningId = const Uuid().v4();
      final timestamp = DateTime.now().toIso8601String();

      // Simple Risk Assessment Logic
      String bpRisk = (int.tryParse(_systolicController.text) ?? 0) > 140 ? 'High' : 'Normal';
      String sugarRisk = (int.tryParse(_randomSugarController.text) ?? 0) > 200 ? 'High' : 'Normal';

      await db.transaction((txn) async {
        await txn.insert('NCD_Screening', {
          'screening_id': screeningId,
          'patient_id': widget.patientId,
          'screening_date': timestamp,
          'hypertension_risk': bpRisk,
          'diabetes_risk': sugarRisk,
          'cancer_screening_status': 'Not Done',
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
      builder: (context) => AlertDialog(
        title: const Text("Screening Saved"),
        content: const Text("The NCD screening data has been recorded and queued for sync."),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          }, child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      appBar: AppBar(
        title: Text("NCD Screening (30+)", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Patient: ${widget.patientName}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              
              _sectionTitle("Blood Pressure (mmHg)"),
              Row(
                children: [
                  Expanded(child: _inputField("Systolic", _systolicController)),
                  const SizedBox(width: 16),
                  Expanded(child: _inputField("Diastolic", _diastolicController)),
                ],
              ),
              
              const SizedBox(height: 24),
              _sectionTitle("Blood Sugar (mg/dL)"),
              _inputField("Random Blood Sugar", _randomSugarController),
              const SizedBox(height: 12),
              _inputField("Fasting Blood Sugar (Optional)", _fastingSugarController),

              const SizedBox(height: 24),
              _sectionTitle("Common Symptoms"),
              CheckboxListTile(title: const Text("Excessive Thirst"), value: _hasExcessiveThirst, onChanged: (v) => setState(() => _hasExcessiveThirst = v!)),
              CheckboxListTile(title: const Text("Frequent Urination"), value: _hasFrequentUrination, onChanged: (v) => setState(() => _hasFrequentUrination = v!)),
              CheckboxListTile(title: const Text("Blurred Vision"), value: _hasBlurredVision, onChanged: (v) => setState(() => _hasBlurredVision = v!)),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _saveScreening,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 56)),
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("SUBMIT SCREENING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blueGrey)));

  Widget _inputField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
    );
  }
}
