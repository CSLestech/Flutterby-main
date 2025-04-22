import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboardingscreen.dart'; // Import the OnboardingScreen
import 'home_view.dart'; // Import the HomeView from home_view.dart

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const CadApp());
}

class CadApp extends StatelessWidget {
  const CadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3E2C1C),
          elevation: 4,
          iconTheme: IconThemeData(color: Color(0xFFF3E5AB)),
          titleTextStyle: TextStyle(
            color: Color(0xFFF3E5AB),
            fontFamily: 'Garamond',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        primarySwatch: Colors.purple,
      ),
      home: const SplashScreen(), // Directly use SplashScreen
    );
  }
}

class FixedSizeWrapper extends StatelessWidget {
  final Widget child;

  const FixedSizeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width, // Use full screen width
          maxHeight:
              MediaQuery.of(context).size.height, // Use full screen height
        ),
        child: child,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _onboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;

    setState(() {
      _onboardingComplete = onboardingComplete;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_onboardingComplete) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const HomeView()), // Use HomeView from home_view.dart
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingScreen(
              onFinish: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const HomeView()), // Use HomeView from home_view.dart
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
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
