import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final _supabase = Supabase.instance.client;

  // Singleton pattern
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  /// Sign up with email and password
  /// Storing name and phone in user metadata
  Future<AuthResponse> signUpEmailPassword({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        'phone_number': phone,
      },
    );
  }

  /// Sign in with email and password
  Future<AuthResponse> signInEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Reset password for email
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Update user profile metadata
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    Map<String, dynamic> data = {};
    if (name != null) data['full_name'] = name;
    if (phone != null) data['phone_number'] = phone;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;

    await _supabase.auth.updateUser(
      UserAttributes(data: data),
    );
  }

  /// Verify OTP for recovery
  Future<AuthResponse> verifyOtpRecovery(String email, String token) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is logged in
  bool get isAuthenticated => currentSession != null;
}
