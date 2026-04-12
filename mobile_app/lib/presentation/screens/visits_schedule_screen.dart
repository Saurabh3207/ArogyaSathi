import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/local/database_helper.dart';

class VisitsScheduleScreen extends StatefulWidget {
  const VisitsScheduleScreen({super.key});

  @override
  State<VisitsScheduleScreen> createState() => _VisitsScheduleScreenState();
}

class _VisitsScheduleScreenState extends State<VisitsScheduleScreen> {
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Visit Schedule", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
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
          _buildCalendarStrip(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : _reminders.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadSchedule,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _reminders.length,
                      itemBuilder: (context, index) {
                        final item = _reminders[index];
                        return _buildVisitCard(
                          item['first_name'], 
                          item['reminder_type'], 
                          item['address'] ?? 'No Address Provided', 
                          item['reminder_type'].toString().contains('Urgent')
                        );
                      },
                    ),
                  ),
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
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No visits scheduled", style: GoogleFonts.poppins(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDateItem("Mon", "12"),
          _buildDateItem("Tue", "13"),
          _buildDateItem("Wed", "14", isSelected: true),
          _buildDateItem("Thu", "15"),
          _buildDateItem("Fri", "16"),
          _buildDateItem("Sat", "17"),
        ],
      ),
    );
  }

  Widget _buildDateItem(String day, String date, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD35400) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(day, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(date, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF344054), fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVisitCard(String name, String type, String address, bool isUrgent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUrgent ? Colors.redAccent.withOpacity(0.3) : const Color(0xFFEAECF0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.person_rounded, color: isUrgent ? Colors.redAccent : const Color(0xFFD35400)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(type, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 10, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(address, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
