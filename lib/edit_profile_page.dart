import 'package:flutter/material.dart';
import 'services/supabase_auth_service.dart';
import 'widgets/top_header.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _authService = SupabaseAuthService();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String _selectedAvatar = 'https://i.pravatar.cc/150?img=12';

  bool _isLoading = false;
  bool _hasChanges = false;

  final List<String> _avatars = List.generate(
    30,
    (index) => 'https://i.pravatar.cc/150?img=${index + 1}',
  );

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    _nameController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
  }

  void _loadInitialData() {
    final user = _authService.currentUser;

    if (user != null) {
      _nameController.text = user.userMetadata?['full_name'] ?? '';
      _phoneController.text = user.userMetadata?['phone_number'] ?? '';
      _selectedAvatar =
          user.userMetadata?['avatar_url'] ?? _avatars[11];
    }
  }

  void _onChanged() {
    final user = _authService.currentUser;

    final changed =
        _nameController.text != (user?.userMetadata?['full_name'] ?? '') ||
        _phoneController.text != (user?.userMetadata?['phone_number'] ?? '') ||
        _selectedAvatar !=
            (user?.userMetadata?['avatar_url'] ?? _avatars[11]);

    setState(() => _hasChanges = changed);
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      await _authService.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: _selectedAvatar,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating profile'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_hasChanges) return true;

        final shouldLeave = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Discard changes?"),
            content: const Text("You have unsaved changes."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Leave"),
              ),
            ],
          ),
        );

        return shouldLeave ?? false;
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Container(
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
                      TopHeader(
                        title: 'Edit Profile',
                        showBackButton: true,
                        onBack: () async {
                          if (!_hasChanges) {
                            Navigator.pop(context);
                            return;
                          }

                          final shouldLeave = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Discard changes?"),
                              content: const Text("You have unsaved changes."),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text("Leave"),
                                ),
                              ],
                            ),
                          );

                          if (shouldLeave == true) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    backgroundImage:
                                        NetworkImage(_selectedAvatar),
                                    onBackgroundImageError: (_, __) {},
                                    child: _selectedAvatar.isEmpty
                                        ? const Icon(Icons.person,
                                            size: 40)
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                const Text(
                                  'Select Avatar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF455A64),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _avatars.length,
                                    itemBuilder: (context, index) {
                                      final avatar = _avatars[index];
                                      final isSelected =
                                          _selectedAvatar == avatar;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() =>
                                              _selectedAvatar = avatar);
                                          _onChanged();
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(
                                                  right: 12),
                                          padding:
                                              const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.orangeAccent
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 35,
                                            backgroundImage:
                                                NetworkImage(avatar),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 32),

                                _buildLabel('Full Name'),
                                _buildTextField(
                                  _nameController,
                                  'Enter your name',
                                  validator: (value) =>
                                      value == null ||
                                              value.trim().isEmpty
                                          ? 'Name is required'
                                          : null,
                                ),

                                const SizedBox(height: 20),

                                _buildLabel('Phone Number'),
                                _buildTextField(
                                  _phoneController,
                                  'Enter your phone',
                                  keyboardType:
                                      TextInputType.phone,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty) {
                                      return 'Phone is required';
                                    }
                                    if (value.length < 10) {
                                      return 'Invalid phone number';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 40),

                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed:
                                        (!_hasChanges || _isLoading)
                                            ? null
                                            : () {
                                                if (_formKey
                                                    .currentState!
                                                    .validate()) {
                                                  _saveProfile();
                                                }
                                              },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.orangeAccent,
                                      foregroundColor:
                                          Colors.white,
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔥 Loading Overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  _onChanged();
                },
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.orangeAccent,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
      ),
    );
  }
}
