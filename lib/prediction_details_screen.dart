import 'package:flutter/material.dart';
import 'dart:io';
// Use prefix for one of the imports with the BackgroundWrapper class
import 'package:check_a_doodle_doo/background_wrapper.dart' as bg;
import 'widgets/guide_book_button.dart';
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
        actions: const [
          GuideBookButton(),
        ],
      ),
      body: bg.BackgroundWrapper(
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centers content vertically
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Image centered vertically with increased height
                    if (imagePath != null && File(imagePath!).existsSync())
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          File(imagePath!),
                          height: 600, // Increased from 280
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),

                    const SizedBox(height: 30), // Increased from 20

                    // Prediction container (remains the same)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        color:
                            _getPredictionBackgroundColor(prediction['text']),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  prediction['icon'] as IconData? ??
                                      Icons.help_outline,
                                  color: prediction['color'] as Color? ??
                                      Colors.grey,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  prediction['text'] as String? ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Garamond',
                                    color: _getPredictionTextColor(
                                        prediction['text']),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Divider(
                              color:
                                  _getPredictionBorderColor(prediction['text'])
                                      .withAlpha(
                                          77), // Changed from withOpacity(0.3)
                              thickness: 1,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Uploaded on: $timestamp",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                fontFamily: "Garamond",
                                color: _getPredictionTextColor(
                                        prediction['text'])
                                    .withAlpha(
                                        204), // Changed from withOpacity(0.8)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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

  Color _getPredictionBackgroundColor(String? prediction) {
    switch (prediction) {
      case 'Consumable':
        return const Color(0xFFE8F5E9); // Light green background
      case 'Half-Consumable':
        return const Color(0xFFFFF8E1); // Light amber background
      case 'Not Consumable':
        return const Color(0xFFFFEBEE); // Light red background
      default:
        return const Color(0xFFEFEFEF); // Light grey as default
    }
  }

  Color _getPredictionBorderColor(String? prediction) {
    switch (prediction) {
      case 'Consumable':
        return Colors.green.shade700;
      case 'Half-Consumable':
        return Colors.orange.shade700;
      case 'Not Consumable':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getPredictionTextColor(String? prediction) {
    switch (prediction) {
      case 'Consumable':
        return Colors.green.shade800;
      case 'Half-Consumable':
        return Colors.orange.shade900;
      case 'Not Consumable':
        return Colors.red.shade900;
      default:
        return Colors.grey.shade800;
    }
  }
}
