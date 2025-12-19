import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final TextAlign alignment;

  const CustomText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = Colors.black,
    this.alignment = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: alignment,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final String userRole; // Pass user role (Admin or normal user)

  const CustomDrawer({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    // If user is Admin, navigate to Admin Dashboard as the default screen
    if (userRole == 'Admin') {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      });
    }

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            accountName: const Text(
              'Salman', // Dynamic name can be passed
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              userRole, // Show user role dynamically
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundImage:
                  AssetImage('assets/profile.jpg'), // Replace with user image
            ),
          ),
          buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => Navigator.pushNamed(context, '/dashboard'),
          ),
          buildDrawerItem(
            context,
            icon: Icons.upload_file,
            title: 'Upload Certificate',
            onTap: () => Navigator.pushNamed(context, '/upload_certificate'),
          ),
          buildDrawerItem(
            context,
            icon: Icons.history,
            title: 'Certificate History',
            onTap: () => Navigator.pushNamed(context, '/certificate_history'),
          ),
          buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          const Divider(),
          buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
