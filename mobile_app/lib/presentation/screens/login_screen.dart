import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../generated/app_localizations.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _phoneValid = false;
  bool _passwordValid = false;

  late AnimationController _formController;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _formAnimation = CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    );
    _formController.forward();

    _phoneController.addListener(_validatePhone);
    _passwordController.addListener(_validatePassword);
  }

  void _validatePhone() {
    setState(() {
      _phoneValid = _phoneController.text.length == 10;
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _passwordValid = password.length >= 8 &&
          password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]')) &&
          password.contains(RegExp(r'[0-9]')) &&
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  void dispose() {
    _formController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  void _changeLocale(String localeCode) {
    ArogyaSathiApp.setLocale(context, Locale(localeCode, ''));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = Localizations.localeOf(context).languageCode;
    const primaryColor = Color(0xFFD35400);
    const successColor = Color(0xFF27AE60);
    const neutralColor = Color(0xFF344054);
    const subtitleColor = Color(0xFF667085);
    const borderColor = Color(0xFFD0D5DD);
    const footerColor = Color(0xFF98A2B3);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Language Switch Area
              Align(
                alignment: Alignment.topRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Language",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 140,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          _buildLangToggleItem('en', 'EN', currentLocale, primaryColor),
                          _buildLangToggleItem('mr', 'मराठी', currentLocale, primaryColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Logo & App Title Section
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: Image.asset(
                        'assets/images/asha_vector.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "ArogyaSathi",
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 32,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "आरोग्यसाथी",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: primaryColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              FadeTransition(
                opacity: _formAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: neutralColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Sign in to continue to ArogyaSathi",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Phone Input
                          _buildCustomTextField(
                            controller: _phoneController,
                            label: "Phone Number",
                            hint: "Enter your mobile number",
                            icon: Icons.phone_android_rounded,
                            isValid: _phoneValid,
                            keyboardType: TextInputType.phone,
                            prefixText: "+91 ",
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10)
                            ],
                            primaryColor: primaryColor,
                            successColor: successColor,
                            borderColor: borderColor,
                          ),

                          const SizedBox(height: 16),

                          // Password Input
                          _buildCustomTextField(
                            controller: _passwordController,
                            label: "Password",
                            hint: "••••••••",
                            icon: Icons.lock_outline_rounded,
                            isValid: _passwordValid,
                            obscureText: !_isPasswordVisible,
                            primaryColor: primaryColor,
                            successColor: successColor,
                            borderColor: borderColor,
                            suffixIcon: IconButton(
                              splashRadius: 20,
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: _isPasswordVisible ? primaryColor : subtitleColor,
                                size: 22,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_phoneValid && _passwordValid) ? _login : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          disabledBackgroundColor: const Color(0xFFE5E7EB),
                          elevation: (_phoneValid && _passwordValid) ? 4 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "LOGIN",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: (_phoneValid && _passwordValid) ? Colors.white : const Color(0xFF9CA3AF),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      "Supported by",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: footerColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ministry of Health & Family Welfare",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: footerColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Government of India",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: footerColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangToggleItem(String code, String label, String current, Color primaryColor) {
    bool isSelected = code == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeLocale(code),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : const Color(0xFF344054),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isValid,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? prefixText,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    required Color primaryColor,
    required Color successColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF344054),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: const Color(0xFF98A2B3), fontSize: 16),
            prefixIcon: Icon(
              icon,
              size: 24,
              color: isValid ? successColor : const Color(0xFF667085),
            ),
            prefixText: prefixText,
            prefixStyle: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            suffixIcon: isValid && !obscureText
                ? Icon(Icons.check_circle, color: successColor, size: 22)
                : suffixIcon,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isValid ? successColor : borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isValid ? successColor : primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
