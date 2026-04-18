import 'package:flutter/material.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import 'services/supabase_auth_service.dart';
import 'widgets/top_header.dart';
import 'my_crops_page.dart';
import 'my_farm_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = SupabaseAuthService();
  User? _user;
  String _name = 'Guest';
  final String _location = 'Not Set';
  String _avatarUrl = 'https://i.pravatar.cc/150?img=12';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _user = _authService.currentUser;
      if (_user != null) {
        _name = _user!.userMetadata?['full_name'] ?? 'No Name';
        _avatarUrl = _user!.userMetadata?['avatar_url'] ?? 'https://i.pravatar.cc/150?img=12';
        // You could also fetch location if stored in metadata
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F2FD), Color(0xFFF5F5F5)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const TopHeader(title: 'Profile', showBackButton: false),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Image
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            image: DecorationImage(
                              image: NetworkImage(_avatarUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF455A64))),
                    Text(_location, style: const TextStyle(color: Colors.black38)),
                    const SizedBox(height: 32),
                    const SizedBox(height: 24),
                    // Menu List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditProfilePage()),
                              );
                              _loadUserData(); // Reload when returning
                            },
                            child: _buildMenuItem(Icons.person_outline, 'Edit Profile'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MyFarmPage()),
                              );
                            },
                            child: _buildMenuItem(Icons.agriculture_outlined, 'My Farm'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MyCropsPage()),
                              );
                            },
                            child: _buildMenuItem(Icons.grass_outlined, 'My Crops'),
                          ),
                          _buildMenuItem(Icons.shopping_cart_outlined, 'Cart'),
                          _buildMenuItem(Icons.assignment_outlined, 'Orders'),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () async {
                              await _authService.signOut();
                              if (mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                  (route) => false,
                                );
                              }
                            },
                            child: _buildMenuItem(Icons.logout, 'Logout', color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMenuItem(IconData icon, String label, {Color color = Colors.black45}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color == Colors.black45 ? const Color(0xFF455A64) : color))),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }
}
