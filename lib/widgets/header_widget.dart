import 'package:flutter/material.dart';
import '../services/supabase_auth_service.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  final _authService = SupabaseAuthService();
  String _name = 'User Name';
  String _avatarUrl = 'https://i.pravatar.cc/150?img=11';

  @override
  void initState() {
    super.initState();
    _loadUserMetadata();
  }

  void _loadUserMetadata() {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _name = user.userMetadata?['full_name'] ?? 'User Name';
        _avatarUrl = user.userMetadata?['avatar_url'] ?? 'https://i.pravatar.cc/150?img=11';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Profile Avatar
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(_avatarUrl),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello',
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                  ),
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF455A64),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Language Toggle
          Container(
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
              children: [
                _buildLangButton('BN', false),
                _buildLangButton('EN', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.orangeAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : Colors.black45,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
