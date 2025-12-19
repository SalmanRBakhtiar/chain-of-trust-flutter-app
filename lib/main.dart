import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase package import
import 'package:chain_of_trust/user/login_page.dart';
import 'package:chain_of_trust/user/signup_page.dart';
import 'package:chain_of_trust/user/chain_of_trust_screen.dart';
import 'package:chain_of_trust/api/certificate_provider.dart'; // Import CertificateProvider

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const ChainOfTrustApp());
}

class ChainOfTrustApp extends StatelessWidget {
  const ChainOfTrustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CertificateProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const ChainOfTrustScreen(), // Directly open ChainOfTrustScreen
        routes: {
          '/login': (context) => const LoginPage(),
          '/signUp': (context) => const SignUpPage(),
          '/chainOfTrust': (context) => const ChainOfTrustScreen(),
        },
      ),
    );
  }
}
