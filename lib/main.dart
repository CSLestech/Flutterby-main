// This file is the entry point of the application
// It sets up the application theme, initializes the app, and manages the splash screen and navigation to home

import 'package:flutter/material.dart'; // Import Material Design package
import 'package:flutter/services.dart'; // Import services for platform integration
import 'package:shared_preferences/shared_preferences.dart'; // Import for local data storage
import 'onboardingscreen.dart'; // Import onboarding screen for first-time users
import 'home_view.dart'; // Import the main home view
import 'widgets/custom_loading_screen.dart'; // Import custom loading screen widget

/// Main function - entry point of the application
void main() {
  // Set system UI overlay style to ensure status bar and navigation bar look good
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor:
          Colors.transparent, // Transparent navigation bar
      statusBarBrightness: Brightness.light, // Light status bar content
      statusBarColor: Colors.transparent, // Transparent status bar background
    ),
  );
  runApp(const CadApp()); // Launch the app
}

/// CadApp is the root widget of the application
class CadApp extends StatelessWidget {
  const CadApp({super.key}); // Constructor with optional key parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner in the corner
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3E2C1C), // Dark brown app bar background
          elevation: 4, // Add shadow beneath the app bar
          iconTheme:
              IconThemeData(color: Color(0xFFF3E5AB)), // Light beige icon color
          titleTextStyle: TextStyle(
            color: Color(0xFFF3E5AB), // Light beige text color
            fontFamily: 'Garamond', // Custom font family
            fontSize: 22, // Larger font size for title
            fontWeight: FontWeight.w600, // Semi-bold font weight
          ),
        ),
        primarySwatch: Colors.purple, // Set primary color palette
      ),
      home: const SplashScreen(), // Show splash screen when app starts
    );
  }
}

/// FixedSizeWrapper constrains its child to the specified dimensions
class FixedSizeWrapper extends StatelessWidget {
  final Widget child; // The child widget to constrain

  const FixedSizeWrapper(
      {super.key, required this.child}); // Constructor requiring child widget

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width, // Use full screen width
          maxHeight:
              MediaQuery.of(context).size.height, // Use full screen height
        ),
        child: child, // Display the child widget
      ),
    );
  }
}

/// SplashScreen shows a loading screen and determines where to navigate next
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // Constructor with optional key parameter

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState(); // Create state for this widget
}

class _SplashScreenState extends State<SplashScreen> {
  bool _onboardingComplete =
      false; // Track whether onboarding has been completed

  @override
  void initState() {
    super.initState(); // Call parent's initState
    _checkOnboardingStatus(); // Check if user has completed onboarding
  }

  /// Checks if the user has completed onboarding by reading from shared preferences
  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences
        .getInstance(); // Get access to shared preferences
    final onboardingComplete = prefs.getBool('onboarding_complete') ??
        false; // Get onboarding status, default to false

    if (!mounted) return; // Safety check to ensure widget is still in tree

    setState(() {
      _onboardingComplete =
          onboardingComplete; // Update state with onboarding status
    });

    // After 3 seconds, navigate to either onboarding or home based on status
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; // Safety check to ensure widget is still in tree
      if (_onboardingComplete) {
        // If onboarding is complete, navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      } else {
        // If onboarding is not complete, navigate to onboarding screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(
              onFinish: () {
                // When onboarding finishes, navigate to home screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeView()),
                );
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomLoadingScreen(
        message: "Starting up...", // Display starting message on loading screen
      ),
    );
  }
}
