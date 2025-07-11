import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vipe_connect/views/login_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': 'Welcome to Vipe Connect',
      'desc': 'Connect, share and grow with your friends.',
    },
    {
      'image': 'assets/images/onboarding3.PNG',
      'title': 'Explore the Community',
      'desc': 'Join discussions and make your voice heard.',
    },
    {
      'image': 'assets/images/onboarding2.PNG',
      'title': 'Start Chatting',
      'desc': 'Send and receive messages in real-time.',
    },
  ];

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginView()),
    );
  }

  void nextPage() {
    if (currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() => currentPage = index);
            },
            itemBuilder: (context, index) {
              final data = onboardingData[index];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(data['image']!, height: 300),
                    const SizedBox(height: 40),
                    Text(
                      data['title']!,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      data['desc']!,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // Skip button (top right)
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: completeOnboarding,
              child: const Text("Skip", style: TextStyle(fontSize: 16)),
            ),
          ),

          // Bottom section: dots + next or get started
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      height: 8,
                      width: currentPage == index ? 20 : 8,
                      decoration: BoxDecoration(
                        color: currentPage == index ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    currentPage == onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
