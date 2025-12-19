// ignore: unused_import
import 'dart:convert';
import 'package:flutter/foundation.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;
import 'models.dart';
import 'api_service.dart';

class CertificateProvider with ChangeNotifier {
  List<CertificateOutput> _certificates = [];
  bool _isLoading = false;
  String? _error;

  List<CertificateOutput> get certificates => _certificates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  Future<void> fetchCertificates({int page = 1, int limit = 100}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final certificates =
          await _apiService.getAllCertificates(page: page, limit: limit);
      _certificates = certificates;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCertificate(CertificateInput certificate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.uploadCertificate(certificate);
      await fetchCertificates(); // Refresh list after upload
    } catch (e) {
      _error = e.toString();
      throw Exception('Failed to add certificate: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> revokeCertificate(String hashcode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.revokeCertificate(hashcode);
      await fetchCertificates(); // Refresh list after revoke
    } catch (e) {
      _error = e.toString();
      throw Exception('Failed to revoke certificate: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
