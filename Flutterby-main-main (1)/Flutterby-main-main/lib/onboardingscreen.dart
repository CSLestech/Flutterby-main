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
      theme: ThemeData(
        fontFamily: 'Garamond',
      ),
      home: onboardingComplete
          ? const HomeView()
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
  bool _showGetStartedButton = false;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/ui/logo.png",
      "title": "Welcome to Check-a-doodle-doo",
      "description":
          "Snap, Analyze, and Stay Safe."
    },
    {
      "image": "assets/images/ui/scan.png",
      "title": "Scan & Classify",
      "description":
          "Snap a photo of chicken meat, and let the system analyze its consumability!"
    },
    {
      "image": "assets/images/ui/results.png",
      "title": "Get Clear Results",
      "description": "Classified into: Safe, Risky, or Not Consumable."
    },
    {
      "image": "assets/images/ui/food_safety.png",
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
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/ui/onboarding_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay content
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);

              if (index == onboardingData.length - 1) {
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _showGetStartedButton = true;
                    });
                  }
                });
              } else {
                setState(() {
                  _showGetStartedButton = false;
                });
              }
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
                      color: Color.fromARGB(255, 128, 94, 2), 
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      data["description"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 125, 100, 0)),
                    ),
                  ),
                ],
              );
            },
          ),

          // Page indicator dots
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    height: 6.0,
                    width: _currentIndex == index ? 12.0 : 6.0,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? const Color.fromARGB(255, 122, 106, 0) : Colors.grey[400],
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Get Started Button
          if (_showGetStartedButton)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 70.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: const Color.fromARGB(255, 170, 107, 0),
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
                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ),
            ),

          // App version text
          const Positioned(
            bottom: 10,
            right: 10,
            child: Text(
              "v1.0.0",
              style: TextStyle(color: Color.fromARGB(179, 186, 174, 0), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
