import 'package:flutter/material.dart';
import 'services/supabase_auth_service.dart';
import 'success_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = SupabaseAuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.updatePassword(password);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SuccessPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating password'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'New Password',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF455A64),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('New Password'),
                        _buildTextField(
                          controller: _passwordController,
                          hint: '***************',
                          obscure: _obscurePassword,
                          toggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Confirm Password'),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: '***************',
                          obscure: _obscurePassword,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Reset Password', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, bool obscure = false, VoidCallback? toggle}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black12),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: toggle != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.black26),
                onPressed: toggle,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
        ),
      ),
    );
  }
}
