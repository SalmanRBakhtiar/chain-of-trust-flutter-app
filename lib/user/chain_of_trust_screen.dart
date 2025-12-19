import 'dart:async';
import 'package:flutter/material.dart';
import 'custom_widgets.dart';
// Import the login screen
// Import the sign-up screen

class ChainOfTrustScreen extends StatefulWidget {
  const ChainOfTrustScreen({super.key});

  @override
  _ChainOfTrustScreenState createState() => _ChainOfTrustScreenState();
}

class _ChainOfTrustScreenState extends State<ChainOfTrustScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<String> carouselTexts = [
    "Transforming how credentials are verified, one block at a time, for a future built on trust.",
    "Securing the past, empowering the future – revolutionizing certificate validation with blockchain.",
    "Blockchain ensures the truth is not just claimed but proven, empowering a tamper-proof digital world.",
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll with a delay
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          (_currentPage + 1) % carouselTexts.length,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 10),
            // Top Image and Title
            Column(
              children: [
                Image.asset(
                  'assets/fingerprint_icon.png', // Add your image to assets
                  height: 225, // Increased height
                  width:
                      MediaQuery.of(context).size.width - 40, // Reduced width
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Chain of Trust',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1), // Reduced gap
              ],
            ),
            // Carousel Text and Indicators
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20), // Added margin on sides
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 100, // Set a bounded height for the carousel
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: carouselTexts.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomText(
                            text: carouselTexts[index],
                            fontSize: 16,
                            color: Colors.white,
                            alignment: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    carouselTexts.length,
                    (index) => _buildIndicator(isActive: index == _currentPage),
                  ),
                ),
                const SizedBox(height: 20),
                // Subheading (Get Started section)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      text: 'Log In',
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/login'); // Navigate to Login Screen
                      },
                    ),
                    CustomButton(
                      text: 'Sign Up',
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/signUp'); // Navigate to Sign-Up Screen
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const CustomText(
                  text: 'Try it first',
                  fontSize: 14,
                  color: Colors.black,
                ),
                const SizedBox(height: 10),
              ],
            ),
            // Footer
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: CustomText(
                text: 'Powered by Blockchain for a Transparent Future.',
                fontSize: 12,
                color: Colors.grey,
                alignment: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: 8, // Reduced width
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
