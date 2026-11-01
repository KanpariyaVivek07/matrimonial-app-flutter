import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:textformfield/Screens/Auth/Login_Screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "image": "assets/image/onboarding1.png",
      "title": "Find Your Perfect Match",
      "desc":
      "Discover compatible profiles tailored to your preferences with our advanced matching algorithm.",
      "color": const Color(0xFF6A11CB), // Deep purple
      "secondaryColor": const Color(0xFF2575FC), // Blue for gradient
      "imageBg": const Color(0xFFE0D7FF), // Light purple background
      "buttonColor": Colors.white,
      "buttonTextColor": Color(0xFF6A11CB),
    },
    {
      "image": "assets/image/onboarding2.png",
      "title": "Connect & Build Relationships",
      "desc":
      "Send requests, chat securely, and take meaningful steps toward your future together.",
      "color": const Color(0xFF2575FC), // Blue
      "secondaryColor": const Color(0xFF6A11CB), // Purple for gradient
      "imageBg": const Color(0xFFD6E4FF), // Light blue background
      "buttonColor": Colors.white,
      "buttonTextColor": Color(0xFF2575FC),
    },
    {
      "image": "assets/image/onboarding3.png",
      "title": "Start Your Journey Together",
      "desc":
      "Real stories from real couples who found love through our platform. Your story could be next!",
      "color": const Color(0xFFFF6B6B), // Coral
      "secondaryColor": const Color(0xFFFFE66D), // Yellow for gradient
      "imageBg": const Color(0xFFFFE0E0), // Light coral background
      "buttonColor": Colors.white,
      "buttonTextColor": Color(0xFFFF6B6B),
    },
  ];

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentIndex == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentIndex == index
            ? Colors.white
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: _currentIndex == index
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ]
            : [],
      ),
    );
  }

  Widget _buildImage(String imagePath, Color bgColor) {
    return Container(
      width: 230,
      height: 230,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background with Gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  onboardingData[_currentIndex]["color"],
                  onboardingData[_currentIndex]["secondaryColor"],
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.8],
              ),
            ),
          ),

          // Background Pattern (optional - comment out if you don't have this asset)
          // Opacity(
          //   opacity: 0.05,
          //   child: Container(
          //     decoration: const BoxDecoration(
          //       image: DecorationImage(
          //         image: AssetImage("assets/image/pattern.png"),
          //         repeat: ImageRepeat.repeat,
          //       ),
          //     ),
          //   ),
          // ),

          // Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 24,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _currentIndex == onboardingData.length - 1 ? 0 : 1,
              child: InkWell(
                onTap: _skipOnboarding,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextButton(onPressed: () {

                  }, child: Text("Skip"),),
                ),
              ),
            ),
          ),

          // PageView Content
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final data = onboardingData[index];
              return SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: screenHeight,
                  ),
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.12,
                    bottom: screenHeight * 0.05,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Image Section with custom shape
                      AnimatedScale(
                        duration: const Duration(milliseconds: 600),
                        scale: _currentIndex == index ? 1 : 0.9,
                        child: _buildImage(data["image"], data["imageBg"]),
                      ),

                      SizedBox(height: isSmallScreen ? 20 : 40),

                      // Text Content
                      Column(
                        children: [
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 500),
                            offset: _currentIndex == index
                                ? Offset.zero
                                : const Offset(0, 0.2),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: _currentIndex == index ? 1 : 0,
                              child: Text(
                                data["title"],
                                style: GoogleFonts.montserrat(
                                  fontSize: isSmallScreen ? 28 : 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 600),
                            offset: _currentIndex == index
                                ? Offset.zero
                                : const Offset(0, 0.2),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 600),
                              opacity: _currentIndex == index ? 1 : 0,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                ),
                                child: Text(
                                  data["desc"],
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    color: Colors.white.withOpacity(0.95),
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 20 : 40),

                      // Indicators and Next Button
                      Column(
                        children: [
                          // Page Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              onboardingData.length,
                                  (index) => _buildIndicator(index),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Next/Get Started Button
                          SizedBox(
                            width: double.infinity,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _nextPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: data["buttonColor"],
                                  foregroundColor: data["buttonTextColor"],
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.deepPurple),
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentIndex == onboardingData.length - 1
                                          ? "Get Started"
                                          : "Continue",
                                      style: GoogleFonts.poppins(
                                        fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (_currentIndex < onboardingData.length - 1)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Back button (only show if not on first page)
          if (_currentIndex > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 24,
              child: InkWell(
                onTap: () {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}