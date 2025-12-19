class CertificateInput {
  final String hashcode;
  final String name;
  final String lastName;
  final String cnicNumber;
  final String email;
  final String mobileNumber;
  final String address;
  final String expirationDate;

  CertificateInput({
    required this.hashcode,
    required this.name,
    required this.lastName,
    required this.cnicNumber,
    required this.email,
    required this.mobileNumber,
    required this.address,
    required this.expirationDate,
  });

  Map<String, dynamic> toJson() => {
        'hashcode': hashcode,
        'name': name,
        'lastName': lastName,
        'cnicNumber': cnicNumber,
        'email': email,
        'mobileNumber': mobileNumber,
        'address': address,
        'expirationDate': expirationDate,
      };
}

class CertificateOutput {
  final String id;
  final String hashcode;
  final String name;
  final String lastName;
  final String cnicNumber;
  final String email;
  final String mobileNumber;
  final String address;
  final String expirationDate;
  final bool isValid;

  CertificateOutput({
    required this.id,
    required this.hashcode,
    required this.name,
    required this.lastName,
    required this.cnicNumber,
    required this.email,
    required this.mobileNumber,
    required this.address,
    required this.expirationDate,
    required this.isValid,
  });

  factory CertificateOutput.fromJson(Map<String, dynamic> json) {
    return CertificateOutput(
      id: json['id'].toString(),
      hashcode: json['hashcode'] ?? '',
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      cnicNumber: json['cnicNumber'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      address: json['address'] ?? '',
      expirationDate: json['expirationDate'] ?? '',
      isValid: json['isValid'] ?? false,
    );
  }
}
