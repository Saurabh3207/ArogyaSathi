import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/local/database_helper.dart';

class VisitHistoryScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String visitType; // 'ANC' or 'NCD'

  const VisitHistoryScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.visitType,
  });

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper().database;
      
      if (widget.visitType == 'ANC') {
        final result = await db.query(
          'Health_Visit',
          where: 'patient_id = ? AND is_deleted = 0',
          whereArgs: [widget.patientId],
          orderBy: 'visit_date DESC',
        );
        setState(() {
          _history = result;
          _isLoading = false;
        });
      } else {
        final result = await db.query(
          'NCD_Screening',
          where: 'patient_id = ? AND is_deleted = 0',
          whereArgs: [widget.patientId],
          orderBy: 'screening_date DESC',
        );
        setState(() {
          _history = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("${widget.visitType} History", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildPatientHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : _history.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return widget.visitType == 'ANC' 
                            ? _buildANCVisitCard(_history[index])
                            : _buildNCDVisitCard(_history[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      color: const Color(0xFFD35400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.patientName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Patient ID: ${widget.patientId.substring(0, 8)}...", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildANCVisitCard(Map<String, dynamic> visit) {
    final date = DateTime.parse(visit['visit_date']);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('dd MMM yyyy').format(date), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFFD35400))),
              Text(visit['visit_type'] ?? 'Routine', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoCol("Weight", "${visit['maternal_weight']} kg"),
              _infoCol("BP", visit['blood_pressure'] ?? 'N/A'),
              _infoCol("HB", "${visit['hb_level'] ?? 'N/A'}"),
            ],
          ),
          if (visit['health_observation'] != null && visit['health_observation'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text("Notes: ${visit['health_observation']}", style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }

  Widget _buildNCDVisitCard(Map<String, dynamic> screening) {
    final date = DateTime.parse(screening['screening_date']);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('dd MMM yyyy').format(date), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoCol("BP Risk", screening['hypertension_risk'], color: screening['hypertension_risk'] == 'High' ? Colors.red : Colors.green),
              _infoCol("Sugar Risk", screening['diabetes_risk'], color: screening['diabetes_risk'] == 'High' ? Colors.red : Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCol(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: color ?? const Color(0xFF344054))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No history found", style: GoogleFonts.poppins(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
