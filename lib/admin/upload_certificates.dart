import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'menu_drawer.dart';
// ignore: unused_import
import '../api/api_service.dart';
import '../api/models.dart';
import '../api/certificate_provider.dart';

class UploadCertificates extends StatefulWidget {
  @override
  _UploadCertificatesState createState() => _UploadCertificatesState();
}

class _UploadCertificatesState extends State<UploadCertificates> {
  final _formKey = GlobalKey<FormState>();
  String? _hashCode;
  File? _selectedFile;
  bool _uploadSuccess = false;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isUploading = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      final bytes = await _selectedFile!.readAsBytes();
      final digest = sha256.convert(bytes);
      setState(() {
        _hashCode = digest.toString();
        _uploadSuccess = false;
      });
    }
  }

  Future<void> _uploadCertificate() async {
    if (_formKey.currentState!.validate() && _hashCode != null) {
      setState(() {
        _isUploading = true;
        _errorMessage = null;
        _uploadSuccess = false;
      });

      final certificate = CertificateInput(
        hashcode: _hashCode!,
        name: _nameController.text,
        lastName: _lastNameController.text,
        cnicNumber: _cnicController.text,
        email: _emailController.text,
        mobileNumber: _mobileController.text,
        address: _addressController.text,
        expirationDate: _dateController.text,
      );

      try {
        await Provider.of<CertificateProvider>(context, listen: false)
            .addCertificate(certificate);
        setState(() {
          _isUploading = false;
          _uploadSuccess = true;
        });

        final verificationUrl =
            "http://10.238.109.17:5053/api/client/certificates/verify/$_hashCode";
        final qrUrl =
            'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$verificationUrl';

        await _downloadQRCode(qrUrl);
      } catch (e) {
        setState(() {
          _isUploading = false;
          _uploadSuccess = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _downloadQRCode(String qrUrl) async {
    try {
      final status = await Permission.storage.request();

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required.')),
        );
        return;
      }

      final response = await http.get(Uri.parse(qrUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final downloadPath = '/storage/emulated/0/Download';
        final fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = '$downloadPath/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR code saved to: $filePath')),
        );
        print('✅ QR saved at: $filePath');
      } else {
        throw Exception('Failed to download QR code');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving QR: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Upload Certificate',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      drawer: MenuDrawer(),
      backgroundColor: Colors.grey[850],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UPLOAD CERTIFICATE',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFileUploadField('Certificate File (PDF)'),
                _buildHashCodeField(),
                _buildTextField('Name', Icons.person,
                    controller: _nameController),
                _buildTextField('Last Name', Icons.person_outline,
                    controller: _lastNameController),
                _buildTextField('CNIC Number', Icons.credit_card,
                    controller: _cnicController, isNumber: true),
                _buildTextField('Email', Icons.email,
                    controller: _emailController, isEmail: true),
                _buildTextField('Mobile Number', Icons.phone,
                    controller: _mobileController, isNumber: true),
                _buildTextField('Address', Icons.home,
                    controller: _addressController),
                _buildDateField(context, 'Expiration Date'),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isUploading ? null : _uploadCertificate,
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Center(
                          child: Text(
                            'Upload Certificate',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                if (_uploadSuccess) _buildCertificateDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon,
      {bool isNumber = false,
      bool isEmail = false,
      TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            if (isEmail &&
                !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
              return 'Enter a valid email';
            }
            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFileUploadField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _selectedFile != null
                  ? _selectedFile!.path.split('/').last
                  : 'Choose File',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHashCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Generated Hashcode',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _hashCode ?? 'No hashcode generated',
            style: const TextStyle(color: Colors.black),
          ),
        ),
        if (_hashCode != null)
          Text('Hashcode length: ${_hashCode!.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              _dateController.text =
                  '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
              setState(() {});
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dateController.text.isEmpty
                      ? 'Select Date'
                      : _dateController.text,
                  style: const TextStyle(color: Colors.black),
                ),
                const Icon(Icons.calendar_today, color: Colors.black),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCertificateDetails() {
    final String name = _nameController.text;
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Certificate uploaded successfully!',
              style: TextStyle(
                  color: Colors.greenAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Certificate Details',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text('Name: $name', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Hash: $_hashCode',
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
