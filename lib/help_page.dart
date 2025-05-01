// This file implements the help page interface that provides user guidance on how to use the application
// It contains two main widget classes: HelpStep and HelpPage

import 'package:flutter/material.dart'; // Import Material Design package
import 'widgets/guide_book_button.dart'; // Import custom GuideBookButton widget

/// HelpStep widget represents a single help instruction with an image and text
class HelpStep extends StatelessWidget {
  final String imagePath; // Path to the image for this help step
  final String text; // Descriptive text explaining this step

  // Constructor requiring image path and text with an optional key parameter
  const HelpStep(this.imagePath, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0), // Add space below each step
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align content to the left
        children: [
          Text(
            text, // Display the step instruction text
            style: const TextStyle(
              color: Color(0xFF3E2C1C), // Dark brown text color
              fontSize: 16, // Set text size
            ),
          ),
          const SizedBox(
              height: 12), // Add vertical spacing between text and image
          Center(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(12), // Rounded corners for the image
              child: Image.asset(
                imagePath, // Display the help step image
                fit: BoxFit.cover, // Scale image to cover the given dimensions
                height: 180, // Fixed image height
                width: 300, // Fixed image width
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// HelpPage widget displays the full help guide with multiple steps
class HelpPage extends StatelessWidget {
  final VoidCallback onBackToHome; // Callback function for back button

  // Constructor requiring the back navigation callback
  const HelpPage({super.key, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2C1C), // Dark brown app bar
        elevation: 4, // Add shadow beneath the app bar
        iconTheme: const IconThemeData(
            color: Color(0xFFF3E5AB)), // Light beige icon color
        titleTextStyle: const TextStyle(
          color: Color(0xFFF3E5AB), // Light beige text color
          fontFamily: 'Garamond', // Custom font family
          fontSize: 22, // Larger font size for title
          fontWeight: FontWeight.w600, // Semi-bold font weight
        ),
        title: const Text("Help"), // Page title
        leading: IconButton(
          // Back button
          icon: const Icon(Icons.arrow_back),
          onPressed:
              onBackToHome, // Call the provided callback to return to home
        ),
        actions: const [
          GuideBookButton(), // Add guide book button to app bar
        ],
      ),
      body: Stack(
        children: [
          // Background image layer
          Positioned.fill(
            child: Image.asset(
              'images/ui/main_bg.png', // Background image path
              fit: BoxFit.cover, // Scale image to cover entire background
            ),
          ),

          // Semi-transparent overlay to improve text readability
          Container(
            color: Colors.black
                .withAlpha(77), // Add dark overlay with transparency
          ),

          // Main help content
          DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'Garamond', // Set default font for all text
              fontSize: 16, // Default text size
              color: Color(0xFF3E2C1C), // Dark brown text color
            ),
            child: SingleChildScrollView(
              // Make content scrollable
              padding: const EdgeInsets.all(24.0), // Add padding around content
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5AB), // Light beige background
                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                ),
                padding: const EdgeInsets.all(20.0), // Inner padding
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Left-align content
                  children: [
                    const Text(
                      "How to use the application:", // Section title
                      style: TextStyle(
                        fontSize: 24, // Large title text
                        fontWeight: FontWeight.bold, // Bold text
                        color: Color(0xFF3E2C1C), // Dark brown text color
                      ),
                    ),
                    const SizedBox(height: 20), // Add vertical spacing

                    // List of help steps with images and instructions
                    const HelpStep(
                      'images/help/step1.png',
                      "1. Click on the camera icon to take a picture or select an image from the gallery.",
                    ),
                    const HelpStep(
                      'images/help/step2.png',
                      "2. Wait for the application to classify the image.",
                    ),
                    const HelpStep(
                      'images/help/step3.png',
                      "3. View the prediction result displayed on the screen.",
                    ),
                    const HelpStep(
                      'images/help/step4.png',
                      "4. You can view the history of previous predictions by clicking on the history icon.",
                    ),
                    const HelpStep(
                      'images/help/step5.png',
                      "5. For more information about the application, click on the info icon.",
                    ),
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
