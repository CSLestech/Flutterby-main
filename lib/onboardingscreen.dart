// This file implements the onboarding screen that is shown to first-time users
// It provides a tutorial walkthrough of the app's main features

import 'package:flutter/material.dart'; // Import Material Design package
import 'package:shared_preferences/shared_preferences.dart'; // Import for local data storage
import 'package:flutter/services.dart'; // Import services for platform integration
import 'home_view.dart'; // Import the main home view

/// Main function - alternative entry point when running this file directly
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Get access to shared preferences to check onboarding status
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ??
      false; // Get status, default to false

  // Configure system UI appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor:
          Colors.transparent, // Transparent navigation bar
      statusBarBrightness: Brightness.light, // Light status bar content
      statusBarColor: Colors.transparent, // Transparent status bar background
    ),
  );

  // Launch the app, passing onboarding status
  runApp(CadApp(onboardingComplete: onboardingComplete));
}

/// CadApp is the root widget of the application when launched from this file
class CadApp extends StatelessWidget {
  final bool
      onboardingComplete; // Flag indicating if user has completed onboarding

  // Constructor requiring onboarding status
  const CadApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, // Remove debug banner in the corner
        theme: ThemeData(
          fontFamily: 'Garamond', // Set default font family for the app
        ),
        home: onboardingComplete
            ? const HomeView() // Navigate directly to HomeView if onboarding is complete
            : OnboardingScreen(
                onFinish: () {
                  // When onboarding finishes, navigate to home screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeView()),
                  );
                },
              ));
  }
}

/// OnboardingScreen displays a series of introductory slides about the app
class OnboardingScreen extends StatefulWidget {
  final VoidCallback
      onFinish; // Callback function for when onboarding completes

  // Constructor requiring the completion callback
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller =
      PageController(); // Controller for managing page transitions
  int _currentIndex = 0; // Tracks the current page index
  bool _showGetStartedButton =
      false; // Controls visibility of the Get Started button

  // List of onboarding slides with their images, titles, and descriptions
  final List<Map<String, String>> onboardingData = [
    {
      "image": "images/ui/logo.png", // App logo image
      "title": "Welcome to Check-a-doodle-doo", // Welcome title
      "description": "Snap, Analyze, and Stay Safe." // Brief app tagline
    },
    {
      "image": "images/ui/scan.png", // Image showing scan functionality
      "title": "Scan & Classify", // Feature title
      "description":
          "Snap a photo of chicken meat, and let the system analyze its consumability!" // Feature description
    },
    {
      "image": "images/ui/results.png", // Image showing results screen
      "title": "Get Clear Results", // Feature title
      "description":
          "Classified into: Safe, Risky, or Not Consumable." // Feature description
    },
    {
      "image": "images/ui/food_safety.png", // Image showing food safety concept
      "title": "Be Informed", // Feature title
      "description":
          "Be aware and make better decisions by checking the quality before cooking or eating." // Feature description
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image layer
          Positioned.fill(
            child: Image.asset(
              'images/ui/onboarding_bg.jpg', // Background image for onboarding
              fit: BoxFit.cover, // Scale image to cover entire background
            ),
          ),

          // Onboarding content - slides that can be swiped through
          PageView.builder(
            controller:
                _controller, // Use the page controller for slide transitions
            itemCount: onboardingData.length, // Number of slides
            onPageChanged: (index) {
              setState(() => _currentIndex =
                  index); // Update the current index when page changes

              // Show the "Get Started" button after a delay when the last page is reached
              if (index == onboardingData.length - 1) {
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    // Safety check that widget is still in tree
                    setState(() {
                      _showGetStartedButton = true; // Show the button
                    });
                  }
                });
              } else {
                setState(() {
                  _showGetStartedButton =
                      false; // Hide the button on non-final pages
                });
              }
            },
            itemBuilder: (context, index) {
              final data = onboardingData[index]; // Get current slide data
              return Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center content vertically
                children: [
                  Image.asset(data["image"]!,
                      height: 300), // Display slide image
                  const SizedBox(height: 20), // Add vertical spacing
                  Text(
                    data["title"]!, // Display slide title
                    style: const TextStyle(
                      fontSize: 24, // Large text size
                      fontWeight: FontWeight.bold, // Bold text
                      color:
                          Color.fromARGB(255, 128, 94, 2), // Golden brown color
                    ),
                  ),
                  const SizedBox(height: 10), // Add vertical spacing
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0), // Add horizontal padding
                    child: Text(
                      data["description"]!, // Display slide description
                      textAlign: TextAlign.center, // Center-align text
                      style: const TextStyle(
                        fontSize: 16, // Medium text size
                        color: Color.fromARGB(
                            255, 125, 100, 0), // Golden brown color (lighter)
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Page indicator dots at bottom of screen
          Align(
            alignment: Alignment.bottomCenter, // Position at bottom center
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 24.0), // Add bottom padding
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center dots horizontally
                children: List.generate(
                  onboardingData.length, // Generate dots for each slide
                  (index) => AnimatedContainer(
                    duration: const Duration(
                        milliseconds:
                            300), // Animation duration for dot transitions
                    margin: const EdgeInsets.symmetric(
                        horizontal: 3.0), // Space between dots
                    height: 6.0, // Dot height
                    width: _currentIndex == index
                        ? 12.0
                        : 6.0, // Width varies based on if dot is active
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? const Color.fromARGB(255, 122, 106,
                              0) // Active dot color - darker gold
                          : Colors.grey[400], // Inactive dot color - light grey
                      borderRadius: BorderRadius.circular(
                          3.0), // Rounded corners for dots
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Get Started Button - only shown on the last slide
          if (_showGetStartedButton)
            Align(
              alignment: Alignment.bottomCenter, // Position at bottom center
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 70.0), // Add bottom padding
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15), // Button padding
                    backgroundColor: const Color.fromARGB(
                        255, 170, 107, 0), // Golden brown button
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // Rounded button corners
                    ),
                  ),
                  onPressed: () async {
                    // Save that onboarding is complete in shared preferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('onboarding_complete', true);
                    widget
                        .onFinish(); // Call the provided callback to finish onboarding
                  },
                  child: const Text(
                    "Get Started", // Button text
                    style: TextStyle(
                      fontSize: 18, // Larger text size for button
                      color: Color.fromARGB(255, 255, 255, 255), // White text
                    ),
                  ),
                ),
              ),
            ), // App version text in bottom right corner with enhanced styling
          Positioned(
            bottom: 10, // Position from bottom
            right: 10, // Position from right
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(
                    51), // 0.2 opacity = roughly 51 as alpha value (0.2 * 255)
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "v2.0.0", // Updated version number text
                style: TextStyle(
                  color: Color.fromARGB(
                      255, 255, 241, 198), // Cream color for better visibility
                  fontSize: 12, // Small text size
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
