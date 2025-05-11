import 'package:flutter/material.dart';
import 'chicken_analysis_mockup.dart';

void main() {
  runApp(const MockupDemoApp());
}

class MockupDemoApp extends StatelessWidget {
  const MockupDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chicken Analysis Mockup',
      theme: ThemeData(
        primaryColor: const Color(0xFF3E2C1C),
        scaffoldBackgroundColor: const Color(0xFFF3E5AB),
      ),
      home: const MockupLauncher(),
    );
  }
}

class MockupLauncher extends StatelessWidget {
  const MockupLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2C1C),
        title: const Text(
          'Chicken Analysis Mockup Demo',
          style: TextStyle(
            color: Color(0xFFF3E5AB),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This is a simple demo of how the chicken analysis\nwith bounding boxes would look',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF3E2C1C),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Use an empty string for the demo
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChickenAnalysisMockup(
                      imagePath: '', // No image path needed
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E2C1C),
                foregroundColor: const Color(0xFFF3E5AB),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Mockup Demo',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
