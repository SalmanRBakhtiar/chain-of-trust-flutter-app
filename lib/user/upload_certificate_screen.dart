import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../api/api_service.dart';

class UploadCertificateScreen extends StatefulWidget {
  @override
  _UploadCertificateScreenState createState() =>
      _UploadCertificateScreenState();
}

class _UploadCertificateScreenState extends State<UploadCertificateScreen> {
  double uploadProgress = 0;
  String? fileName;
  File? qrImageFile;

  final TextEditingController _hashcodeController = TextEditingController();

  String? certificateStatus;
  String? expirationDate;
  String? verificationError;
  bool isVerifying = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _hashcodeController.addListener(() {
      if (_hashcodeController.text.isNotEmpty && qrImageFile != null) {
        setState(() {
          qrImageFile = null;
          fileName = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _hashcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlockCert Manager',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadSection(),
            const SizedBox(height: 32),
            _buildVerificationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.indigo),
              const SizedBox(width: 12),
              Text('Validate Certificate',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade800)),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Enter a hashcode, upload a QR image, or scan to check certificate status.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 30),
          const Text('Enter Hashcode:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _hashcodeController,
            decoration: InputDecoration(
              hintText: 'e.g., abc123xyz...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Upload QR Code Image:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickQRFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Text(
                fileName ?? 'Choose QR Code Image',
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Code'),
                  onPressed: _scanQRCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Validate'),
                  onPressed: () => _verifyCertificate(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildVerificationSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.green),
              const SizedBox(width: 12),
              Text('Certificate Verification',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800)),
            ],
          ),
          const SizedBox(height: 20),
          if (isVerifying) const Center(child: CircularProgressIndicator()),
          if (verificationError != null)
            Text(verificationError!,
                style: const TextStyle(color: Colors.red, fontSize: 16)),
          if (!isVerifying &&
              verificationError == null &&
              certificateStatus == null &&
              expirationDate == null)
            const Text(
              'Enter or scan a hashcode to see the result.',
              style: TextStyle(color: Colors.black54),
            ),
          if (certificateStatus != null || expirationDate != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (certificateStatus != null)
                  Text('Certificate Status: $certificateStatus',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: certificateStatus == 'Valid'
                              ? Colors.green
                              : Colors.red)),
                const SizedBox(height: 4),
                if (expirationDate != null)
                  Text('Expiration Date: $expirationDate',
                      style: TextStyle(color: Colors.grey.shade800)),
              ],
            ),
        ]),
      ),
    );
  }

  Future<void> _verifyCertificate([String? customHash]) async {
    String hash = (customHash ?? _hashcodeController.text).trim();
    hash = hash.replaceAll(RegExp(r'\s+'), '');

    final match = RegExp(r'([0-9a-fA-F]{64})$').firstMatch(hash);
    if (match != null) {
      hash = match.group(0)!;
    }

    final isHex = RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hash);
    if (!isHex) {
      setState(() {
        verificationError =
            '❌ Invalid hash: must be a 64-character hexadecimal string.';
        isVerifying = false;
      });
      return;
    }

    setState(() {
      isVerifying = true;
      certificateStatus = null;
      expirationDate = null;
      verificationError = null;
    });

    try {
      final result = await _apiService.verifyCertificate(hash);

      setState(() {
        final isValid = result['isValid'].toString().toLowerCase() == 'true';
        certificateStatus = isValid ? 'Valid' : 'Invalid';
        final rawDate = result['expirationDate'];
        expirationDate =
            (rawDate != null && rawDate.toString().trim().isNotEmpty)
                ? rawDate.toString()
                : 'N/A';
      });
    } catch (e) {
      setState(() {
        verificationError = e.toString();
      });
    } finally {
      setState(() => isVerifying = false);
    }
  }

  Future<void> _pickQRFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      setState(() {
        qrImageFile = file;
        fileName = file.path.split('/').last;
        _hashcodeController.clear();
      });

      try {
        final String? decoded = await QrCodeToolsPlugin.decodeFrom(file.path);
        if (decoded != null && decoded.isNotEmpty) {
          final match = RegExp(r'([0-9a-fA-F]{64})$').firstMatch(decoded);
          if (match != null) {
            final cleanHash = match.group(0)!;
            _hashcodeController.text = cleanHash;
            await _verifyCertificate(cleanHash);
          } else {
            setState(() =>
                verificationError = 'QR code does not contain a valid hash.');
          }
        } else {
          setState(() => verificationError = 'QR Code could not be read.');
        }
      } catch (e) {
        setState(() {
          verificationError = 'Error reading QR Code: $e';
        });
      }
    }
  }

  Future<void> _scanQRCode() async {
    final scannedResult = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => QRScannerScreen(
          onScanned: (result) {
            Navigator.pop(context, result);
          },
        ),
      ),
    );

    if (scannedResult != null && scannedResult.isNotEmpty) {
      final match = RegExp(r'([0-9a-fA-F]{64})$').firstMatch(scannedResult);
      if (match != null) {
        final cleanHash = match.group(0)!;

        setState(() {
          qrImageFile = null;
          fileName = null;
          verificationError = null;
          certificateStatus = null;
          expirationDate = null;
          _hashcodeController.text = cleanHash;
        });

        await _verifyCertificate(cleanHash);
      } else {
        setState(() {
          verificationError = 'Scanned QR does not contain a valid hash.';
        });
      }
    }
  }
}

// ---------------------- ✅ Embedded QR Scanner Screen ----------------------

class QRScannerScreen extends StatefulWidget {
  final Function(String) onScanned;

  const QRScannerScreen({Key? key, required this.onScanned}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              facing: CameraFacing.back,
              torchEnabled: false,
            ),
            onDetect: (capture) {
              if (!_isScanned && capture.barcodes.isNotEmpty) {
                final barcode = capture.barcodes.first;
                final String? rawValue = barcode.rawValue;

                if (rawValue != null) {
                  setState(() => _isScanned = true);
                  Navigator.pop(context, rawValue);
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
