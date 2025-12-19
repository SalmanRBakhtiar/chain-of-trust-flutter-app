import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../api/certificate_provider.dart';
import '../user/login_page.dart';
import 'menu_drawer.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CertificateProvider>(context, listen: false)
            .fetchCertificates());
  }

  @override
  Widget build(BuildContext context) {
    final certProvider = Provider.of<CertificateProvider>(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Row(
            children: [
              const Expanded(
                child: Text(
                  'Admin Dashboard',
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () => _showNotificationDialog(context),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 18,
                backgroundImage: const AssetImage('assets/salman.jpg'),
                backgroundColor: Colors.grey[700],
              ),
            ],
          ),
        ),
        drawer: MenuDrawer(),
        body: certProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : certProvider.error != null
                ? Center(
                    child: Text(
                      "❌ ${certProvider.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _buildDashboard(certProvider),
      ),
    );
  }

  Widget _buildDashboard(CertificateProvider certProvider) {
    final certs = certProvider.certificates;
    final total = certs.length;
    final valid = certs.where((c) => c.isValid).length;
    final revoked = certs.where((c) => !c.isValid).length;
    final expired = certs
        .where((c) => DateTime.tryParse(c.expirationDate) != null
            ? DateTime.parse(c.expirationDate).isBefore(DateTime.now())
            : false)
        .length;
    final expiringSoon = certs
        .where((c) => DateTime.tryParse(c.expirationDate) != null
            ? DateTime.parse(c.expirationDate)
                .isBefore(DateTime.now().add(const Duration(days: 30)))
            : false)
        .length;
    final successRate =
        total > 0 ? ((valid / total) * 100).toStringAsFixed(1) : "0";

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your dashboard overview and recent activities.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // ✅ Dynamic Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('$total', 'Total Certificates', Icons.file_copy,
                    Colors.red),
                _buildStatCard('$valid', 'Valid Certificates',
                    Icons.check_circle, Colors.green),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('$revoked', 'Revoked Certificates', Icons.cancel,
                    Colors.orange),
                _buildStatCard('$expired', 'Expired Certificates',
                    Icons.timer_off, Colors.purple),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                    '0', 'Renewed Certificates', Icons.refresh, Colors.blue),
                _buildStatCard(
                    '$total', 'Total Students', Icons.people, Colors.teal),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('$successRate%', 'Success Rate From Results',
                    Icons.show_chart, Colors.lightGreen),
                _buildStatCard('$expiringSoon', 'Expiring Soon (30 days)',
                    Icons.warning, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String count, String label, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('You have no new notifications.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }
}
