import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/patient_model.dart';
import '../../data/repositories/patient_repository.dart';
import 'package:uuid/uuid.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final PatientRepository _repository = PatientRepository();
  bool _isSubmitting = false;

  String? _passedHouseholdId;
  String? _passedHouseholdName;

  // Controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadhaarController = TextEditingController();
  
  // Form Values
  String? _selectedGender;
  String? _selectedCategory;
  String? _selectedMaritalStatus;
  String? _selectedMigrationStatus = 'Resident';
  String? _selectedContraceptive;
  bool _isHighRisk = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _passedHouseholdId = args['householdId'];
      _passedHouseholdName = args['householdName'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD35400),
              onPrimary: Colors.white,
              onSurface: Color(0xFF344054),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  int? _calculateAge() {
    if (_dobController.text.isEmpty) return null;
    try {
      DateTime dob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      DateTime today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passedHouseholdId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No household selected for this patient.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final patient = Patient(
        householdId: _passedHouseholdId!,
        firstName: _nameController.text,
        dateOfBirth: _dobController.text,
        gender: _selectedGender ?? 'Other',
        citizenCategory: _selectedCategory ?? 'General',
        maritalStatus: _selectedMaritalStatus,
        contraceptiveMethod: _selectedContraceptive,
        migrationStatus: _selectedMigrationStatus ?? 'Resident',
        isHighRisk: _isHighRisk ? 1 : 0,
        lastModifiedAt: DateTime.now().toIso8601String(),
      );

      await _repository.insert(patient);
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving patient: $e")),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFF0FFF4), shape: BoxShape.circle),
              child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF27AE60), size: 60),
            ),
            const SizedBox(height: 20),
            Text("Member Registered", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF1D2939))),
            const SizedBox(height: 8),
            Text(
              "${_nameController.text} has been successfully added to ${_passedHouseholdName ?? 'the system'}.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: const Color(0xFF667085), fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to Household List
                },
                child: Text("Return to List", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
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
        title: Text("Add Family Member", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
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
          if (_passedHouseholdName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              color: primaryColor.withValues(alpha: 0.9),
              child: Text(
                "Registering for: $_passedHouseholdName",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          _buildStepperHeader(primaryColor),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(key: _formKey, child: _buildStepContent()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(primaryColor),
    );
  }

  Widget _buildStepperHeader(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: primaryColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIcon(0, Icons.person_outline_rounded, "Personal"),
          _buildStepLine(0),
          _buildStepIcon(1, Icons.health_and_safety_outlined, "Health"),
          _buildStepLine(1),
          _buildStepIcon(2, Icons.assignment_outlined, "Social"),
        ],
      ),
    );
  }

  Widget _buildStepIcon(int step, IconData icon, String label) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCurrent ? Colors.white : (isActive ? Colors.white.withValues(alpha: 0.24) : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(icon, color: isCurrent ? const Color(0xFFD35400) : Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 18),
      color: _currentStep > step ? Colors.white : Colors.white.withValues(alpha: 0.24),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalDetails();
      case 1:
        return _buildHealthDetails();
      case 2:
        return _buildSocialDetails();
      default:
        return Container();
    }
  }

  Widget _buildPersonalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Basic Information", "Member's identification details"),
        const SizedBox(height: 24),
        _buildTextField("Full Name", "Enter first and last name", _nameController, Icons.badge_outlined),
        const SizedBox(height: 16),
        _buildDateField("Date of Birth", "Select DOB", _dobController, Icons.calendar_today_outlined),
        const SizedBox(height: 16),
        _buildDropdown("Gender", ["Male", "Female", "Other"], _selectedGender, (val) => setState(() => _selectedGender = val), Icons.transgender_rounded),
        const SizedBox(height: 16),
        _buildTextField("Aadhaar Number", "12-digit number (Optional)", _aadhaarController, Icons.fingerprint_rounded, keyboardType: TextInputType.number, maxLength: 12),
      ],
    );
  }

  Widget _buildHealthDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Health & Risk", "Risk identification and care needs"),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHighRisk ? const Color(0xFFFFF5F5) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isHighRisk ? Colors.redAccent : const Color(0xFFD0D5DD)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _isHighRisk ? Colors.redAccent.withValues(alpha: 0.1) : const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.warning_amber_rounded, color: _isHighRisk ? Colors.redAccent : const Color(0xFF667085)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("High Risk Case", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF344054))),
                    Text("Does this patient need extra care?", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF667085))),
                  ],
                ),
              ),
              Switch(
                value: _isHighRisk,
                onChanged: (val) => setState(() => _isHighRisk = val),
                activeColor: Colors.redAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Social Status", "Community and residential details"),
        const SizedBox(height: 24),
        _buildDropdown("Citizen Category", ["General", "OBC", "SC", "ST"], _selectedCategory, (val) => setState(() => _selectedCategory = val), Icons.groups_outlined),
        const SizedBox(height: 16),
        _buildDropdown("Marital Status", ["Unmarried", "Married", "Widowed", "Divorced"], _selectedMaritalStatus, (val) => setState(() => _selectedMaritalStatus = val), Icons.favorite_outline_rounded),
        const SizedBox(height: 16),
        _buildDropdown("Migration Status", ["Resident", "Migrant (In)", "Migrant (Out)"], _selectedMigrationStatus, (val) => setState(() => _selectedMigrationStatus = val), Icons.route_outlined),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1D2939))),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF667085))),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int? maxLength}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF344054))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: GoogleFonts.poppins(fontSize: 16),
          validator: (value) {
            if (label != "Aadhaar Number" && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            if (label == "Aadhaar Number" && value != null && value.isNotEmpty && !RegExp(r'^[0-9]{12}$').hasMatch(value)) {
              return 'Aadhaar must be 12 digits';
            }
            return null;
          },
          decoration: _inputDecoration(hint, icon),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, String hint, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF344054))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context),
          style: GoogleFonts.poppins(fontSize: 16),
          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
          decoration: _inputDecoration(hint, icon).copyWith(suffixIcon: const Icon(Icons.calendar_month_rounded, size: 20)),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF344054))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
          decoration: _inputDecoration("Select $label", icon),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 16)))).toList(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: const Color(0xFF98A2B3), fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF667085)),
      filled: true,
      fillColor: Colors.white,
      counterText: "",
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD35400), width: 2)),
    );
  }

  Widget _buildBottomBar(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text("BACK", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF344054))),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 56), backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isSubmitting 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_currentStep == 2 ? "SUBMIT MEMBER" : "CONTINUE", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1)),
            ),
          ),
        ],
      ),
    );
  }
}
