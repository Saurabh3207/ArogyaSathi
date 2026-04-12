import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/asha_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AshaRepository _ashaRepo = AshaRepository();
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _ashaRepo.getCurrentProfile();
    setState(() => _profile = profile);
  }

  void _handleLogout() async {
    await _ashaRepo.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings & Profile", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _profile == null 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFFFF4ED),
                  child: Icon(Icons.person_rounded, size: 60, color: primaryColor),
                ),
                const SizedBox(height: 16),
                Text(_profile!['name'], style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                Text("ASHA ID: ${_profile!['asha_id']}", style: GoogleFonts.poppins(color: Colors.grey)),
                
                const SizedBox(height: 32),
                _buildInfoTile(Icons.location_on_rounded, "Village / Ward", _profile!['village']),
                _buildInfoTile(Icons.local_hospital_rounded, "Primary Health Centre", _profile!['phc_name']),
                _buildInfoTile(Icons.phone_rounded, "Phone Number", _profile!['phone']),
                
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: const Text("LOGOUT SESSION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text("App Version 1.0.0", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2F4F7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD35400), size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }
}
