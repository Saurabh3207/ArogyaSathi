import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/patient_repository.dart';
import '../../data/models/patient_model.dart';
import 'maternal_visit_form_screen.dart';
import 'visit_history_screen.dart';

class MaternalHealthScreen extends StatefulWidget {
  const MaternalHealthScreen({super.key});

  @override
  State<MaternalHealthScreen> createState() => _MaternalHealthScreenState();
}

class _MaternalHealthScreenState extends State<MaternalHealthScreen> {
  final PatientRepository _repository = PatientRepository();
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMaternalPatients();
  }

  Future<void> _loadMaternalPatients() async {
    setState(() => _isLoading = true);
    try {
      final all = await _repository.getAll();
      // Improved logic: Filter for Female + High Risk or specific age range (15-49)
      // For now, keeping Female as base filter but adding visual cues
      setState(() {
        _patients = all.where((p) => p.gender == 'Female').toList();
        _filteredPatients = _patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterPatients(String query) {
    setState(() {
      _filteredPatients = _patients
          .where((p) => p.firstName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Maternal Health", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1D2939))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF1D2939)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(primaryColor),
      body: Column(
        children: [
          _buildSummaryHeader(primaryColor),
          _buildSearchHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : _filteredPatients.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          return _buildMaternalCard(_filteredPatients[index], primaryColor);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/household_list'),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("NEW ANC REGISTRATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildSummaryHeader(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatBox("Total ANC", _patients.length.toString()),
          _buildDivider(),
          _buildStatBox("High Risk", _patients.where((p) => p.isHighRisk == 1).length.toString()),
          _buildDivider(),
          _buildStatBox("Visits Due", "03"),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.white24);
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(16)),
        child: TextField(
          controller: _searchController,
          onChanged: _filterPatients,
          decoration: InputDecoration(
            hintText: "Search Mother's Name",
            hintStyle: GoogleFonts.poppins(color: const Color(0xFF98A2B3), fontSize: 14),
            icon: const Icon(Icons.search_rounded, color: Color(0xFF667085)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildMaternalCard(Patient patient, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFFFF0F3),
                  child: const Icon(Icons.pregnant_woman_rounded, color: Colors.pinkAccent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.firstName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1D2939))),
                      Text("ANC No: 2024/${patient.patientId.substring(0,4).toUpperCase()}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
                    ],
                  ),
                ),
                if (patient.isHighRisk == 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent.withOpacity(0.2))),
                    child: Text("HIGH RISK", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF9FAFB),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardInfo("Last Visit", "12 Mar"),
                _buildCardInfo("EDD", "24 Oct"),
                _buildCardInfo("Status", "Active"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VisitHistoryScreen(patientId: patient.patientId, patientName: patient.firstName, visitType: 'ANC'))),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("HISTORY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF344054))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MaternalVisitFormScreen(patientName: patient.firstName, patientId: patient.patientId))),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                    child: const Text("RECORD VISIT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF667085))),
        Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF344054))),
      ],
    );
  }

  Widget _buildDrawer(Color primaryColor) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            accountName: Text("Sunita Tai", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            accountEmail: const Text("ASHA Worker - Ward A"),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 40)),
          ),
          ListTile(leading: const Icon(Icons.dashboard_rounded), title: const Text("Dashboard"), onTap: () => Navigator.pushReplacementNamed(context, '/dashboard')),
          ListTile(leading: const Icon(Icons.pregnant_woman_rounded), title: const Text("Maternal Health"), selected: true, selectedColor: primaryColor, onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.sync_rounded), title: const Text("Sync Center"), onTap: () => Navigator.pushNamed(context, '/sync-center')),
          const Spacer(),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout_rounded, color: Colors.red), title: const Text("Logout", style: TextStyle(color: Colors.red)), onTap: () => Navigator.pushReplacementNamed(context, '/login')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pregnant_woman_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No maternal records found", style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
