import 'package:flutter/material.dart';
import 'services/supabase_auth_service.dart';
import 'reset_password_page.dart';
import 'dart:async';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _authService = SupabaseAuthService();
  String _otp = "";
  bool _isLoading = false;
  int _timerSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onNumberPress(String number) {
    if (_otp.length < 6) {
      setState(() => _otp += number);
    }
  }

  void _onBackspace() {
    if (_otp.isNotEmpty) {
      setState(() => _otp = _otp.substring(0, _otp.length - 1));
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyOtpRecovery(widget.email, _otp);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ResetPasswordPage(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP code'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification OTP', style: TextStyle(color: Color(0xFF455A64), fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildLangToggle(),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFF5F5F5)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // OTP Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) => _buildOtpBox(index)),
            ),
            const SizedBox(height: 16),
            Text(
              'A code has been sent to your email',
              style: TextStyle(color: Colors.black.withOpacity(0.4)),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _timerSeconds == 0 ? () {
                setState(() => _timerSeconds = 60);
                _startTimer();
                _authService.resetPassword(widget.email);
              } : null,
              child: Text(
                _timerSeconds == 0 ? 'Resend now' : 'Resend in 00:${_timerSeconds.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const Spacer(),
            // Custom Numpad
            _buildNumpad(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    String char = "";
    if (_otp.length > index) {
      char = _otp[index];
    }
    bool isFocused = _otp.length == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? Colors.orangeAccent : Colors.black.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Center(
        child: Text(
          char,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF455A64)),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildNumButton("1"), _buildNumButton("2"), _buildNumButton("3")],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildNumButton("4"), _buildNumButton("5"), _buildNumButton("6")],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildNumButton("7"), _buildNumButton("8"), _buildNumButton("9")],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumButton("*", isSpecial: true),
              _buildNumButton("0"),
              _buildNumButton("backspace", isIcon: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumButton(String value, {bool isIcon = false, bool isSpecial = false}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          if (isIcon) {
            _onBackspace();
          } else if (!isSpecial) {
            _onNumberPress(value);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.28,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isIcon 
              ? const Icon(Icons.backspace_outlined, color: Color(0xFF455A64))
              : Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF455A64)),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSmallLangButton('BN', false),
          _buildSmallLangButton('EN', true),
        ],
      ),
    );
  }

  Widget _buildSmallLangButton(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.orangeAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(color: active ? Colors.white : Colors.black45, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
