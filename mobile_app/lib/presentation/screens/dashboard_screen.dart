import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../generated/app_localizations.dart';
import '../../data/repositories/household_repository.dart';
import '../../data/repositories/patient_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HouseholdRepository _householdRepo = HouseholdRepository();
  final PatientRepository _patientRepo = PatientRepository();

  int _totalHouseholds = 0;
  int _totalPatients = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final houseCount = await _householdRepo.countTotal();
      final patientCount = await _patientRepo.countTotal();
      setState(() {
        _totalHouseholds = houseCount;
        _totalPatients = patientCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const primaryColor = Color(0xFFD35400); // Terracotta
    const secondaryColor = Color(0xFF27AE60); // Healthy Green

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: _buildDrawer(context, primaryColor),
      bottomNavigationBar: _buildBottomNav(context, primaryColor),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: RefreshIndicator(
          onRefresh: _loadStats,
          color: primaryColor,
          child: Column(
            children: [
              // 1. PREMIUM HEADER SECTION
              Container(
                padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33D35400),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person_rounded, size: 35, color: primaryColor),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "नमस्ते, सुनीता ताई",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                "Ward A - Sector 4",
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildHeaderAction(context, Icons.menu_rounded, 0),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Overview Status", null),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(_totalHouseholds.toString(), l10n.totalHouseholds, secondaryColor),
                            _buildStatDivider(),
                            _buildStatItem(_totalPatients.toString(), l10n.totalPatients, primaryColor),
                            _buildStatDivider(),
                            _buildStatItem("05", "Pending", Colors.redAccent),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      _buildSectionHeader(l10n.quickActions, "View All", onActionTap: () => Navigator.pushNamed(context, '/household_list')),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.15,
                        children: [
                          _buildActionCard(
                            context,
                            l10n.householdRegistration,
                            "Manage Houses",
                            Icons.house_rounded,
                            const Color(0xFFEBF5FF),
                            const Color(0xFF2196F3),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/household_list');
                              _loadStats();
                            },
                          ),
                          _buildActionCard(
                            context,
                            l10n.patientRegistration,
                            "Add Member",
                            Icons.person_add_rounded,
                            const Color(0xFFF0FFF4),
                            secondaryColor,
                            onTap: () async {
                              await Navigator.pushNamed(context, '/household_list');
                              _loadStats();
                            },
                          ),
                          _buildActionCard(
                            context,
                            l10n.maternalHealth,
                            "Care & Visits",
                            Icons.pregnant_woman_rounded,
                            const Color(0xFFFFF5F5),
                            Colors.redAccent,
                            badge: "2",
                            onTap: () => Navigator.pushNamed(context, '/maternal_health'),
                          ),
                          _buildActionCard(
                            context,
                            l10n.syncRecords,
                            "Cloud Sync",
                            Icons.cloud_sync_rounded,
                            const Color(0xFFFFF9DB),
                            primaryColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      _buildSectionHeader("Upcoming Visits", null),
                      const SizedBox(height: 16),
                      _buildVisitTile("Janaki Sharma", "Prenatal Checkup", "10:30 AM", "Urgent"),
                      _buildVisitTile("Rahul G.", "Vaccination (Dose 2)", "02:15 PM", "Pending"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? actionText, {VoidCallback? onActionTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD35400),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color bg, Color iconColor, {String? badge, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF2F4F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF344054),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF667085),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF667085),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: const Color(0xFFF2F4F7),
    );
  }

  Widget _buildVisitTile(String name, String task, String time, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F4F7)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF2F4F7),
            child: Text(name[0], style: const TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF344054))),
                Text(task, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFFD35400))),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: status == "Urgent" ? const Color(0xFFFFF5F5) : const Color(0xFFF0FFF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == "Urgent" ? Colors.redAccent : const Color(0xFF27AE60),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(BuildContext context, IconData icon, int count) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Color(0xFF27AE60), shape: BoxShape.circle),
              child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, Color primaryColor) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            accountName: Text("Sunita Tai", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            accountEmail: const Text("ASHA Worker - Ward A"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text("Dashboard"),
            selected: true,
            selectedColor: primaryColor,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_rounded),
            title: const Text("My Patients"),
            onTap: () => Navigator.pushNamed(context, '/household_list'),
          ),
          ListTile(
            leading: const Icon(Icons.sync_rounded),
            title: const Text("Sync Center"),
            onTap: () => Navigator.pushNamed(context, '/sync-center'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text("Settings"),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFF98A2B3),
        type: BottomNavigationBarType.fixed,
        onTap: (index) async {
          if (index == 1) await Navigator.pushNamed(context, '/household_list');
          if (index == 2) await Navigator.pushNamed(context, '/household_registration');
          if (index == 3) await Navigator.pushNamed(context, '/schedule');
          if (index == 4) await Navigator.pushNamed(context, '/settings');
          _loadStats();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: "Patients"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded, size: 32), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
        ],
      ),
    );
  }
}
