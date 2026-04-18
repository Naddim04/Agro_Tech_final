import 'package:flutter/material.dart';
import 'home_screen.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // Shield / Checkmark Icon
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 140, color: Colors.blueGrey.withOpacity(0.8)),
                      const Icon(Icons.check, size: 80, color: Colors.green),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'Password Changed Succesful', // Matching design spelling
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF455A64),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your information has been Saved',
                  style: TextStyle(color: Colors.black38, fontSize: 16),
                ),
                const Text(
                  'Logging In.',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
