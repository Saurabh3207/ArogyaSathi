import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/household_repository.dart';
import '../../data/models/household_model.dart';

class HouseholdListScreen extends StatefulWidget {
  const HouseholdListScreen({super.key});

  @override
  State<HouseholdListScreen> createState() => _HouseholdListScreenState();
}

class _HouseholdListScreenState extends State<HouseholdListScreen> {
  final HouseholdRepository _repository = HouseholdRepository();
  List<Household> _allHouseholds = [];
  List<Household> _filteredHouseholds = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  int get _totalPopulation => _allHouseholds.fold(0, (sum, item) => sum + (item.totalMembers ?? 0));

  @override
  void initState() {
    super.initState();
    _loadHouseholds();
  }

  Future<void> _loadHouseholds() async {
    setState(() => _isLoading = true);
    try {
      final houses = await _repository.getAll();
      setState(() {
        _allHouseholds = houses;
        _filteredHouseholds = houses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterHouseholds(String query) {
    setState(() {
      _filteredHouseholds = _allHouseholds.where((h) {
        final nameMatch = h.headOfFamilyName.toLowerCase().contains(query.toLowerCase());
        final numberMatch = (h.houseNumber ?? "").toLowerCase().contains(query.toLowerCase());
        return nameMatch || numberMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Village Households", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1D2939))),
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
          _buildSummaryStats(primaryColor),
          _buildSearchHeader(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : _filteredHouseholds.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _filteredHouseholds.length,
                    itemBuilder: (context, index) {
                      return _buildHouseholdCard(_filteredHouseholds[index], primaryColor);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/household_registration');
          _loadHouseholds();
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_home_rounded, color: Colors.white),
        label: const Text("ADD HOUSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryStats(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatBox("Families", _allHouseholds.length.toString()),
          _buildDivider(),
          _buildStatBox("Population", _totalPopulation.toString()),
          _buildDivider(),
          _buildStatBox("Area", "Ward A"),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
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
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterHouseholds,
          decoration: InputDecoration(
            hintText: "Search by Head Name or House No",
            hintStyle: GoogleFonts.poppins(color: const Color(0xFF98A2B3), fontSize: 14),
            icon: const Icon(Icons.search_rounded, color: Color(0xFF667085)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildHouseholdCard(Household house, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.house_rounded, color: primaryColor),
        ),
        title: Text(house.headOfFamilyName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1D2939))),
        subtitle: Text("House No: ${house.houseNumber ?? 'N/A'}", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoRow(Icons.people_alt_rounded, "Members", house.totalMembers.toString()),
                    _buildInfoRow(Icons.location_city_rounded, "Type", house.rationCardType ?? "Pucca"),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/patient_list', arguments: {'householdId': house.householdId, 'householdName': house.headOfFamilyName}),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text("VIEW MEMBERS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF667085)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF667085))),
            Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF344054))),
          ],
        ),
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
          ListTile(leading: const Icon(Icons.people_alt_rounded), title: const Text("Households"), selected: true, selectedColor: primaryColor, onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.pregnant_woman_rounded), title: const Text("Maternal Health"), onTap: () => Navigator.pushReplacementNamed(context, '/maternal_health')),
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
          Icon(Icons.house_siding_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No households found", style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
