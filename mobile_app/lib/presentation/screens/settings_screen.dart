import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/asha_repository.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _ashaName = "";
  String _ashaId = "";
  String _ashaWard = "";

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ashaName = prefs.getString('asha_name') ?? "Sunita Tai (ASHA)";
      _ashaId = prefs.getString('asha_id') ?? "ASHA-MAR-4501";
      _ashaWard = prefs.getString('asha_ward') ?? "Ward A - Sector 4";
    });
  }

  void _changeLanguage(String code) {
    ArogyaSathiApp.setLocale(context, Locale(code, ''));
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Settings & Profile", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D2939),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROFILE CARD
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_rounded, size: 45, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_ashaName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("ID: $_ashaId", style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(_ashaWard, style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionLabel("APP SETTINGS"),
            const SizedBox(height: 12),
            _buildSettingsItem(Icons.language_rounded, "Language / भाषा", "Change to Marathi/English", onTap: () => _showLanguageDialog()),
            _buildSettingsItem(Icons.notifications_active_rounded, "Notifications", "Toggle alerts & reminders", isSwitch: true),
            _buildSettingsItem(Icons.cloud_sync_rounded, "Sync Settings", "Auto-sync frequency", onTap: () => Navigator.pushNamed(context, '/sync-center')),

            const SizedBox(height: 24),
            _buildSectionLabel("SUPPORT"),
            const SizedBox(height: 12),
            _buildSettingsItem(Icons.help_outline_rounded, "Help Center", "Tutorials & FAQs"),
            _buildSettingsItem(Icons.info_outline_rounded, "About App", "Version 1.0.0 (Stable)"),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: Text("LOGOUT SESSION", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Digital Health Stack • MoHFW",
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF98A2B3), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF667085), letterSpacing: 1.1));
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, {bool isSwitch = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEAECF0))),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFFD35400), size: 22),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF1D2939))),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
        trailing: isSwitch 
          ? Switch(value: true, onChanged: (v) {}, activeColor: const Color(0xFF27AE60))
          : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFD0D5DD)),
      ),
    );
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Language", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
              title: const Text("English"),
              onTap: () { _changeLanguage('en'); Navigator.pop(context); },
            ),
            const Divider(),
            ListTile(
              leading: const Text("🇮🇳", style: TextStyle(fontSize: 24)),
              title: const Text("मराठी (Marathi)"),
              onTap: () { _changeLanguage('mr'); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }
}
