import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/database_helper.dart';

class ImmunizationFormScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const ImmunizationFormScreen({super.key, required this.patientId, required this.patientName});

  @override
  State<ImmunizationFormScreen> createState() => _ImmunizationFormScreenState();
}

class _ImmunizationFormScreenState extends State<ImmunizationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedVaccine = 'BCG';
  int _doseNumber = 1;
  DateTime _administeredDate = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _vaccines = [
    'BCG', 'Polio (OPV)', 'Hepatitis B', 'Pentavalent', 'Rotavirus', 'PCV', 'IPV', 'Measles/MR', 'Vitamin A', 'DPT Booster'
  ];

  Future<void> _saveImmunization() async {
    setState(() => _isSubmitting = true);
    try {
      final db = await DatabaseHelper().database;
      final recordId = const Uuid().v4();
      final timestamp = DateTime.now().toIso8601String();

      await db.transaction((txn) async {
        await txn.insert('Immunization_Record', {
          'immunization_id': recordId,
          'patient_id': widget.patientId,
          'vaccine_name': _selectedVaccine,
          'dose_number': _doseNumber,
          'date_administered': _administeredDate.toIso8601String(),
          'next_due_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(), // Mock logic
          'last_modified_at': timestamp,
          'is_deleted': 0,
        });

        await txn.insert('Sync_Status', {
          'sync_id': const Uuid().v4(),
          'entity_type': 'Immunization_Record',
          'entity_id': recordId,
          'operation': 'CREATE',
          'sync_status': 'PENDING',
        });
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vaccination recorded successfully")));
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      appBar: AppBar(
        title: Text("Child Immunization", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
              Text("Child: ${widget.patientName}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              
              _label("Select Vaccine"),
              DropdownButtonFormField<String>(
                value: _selectedVaccine,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: _vaccines.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => _selectedVaccine = v!),
              ),
              
              const SizedBox(height: 20),
              _label("Dose Number"),
              Row(
                children: [1, 2, 3, 4, 5].map((d) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text("Dose $d"),
                    selected: _doseNumber == d,
                    onSelected: (s) => setState(() => _doseNumber = d),
                    selectedColor: primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(color: _doseNumber == d ? primaryColor : Colors.black),
                  ),
                )).toList(),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _saveImmunization,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 56)),
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("RECORD VACCINATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blueGrey)));
}
