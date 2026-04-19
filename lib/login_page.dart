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
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = SupabaseAuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  String _passwordStrength = '';

  // 🔹 Password Strength Checker
  void _checkPasswordStrength(String password) {
    if (password.length < 6) {
      _passwordStrength = 'Weak';
    } else if (password.length < 10) {
      _passwordStrength = 'Medium';
    } else {
      _passwordStrength = 'Strong';
    }
    setState(() {});
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to Terms & Conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUpEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Validators
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Email required';
    if (!value.contains('@')) return 'Invalid email';
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'Phone required';
    if (value.length < 10) return 'Invalid phone number';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password required';
    if (value.length < 6) return 'Minimum 6 characters';
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildUI(),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                'Sign Up',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              _buildTextField(
                controller: _nameController,
                hint: 'Full Name',
              ),

              _buildTextField(
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
              ),

              _buildTextField(
                controller: _phoneController,
                hint: 'Phone',
                keyboardType: TextInputType.phone,
                validator: _phoneValidator,
              ),

              _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                isPassword: true,
                obscure: _obscurePassword,
                validator: _passwordValidator,
                onChanged: _checkPasswordStrength,
                onToggleVisibility: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),

              // 🔥 Password strength indicator
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Strength: $_passwordStrength',
                  style: TextStyle(
                    color: _passwordStrength == 'Strong'
                        ? Colors.green
                        : _passwordStrength == 'Medium'
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ),

              _buildTextField(
                controller: _confirmPasswordController,
                hint: 'Confirm Password',
                isPassword: true,
                obscure: _obscureConfirmPassword,
                validator: _confirmPasswordValidator,
                onToggleVisibility: () => setState(
                    () => _obscureConfirmPassword =
                        !_obscureConfirmPassword),
              ),

              const SizedBox(height: 10),

              // 🔹 Terms checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (val) =>
                        setState(() => _agreeToTerms = val!),
                  ),
                  const Expanded(
                    child: Text("I agree to Terms & Conditions"),
                  )
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signUp,
                  child: const Text('Create Account'),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage()),
                  );
                },
                child: const Text("Already have an account? Login"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscure = false,
    String? Function(String?)? validator,
    VoidCallback? onToggleVisibility,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscure
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}
