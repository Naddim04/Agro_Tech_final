import 'package:flutter/material.dart';
import 'login_page.dart';
import 'services/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = SupabaseAuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUpEmailPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent! Please check your inbox.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Language Toggle
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLangButton('BN', false),
                          _buildLangButton('EN', true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF455A64),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Name'),
                        _buildTextField(controller: _nameController, hint: 'Enter Your Name'),
                        const SizedBox(height: 16),
                        _buildLabel('Email'),
                        _buildTextField(controller: _emailController, hint: 'Enter Your Email', keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 16),
                        _buildLabel('Phone Number'),
                        _buildTextField(controller: _phoneController, hint: 'Enter Your Number', keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                        _buildLabel('Password'),
                        _buildTextField(
                          controller: _passwordController,
                          hint: '***************',
                          isPassword: true,
                          obscure: _obscurePassword,
                          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Confirm Password'),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: '***************',
                          isPassword: true,
                          obscure: _obscureConfirmPassword,
                          onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Create an Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.black.withOpacity(0.1))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Or', style: TextStyle(color: Colors.black26)),
                      ),
                      Expanded(child: Divider(color: Colors.black.withOpacity(0.1))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Bottom Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black45, fontSize: 16),
                          children: [
                            const TextSpan(text: 'Already Have an Account? '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                  );
                                },
                                child: const Text('Login', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.orangeAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.black45, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, TextInputType keyboardType = TextInputType.text, bool isPassword = false, bool obscure = false, VoidCallback? onToggleVisibility}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black12),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black26), onPressed: onToggleVisibility) : null,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
