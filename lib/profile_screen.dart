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
  String _location = 'Not Set';
  String _avatarUrl = 'https://i.pravatar.cc/150?img=12';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final user = _authService.currentUser;

    if (user != null) {
      _name = user.userMetadata?['full_name'] ?? 'No Name';
      _avatarUrl = user.userMetadata?['avatar_url'] ?? _avatarUrl;
      _location = user.userMetadata?['location'] ?? 'Not Set';
    }

    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout")),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: Scaffold(
        body: Container(
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              // Avatar + Edit Button
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(_avatarUrl),
                                    onBackgroundImageError: (_, __) {},
                                    child: _avatarUrl.isEmpty
                                        ? const Icon(Icons.person, size: 40)
                                        : null,
                                  ),

                                  InkWell(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const EditProfilePage()),
                                      );
                                      _loadUserData();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.orangeAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.edit, size: 18, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Text(
                                _name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF455A64),
                                ),
                              ),

                              Text(
                                _location,
                                style: const TextStyle(color: Colors.black38),
                              ),

                              const SizedBox(height: 32),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: [
                                    _menuItem(Icons.person_outline, 'Edit Profile', () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const EditProfilePage()),
                                      );
                                      _loadUserData();
                                    }),

                                    _menuItem(Icons.agriculture_outlined, 'My Farm', () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const MyFarmPage()),
                                      );
                                    }),

                                    _menuItem(Icons.grass_outlined, 'My Crops', () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const MyCropsPage()),
                                      );
                                    }),

                                    _menuItem(Icons.shopping_cart_outlined, 'Cart', () {}),

                                    _menuItem(Icons.assignment_outlined, 'Orders', () {}),

                                    const SizedBox(height: 12),

                                    _menuItem(Icons.logout, 'Logout', _confirmLogout, color: Colors.redAccent),
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
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap,
      {Color color = Colors.black45}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color == Colors.black45
                        ? const Color(0xFF455A64)
                        : color,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
