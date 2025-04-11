import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'home_view.dart'; // Import the HomeView class

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(CadApp(onboardingComplete: onboardingComplete));
}

class CadApp extends StatelessWidget {
  final bool onboardingComplete;

  const CadApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: onboardingComplete
          ? const HomeView() // Navigate directly to HomeView if onboarding is complete
          : OnboardingScreen(
              onFinish: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeView()),
                );
              },
            ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/scan.png",
      "title": "Scan & Classify",
      "description":
          "Snap a photo of chicken meat, and let the system analyze its consumability!"
    },
    {
      "image": "assets/results.png",
      "title": "Get Clear Results",
      "description": "Classified into: Safe, Risky, or Not Consumable."
    },
    {
      "image": "assets/food_safety.png",
      "title": "Be Informed",
      "description":
          "Be aware and make better decisions by checking the quality before cooking or eating."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final data = onboardingData[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(data["image"]!, height: 300),
                  const SizedBox(height: 20),
                  Text(
                    data["title"]!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      data["description"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              );
            },
          ),
          if (_currentIndex != onboardingData.length - 1)
            Align(
              alignment: Alignment.bottomRight, // Align to the bottom-right
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 16.0, // Add some padding from the right
                  bottom: 16.0, // Add some padding from the bottom
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30, // Adjust the horizontal padding
                      vertical: 15, // Adjust the vertical padding
                    ),
                    backgroundColor: Colors.blue, // Change the button color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                    ),
                  ),
                  onPressed: () {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 18, // Adjust the font size
                      color: Colors.white, // Change the text color
                    ),
                  ),
                ),
              ),
            ),
          if (_currentIndex == onboardingData.length - 1)
            Align(
              alignment: Alignment.bottomCenter, // Align to the bottom-center
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 32.0, // Add some padding from the bottom
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.green, // Change the button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('onboarding_complete', true);
                    widget.onFinish();
                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
