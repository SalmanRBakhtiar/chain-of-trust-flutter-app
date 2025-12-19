import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/certificate_provider.dart';
// ignore: unused_import
import '../api/models.dart';
import 'menu_drawer.dart';

class CertificateScreen extends StatefulWidget {
  @override
  _CertificateScreenState createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCertificates();
    });
  }

  void _fetchCertificates() async {
    final provider = Provider.of<CertificateProvider>(context, listen: false);
    try {
      await provider.fetchCertificates();
      print("Fetched ${provider.certificates.length} certificates");
    } catch (e) {
      print("Error fetching certificates: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CertificateProvider>(context);
    final certificates = provider.certificates.where((cert) {
      final query = _searchQuery.toLowerCase();
      return cert.name.toLowerCase().contains(query) ||
          cert.email.toLowerCase().contains(query) ||
          cert.cnicNumber.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'All Certificates',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchCertificates,
          )
        ],
      ),
      drawer: MenuDrawer(),
      backgroundColor: Colors.grey[850],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search by name, email or CNIC',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : certificates.isEmpty
                    ? const Center(
                        child: Text(
                          'No certificates found.',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: certificates.length,
                        itemBuilder: (context, index) {
                          final cert = certificates[index];
                          return Card(
                            color: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: ListTile(
                              title: Text(
                                '${cert.name} ${cert.lastName}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${cert.email}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  Text('CNIC: ${cert.cnicNumber}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  Text('Mobile: ${cert.mobileNumber}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  Text('Hash: ${cert.hashcode}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  Row(
                                    children: [
                                      const Text(
                                        'Status: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Icon(
                                        cert.isValid
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: cert.isValid
                                            ? Colors.green
                                            : Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        cert.isValid ? 'Valid' : 'Revoked',
                                        style: TextStyle(
                                          color: cert.isValid
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text('Expiry: ${cert.expirationDate}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
