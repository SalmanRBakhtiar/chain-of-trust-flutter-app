import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  static const String _baseUrl = 'http://10.33.47.186:5053/api';

  Future<Map<String, dynamic>> uploadCertificate(
      CertificateInput certificate) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/certificates'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(certificate.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to upload certificate: ${jsonDecode(response.body)['message']}');
    }
  }

  Future<Map<String, dynamic>> revokeCertificate(String hashcode) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/certificates/revoke'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Hashcode': hashcode}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to revoke certificate: ${jsonDecode(response.body)['message']}');
    }
  }

  Future<List<CertificateOutput>> getAllCertificates(
      {required int page, required int limit}) async {
    final response = await http.get(Uri.parse('$_baseUrl/admin/certificates'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CertificateOutput.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to fetch certificates: ${jsonDecode(response.body)['message']}');
    }
  }

  Future<Map<String, dynamic>> verifyCertificate(String hashcode) async {
    final url = '$_baseUrl/client/certificates/verify/$hashcode';
    print('🔍 Requesting: $url');

    // Validate hash before calling API (matches backend)
    if (hashcode.length != 64 ||
        !RegExp(r'^[0-9a-fA-F]+$').hasMatch(hashcode)) {
      throw Exception(
          '❌ Invalid hashcode: Must be a 64-character hexadecimal string.');
    }

    final response = await http.get(Uri.parse(url));
    print('📦 Status Code: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final errorMsg = jsonDecode(response.body)['message'];
        throw Exception('❌ $errorMsg');
      } catch (_) {
        throw Exception(
            '❌ Failed to verify certificate. Raw response: ${response.body}');
      }
    }
  }
}
