import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menu_drawer.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool emailNotification = false;
  bool smsNotification = false;
  bool isLoading = false;

  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => isLoading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc =
        await FirebaseFirestore.instance.collection('admin').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      _usernameController.text = data?['name'] ?? '';
      _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
      _phoneController.text = data?['phone'] ?? '';
    }
    setState(() => isLoading = false);
  }

  Future<void> _saveAdminProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isNotEmpty || confirmPassword.isNotEmpty) {
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
        return;
      }
      try {
        await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password update failed: $e')),
        );
        return;
      }
    }

    await FirebaseFirestore.instance.collection('admin').doc(uid).set({
      'name': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'role': 'admin',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin profile updated successfully!')),
    );

    // Clear password fields after success
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Settings',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      drawer: MenuDrawer(),
      backgroundColor: Colors.grey[850],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SETTINGS',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage your preferences and account settings.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsSection(
                    title: 'Admin Profile',
                    children: [
                      _buildTextField(
                          label: 'Username', controller: _usernameController),
                      _buildTextField(
                          label: 'Email',
                          controller: _emailController,
                          isEnabled: false),
                      _buildTextField(
                          label: 'Phone Number', controller: _phoneController),
                      _buildPasswordField(
                          label: 'New Password',
                          controller: _newPasswordController,
                          isVisible: _newPasswordVisible,
                          onToggle: () {
                            setState(() =>
                                _newPasswordVisible = !_newPasswordVisible);
                          }),
                      _buildPasswordField(
                          label: 'Confirm New Password',
                          controller: _confirmPasswordController,
                          isVisible: _confirmPasswordVisible,
                          onToggle: () {
                            setState(() => _confirmPasswordVisible =
                                !_confirmPasswordVisible);
                          }),
                      const SizedBox(height: 8),
                      _buildSaveButton(onPressed: _saveAdminProfile),
                    ],
                  ),
                  _buildSettingsSection(
                    title: 'Notifications',
                    children: [
                      _buildNotificationRow(),
                      const SizedBox(height: 8),
                      _buildSaveButton(onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Notification preferences saved!')),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: isEnabled,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: onToggle,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNotificationRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildCheckbox(
            label: 'Email Notifications',
            value: emailNotification,
            onChanged: (value) => setState(() => emailNotification = value!),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildCheckbox(
            label: 'SMS Notifications',
            value: smsNotification,
            onChanged: (value) => setState(() => smsNotification = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.red,
          checkColor: Colors.white,
        ),
        Flexible(
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSaveButton({required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Text('SAVE CHANGES',
          style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }
}
