import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/household_model.dart';
import '../../data/models/patient_model.dart';
import '../../data/repositories/household_repository.dart';
import '../../data/repositories/patient_repository.dart';
import 'package:uuid/uuid.dart';

class HouseholdRegistrationScreen extends StatefulWidget {
  const HouseholdRegistrationScreen({super.key});

  @override
  State<HouseholdRegistrationScreen> createState() => _HouseholdRegistrationScreenState();
}

class _HouseholdRegistrationScreenState extends State<HouseholdRegistrationScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final HouseholdRepository _repository = HouseholdRepository();
  final PatientRepository _patientRepository = PatientRepository();
  bool _isSubmitting = false;

  // Form Controllers
  final _houseNoController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _headNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  
  String? _selectedLocality;
  String? _selectedGender;
  String? _selectedCategory;
  String? _selectedHouseType;
  bool _hasToilet = false;

  @override
  void dispose() {
    _houseNoController.dispose();
    _landmarkController.dispose();
    _headNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final household = Household(
        ashaId: "ASHA-001", // TODO: Get from Auth/Session
        houseNumber: _houseNoController.text,
        headOfFamilyName: _headNameController.text,
        address: "${_landmarkController.text}, ${_selectedLocality ?? ''}",
        lastModifiedAt: DateTime.now().toIso8601String(),
        // Additional fields can be mapped here or stored in a JSON column if needed
      );

      await _repository.insert(household);

      // 2. Automatically register the Head as the first Patient (Member)
      final headAsPatient = Patient(
        householdId: household.householdId,
        firstName: _headNameController.text,
        dateOfBirth: "01/01/1980", // Mock for now, usually heads are adults
        gender: _selectedGender ?? 'Male',
        citizenCategory: _selectedCategory ?? 'General',
        migrationStatus: 'Resident',
        lastModifiedAt: DateTime.now().toIso8601String(),
      );
      await _patientRepository.insert(headAsPatient);

      _showSuccessDialog(household.householdId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving household: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showSuccessDialog(String id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60), size: 80),
            const SizedBox(height: 16),
            Text(
              "Registration Successful",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Household ID: ${id.substring(0, 8).toUpperCase()} has been created.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: const Color(0xFF667085)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Back to Dashboard"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD35400);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          "New Household",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
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
          // Stepper Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0, "Basic"),
                _buildStepConnector(0),
                _buildStepIndicator(1, "Head"),
                _buildStepConnector(1),
                _buildStepIndicator(2, "Social"),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: _buildCurrentStepContent(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(primaryColor),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCurrent ? Colors.white : (isActive ? Colors.white.withOpacity(0.4) : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              (step + 1).toString(),
              style: GoogleFonts.poppins(
                color: isCurrent ? const Color(0xFFD35400) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
      color: _currentStep > step ? Colors.white : Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return Container();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Location Details", "Specify where the house is located"),
        const SizedBox(height: 24),
        _buildInputField("House Number", "e.g. 45-B/2", _houseNoController, Icons.home_work_rounded),
        const SizedBox(height: 16),
        _buildInputField("Landmark", "e.g. Near Hanuman Temple", _landmarkController, Icons.location_on_rounded),
        const SizedBox(height: 16),
        _buildDropdownField("Locality / Ward", ["Ward A", "Ward B", "Ward C", "Ward D"], (val) => setState(() => _selectedLocality = val)),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Family Head", "Details of the head of the household"),
        const SizedBox(height: 24),
        _buildInputField("Full Name", "Enter name of head", _headNameController, Icons.person_rounded),
        const SizedBox(height: 16),
        _buildInputField("Phone Number", "10-digit mobile number", _phoneController, Icons.phone_android_rounded, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildInputField("Age", "00", _ageController, Icons.calendar_month_rounded, keyboardType: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdownField("Gender", ["Male", "Female", "Other"], (val) => setState(() => _selectedGender = val))),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Socio-Economic", "Additional information for records"),
        const SizedBox(height: 24),
        _buildDropdownField("Category", ["General", "OBC", "SC", "ST"], (val) => setState(() => _selectedCategory = val)),
        const SizedBox(height: 16),
        _buildDropdownField("House Type", ["Kutcha", "Pucca", "Semi-Pucca"], (val) => setState(() => _selectedHouseType = val)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD0D5DD)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.wc_rounded, color: Color(0xFF667085), size: 20),
                  const SizedBox(width: 12),
                  Text("Functional Toilet", style: GoogleFonts.poppins(color: const Color(0xFF344054))),
                ],
              ),
              Switch(
                value: _hasToilet,
                onChanged: (val) => setState(() => _hasToilet = val),
                activeColor: const Color(0xFF27AE60),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50)),
        ),
        Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF667085)),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF344054))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: const Color(0xFF98A2B3), fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF667085)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD35400), width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF344054))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD35400), width: 2)),
          ),
          hint: Text("Select $label", style: GoogleFonts.poppins(color: const Color(0xFF98A2B3), fontSize: 14)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 16)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildBottomBar(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  side: const BorderSide(color: Color(0xFFD0D5DD)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text("BACK", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF344054))),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 56),
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isSubmitting 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    _currentStep == 2 ? "SUBMIT" : "CONTINUE",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
