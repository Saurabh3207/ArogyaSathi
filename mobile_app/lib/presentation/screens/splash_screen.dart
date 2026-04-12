import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    // Hide status bar for full-screen splash image effect
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _navigateToNext();
  }

  _navigateToNext() async {
    // Stage 1: Show only the image for 1.5 seconds (Faster)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() {
        _showLoader = true;
      });
    }

    // Stage 2: Check Session
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getString('asha_id') != null;

    // Wait for remaining duration
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      // Re-enable status bar before leaving
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD35400),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/splash-scren.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Subtle Loading Indicator - Appears after delay
          if (_showLoader)
            Positioned(
              bottom: 80,
              left: 50,
              right: 50,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        minHeight: 2.5,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Verifying Session & Syncing...",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
