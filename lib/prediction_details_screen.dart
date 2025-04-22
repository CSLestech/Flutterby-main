import 'package:flutter/material.dart';
import 'dart:io';
// Use prefix for one of the imports with the BackgroundWrapper class
import 'package:check_a_doodle_doo/background_wrapper.dart' as bg;
// Or comment out one of the imports if you're not using other parts of it
// import 'package:check_a_doodle_doo/home_view.dart';

class PredictionDetailsScreen extends StatelessWidget {
  final String? imagePath;
  final Map<String, dynamic> prediction;
  final String timestamp;
  final Function(int)? onNavigate; // Add this callback

  const PredictionDetailsScreen({
    super.key,
    required this.imagePath,
    required this.prediction,
    required this.timestamp,
    this.onNavigate, // Optional callback for navigation
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF3E2C1C), // Deep warm brown - match with home
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFFF3E5AB)), // Warm accent
        titleTextStyle: const TextStyle(
          color: Color(0xFFF3E5AB),
          fontFamily: 'Garamond',
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        title: const Text("Prediction Details"),
        centerTitle: false, // Match home style (left-aligned title)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Change this to navigate to History instead of just popping
            Navigator.pop(context);

            // This is handled in the parent HomeViewState
            // You'll need to update the _sendImageToServer method
          },
        ),
      ),
      body: bg.BackgroundWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (imagePath != null && File(imagePath!).existsSync())
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imagePath!),
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              Text(
                "Uploaded on: $timestamp",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Garamond",
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    prediction["icon"],
                    color: prediction["color"],
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    prediction["text"],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: prediction["color"],
                      fontFamily: "Garamond",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromARGB(255, 194, 184, 146),
          selectedItemColor: const Color(0xFF3E2C1C),
          unselectedItemColor: Colors.black.withAlpha(77),
          currentIndex: 1, // Set to History (index 1)
          onTap: (index) {
            Navigator.pop(context);
            if (onNavigate != null) {
              onNavigate!(index);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'About',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.help),
              label: 'Help',
            ),
          ],
        ),
      ),
    );
  }
}
