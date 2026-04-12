import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    _navigateToLogin();
  }

  _navigateToLogin() async {
    // Stage 1: Show only the image for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _showLoader = true;
      });
    }

    // Stage 2: Show image + loader for 2 more seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Re-enable status bar before leaving
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ));
      Navigator.pushReplacementNamed(context, '/login');
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
          // Subtle Loading Indicator - Appears after 3 seconds
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
                        color: Colors.white.withOpacity(0.8),
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
