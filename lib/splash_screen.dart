import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_screen.dart';
import 'services/supabase_auth_service.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progressValue = 0.0;
  Timer? _timer;
  final _authService = SupabaseAuthService();

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    const duration = Duration(milliseconds: 50);
    _timer = Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          _progressValue += 0.01;
          if (_progressValue >= 1.0) {
            _timer?.cancel();
            _handleNavigation();
          }
        });
      }
    });
  }

  void _handleNavigation() {
    if (_authService.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // Light blue-ish top
              Color(0xFFF5F5F5), // Near-white bottom
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // App Title
                const Text(
                  'AgroTech',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF455A64),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                Text(
                  'Smarter Farming for a Better Future',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black38,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 48),
                // Progress Bar
                SizedBox(
                  width: 250,
                  height: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                    ),
                  ),
                ),
              ],
            ),
            // Version at bottom
            Positioned(
              bottom: 40,
              child: Text(
                'Version - 1.0',
                style: TextStyle(
                  color: Colors.black26,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
