// This file implements the help page interface that provides user guidance on how to use the application
// It contains two main widget classes: HelpStep and HelpPage

import 'package:flutter/material.dart'; // Import Material Design package
import 'widgets/guide_book_button.dart'; // Import custom GuideBookButton widget

/// HelpStep widget represents a single help instruction with an image and text
class HelpStep extends StatelessWidget {
  final String imagePath; // Path to the image for this help step
  final String text; // Descriptive text explaining this step
  final IconData icon; // Icon for the instruction
  final String tooltip; // Tooltip text for detailed explanation

  // Constructor requiring image path and text with optional parameters
  const HelpStep(this.imagePath, this.text,
      {this.icon = Icons.check_circle_outline, this.tooltip = '', super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.help,
              child: Tooltip(
                message: tooltip.isNotEmpty ? tooltip : text,
                preferBelow: true,
                showDuration: const Duration(seconds: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF3E2C1C),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                textStyle: const TextStyle(
                  color: Color(0xFFF3E5AB),
                  fontSize: 14,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3E2C1C)
                        .withAlpha(26), // Changed from withOpacity to withAlpha
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: const Color(0xFF3E2C1C),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Color(0xFF3E2C1C),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 200, // Slightly increased image height
                width: double.infinity, // Image takes full width
              ),
            ),
          ],
        ),
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
        title: const Text("Help Guide"), // Enhanced page title
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
              padding: const EdgeInsets.symmetric(
                  vertical: 24.0, horizontal: 16.0), // Adjusted padding
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5AB).withAlpha(
                      243), // Changed from withOpacity(0.95) to withAlpha(243)
                  borderRadius:
                      BorderRadius.circular(20.0), // More rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(
                          38), // Changed from withOpacity(0.15) to withAlpha(38)
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24.0), // Increased inner padding
                margin: const EdgeInsets.only(bottom: 20.0), // Bottom margin
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Left-align content
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.help_outline,
                          color: Color(0xFF3E2C1C),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "How to use the application", // Section title without colon
                            style: TextStyle(
                              fontSize: 24, // Large title text
                              fontWeight: FontWeight.bold, // Bold text
                              color: Color(0xFF3E2C1C), // Dark brown text color
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      color: Color(0xFF3E2C1C),
                      thickness: 1.0,
                      height: 32.0,
                    ), // Decorative divider

                    // List of help steps with images and instructions
                    const HelpStep(
                      'images/help/step1.png',
                      "1. Click on the camera icon to take a picture or select an image from the gallery.",
                      icon: Icons.camera_alt_outlined,
                      tooltip: "Use the camera or gallery to provide an image.",
                    ),
                    const HelpStep(
                      'images/help/step2.png',
                      "2. Wait for the application to classify the image.",
                      icon: Icons.hourglass_empty,
                      tooltip: "The app will process the image to classify it.",
                    ),
                    const HelpStep(
                      'images/help/step3.png',
                      "3. View the prediction result displayed on the screen.",
                      icon: Icons.visibility_outlined,
                      tooltip:
                          "Check the screen for the classification result.",
                    ),
                    const HelpStep(
                      'images/help/step4.png',
                      "4. You can view the history of previous predictions by clicking on the history icon.",
                      icon: Icons.history,
                      tooltip:
                          "Access past predictions in the history section.",
                    ),
                    const HelpStep(
                      'images/help/step5.png',
                      "5. For more information about the application, click on the info icon.",
                      icon: Icons.info_outline,
                      tooltip: "Find additional details in the info section.",
                    ),

                    const SizedBox(height: 16),
                    MouseRegion(
                      cursor: SystemMouseCursors.help,
                      child: Tooltip(
                        message:
                            "Contact us at support@flutterby.com or visit our website for more resources",
                        preferBelow: false,
                        showDuration: const Duration(seconds: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E2C1C),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(
                          color: Color(0xFFF3E5AB),
                          fontSize: 14,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E2C1C).withAlpha(26),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: const Color(0xFF3E2C1C).withAlpha(77),
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF3E2C1C),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "For additional assistance, please check the guidebook or contact support.",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF3E2C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
