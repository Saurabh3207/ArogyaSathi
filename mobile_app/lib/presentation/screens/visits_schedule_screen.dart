import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/local/database_helper.dart';

class VisitsScheduleScreen extends StatefulWidget {
  const VisitsScheduleScreen({super.key});

  @override
  State<VisitsScheduleScreen> createState() => _VisitsScheduleScreenState();
}

class _VisitsScheduleScreenState extends State<VisitsScheduleScreen> {
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper().database;
      final result = await db.rawQuery('''
        SELECT r.*, p.first_name, h.address 
        FROM Local_Reminder r
        JOIN Patient p ON r.patient_id = p.patient_id
        JOIN Household h ON p.household_id = h.household_id
        WHERE r.is_triggered = 0
        ORDER BY r.scheduled_date ASC
      ''');
      setState(() {
        _reminders = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showPlanVisitDialog() async {
    final db = await DatabaseHelper().database;
    final patients = await db.query('Patient', columns: ['patient_id', 'first_name']);
    
    if (!mounted) return;

    String? selectedPatientId;
    String? selectedType = 'Routine Checkup';
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Plan New Visit", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1D2939))),
              const SizedBox(height: 24),
              
              // Patient Dropdown
              Text("Select Patient", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF344054))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Search patient...", Icons.person_search_rounded),
                items: patients.map((p) => DropdownMenuItem(value: p['patient_id'].toString(), child: Text(p['first_name'].toString()))).toList(),
                onChanged: (val) => setModalState(() => selectedPatientId = val),
              ),
              
              const SizedBox(height: 16),
              
              // Visit Type
              Text("Visit Reason", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF344054))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: _inputDecoration("Select reason", Icons.medical_information_rounded),
                items: ['Routine Checkup', 'ANC Visit', 'Immunization', 'NCD Follow-up', 'PNC Visit']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setModalState(() => selectedType = val),
              ),

              const SizedBox(height: 16),

              // Date Picker
              Text("Scheduled Date", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF344054))),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (picked != null) setModalState(() => selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD0D5DD)), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF667085)),
                      const SizedBox(width: 12),
                      Text(DateFormat('dd MMM, yyyy').format(selectedDate), style: GoogleFonts.poppins(fontSize: 16)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedPatientId == null ? null : () async {
                    await db.insert('Local_Reminder', {
                      'patient_id': selectedPatientId,
                      'reminder_type': selectedType,
                      'scheduled_date': selectedDate.toIso8601String(),
                      'is_triggered': 0,
                    });
                    Navigator.pop(context);
                    _loadSchedule();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD35400), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text("SCHEDULE VISIT", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF667085)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD35400), width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Visit Schedule", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1D2939))),
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
          _buildCalendarStrip(primaryColor),
          const Divider(height: 1),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : _reminders.isEmpty
                ? _buildEmptyState()
                : _buildTimelineList(primaryColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPlanVisitDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: Text("PLAN VISIT", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildCalendarStrip(Color primaryColor) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index - 2));
          bool isSelected = date.day == _selectedDate.day;
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? primaryColor : const Color(0xFFEAECF0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE').format(date), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white70 : const Color(0xFF667085))),
                  Text(date.day.toString(), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF1D2939))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineList(Color primaryColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final item = _reminders[index];
        return _buildTimelineItem(
          item['first_name'],
          item['reminder_type'],
          "10:30 AM", 
          item['address'] ?? 'Ward A, Sector 4',
          index == 0, 
          primaryColor,
        );
      },
    );
  }

  Widget _buildTimelineItem(String name, String task, String time, String location, bool isActive, Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(time, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF667085))),
            Container(
              width: 2,
              height: 120,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [isActive ? primaryColor : const Color(0xFFEAECF0), const Color(0xFFEAECF0)],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isActive ? primaryColor.withValues(alpha: 0.3) : const Color(0xFFEAECF0)),
              boxShadow: isActive ? [BoxShadow(color: primaryColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(task.toUpperCase(), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 0.5)),
                    if (isActive) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF0FFF4), borderRadius: BorderRadius.circular(6)), child: const Text("NOW", style: TextStyle(color: Color(0xFF27AE60), fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1D2939))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF667085)),
                    const SizedBox(width: 4),
                    Text(location, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildActionButton(Icons.call_rounded, "Call", const Color(0xFFF2F4F7), const Color(0xFF344054)),
                    const SizedBox(width: 12),
                    _buildActionButton(Icons.check_circle_rounded, "Done", primaryColor.withValues(alpha: 0.1), primaryColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color bg, Color textCol) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textCol),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: textCol)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), shape: BoxShape.circle),
            child: Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          Text("No visits scheduled", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1D2939))),
          const SizedBox(height: 8),
          Text("Tap the button below to plan a visit.", style: GoogleFonts.poppins(color: const Color(0xFF667085))),
        ],
      ),
    );
  }
}
