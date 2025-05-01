// This file defines the About page interface that displays information about the application
// It contains a single widget class: AboutPage

import 'package:flutter/material.dart'; // Import Material Design package
import 'widgets/guide_book_button.dart'; // Import custom GuideBookButton widget

/// AboutPage widget displays information about the application, its purpose and developers
class AboutPage extends StatelessWidget {
  final VoidCallback
      onBackToHome; // Callback function for back button navigation

  // Constructor requiring the back navigation callback
  const AboutPage({super.key, required this.onBackToHome});

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
        title: const Text("About"), // Page title
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

          // Main about content
          SingleChildScrollView(
            // Make content scrollable
            padding: const EdgeInsets.all(24.0), // Add padding around content
            child: DefaultTextStyle(
              // Set default text styling for all child text widgets
              style: const TextStyle(
                fontFamily: 'Garamond', // Set default font for all text
                fontSize: 16, // Default text size
                color: Color(0xFF3E2C1C), // Dark brown text color
              ),
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
                    const Center(
                      // Center-align the logo
                      child: CircleAvatar(
                        radius: 60, // Set logo size
                        backgroundColor:
                            Colors.white, // White background for logo
                        child: ClipOval(
                          child: Image(
                            image: AssetImage(
                                'images/ui/logo.png'), // App logo image
                            width: 100, // Logo width
                            height: 100, // Logo height
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Add vertical spacing

                    // App title and version
                    const Center(
                      child: Text(
                        "Check-a-doodle-doo",
                        style: TextStyle(
                          fontSize: 24, // Large title text
                          fontWeight: FontWeight.bold, // Bold text
                          color: Color(0xFF3E2C1C), // Dark brown text color
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Version 1.0.0", // App version number
                        style: TextStyle(
                          fontSize: 16, // Medium text size
                          fontStyle: FontStyle.italic, // Italic style
                          color: Color(0xFF3E2C1C), // Dark brown text color
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Add vertical spacing

                    // App description header
                    const Text(
                      "Description:",
                      style: TextStyle(
                        fontSize: 18, // Medium-large text size
                        fontWeight: FontWeight.bold, // Bold text
                        color: Color(0xFF3E2C1C), // Dark brown text color
                      ),
                    ),
                    const SizedBox(height: 10), // Add vertical spacing

                    // App description paragraphs
                    const Text(
                      "Check-a-doodle-doo is an application designed to help users determine if chicken is safe to consume based on its appearance.",
                      style: TextStyle(
                        fontSize: 16, // Medium text size
                        color: Color(0xFF3E2C1C), // Dark brown text color
                      ),
                    ),
                    const SizedBox(height: 10), // Add vertical spacing

                    const Text(
                      "Using machine learning technology, the application can analyze images of chicken meat and classify them into three categories: Consumable, Half-consumable, and Not consumable.",
                      style: TextStyle(
                        fontSize: 16, // Medium text size
                        color: Color(0xFF3E2C1C), // Dark brown text color
                      ),
                    ),
                    const SizedBox(height: 20), // Add vertical spacing

                    // Features section header
                    const Text(
                      "Features:",
                      style: TextStyle(
                        fontSize: 18, // Medium-large text size
                        fontWeight: FontWeight.bold, // Bold text
                        color: Color(0xFF3E2C1C), // Dark brown text color
                      ),
                    ),
                    const SizedBox(height: 10), // Add vertical spacing

                    // Feature list with bullet points
                    _buildFeatureItem(
                        "Take photos of chicken meat for analysis"),
                    _buildFeatureItem("Upload existing photos from gallery"),
                    _buildFeatureItem("Get instant classification results"),
                    _buildFeatureItem("View history of previous analyses"),
                    _buildFeatureItem(
                        "User-friendly interface with detailed help"),
                    const SizedBox(height: 20), // Add vertical spacing

                    // Developers section header
                    const Text(
                      "Developed by:",
                      style: TextStyle(
                        fontSize: 18, // Medium-large text size
                        fontWeight: FontWeight.bold, // Bold text
                        color: Color(0xFF3E2C1C), // Dark brown text color
                      ),
                    ),
                    const SizedBox(height: 10), // Add vertical spacing

                    // Developer information
                    const Text(
                      "Tipian Students", // Development team name
                      style: TextStyle(
                        fontSize: 16, // Medium text size
                        fontWeight: FontWeight.bold, // Bold text
                        color: Color(0xFF3E2C1C), // Dark brown text color
                      ),
                    ),
                    const SizedBox(height: 10), // Add vertical spacing

                    // Individual developer profiles with images
                    _buildDeveloperProfile(
                        name: "Leslie Ann Enriquez",
                        role: "Main Developer",
                        imagePath: "images/devs/Enriquez.png"),
                    _buildDeveloperProfile(
                        name: "Ernest Marshal Oropesa",
                        role: "UI/UX Designer",
                        imagePath: "images/devs/Oropesa.png"),
                    _buildDeveloperProfile(
                        name: "Melissa Dollano",
                        role: "ML Engineer",
                        imagePath: "images/dollano.jpg"),
                    const SizedBox(height: 5), // Add small vertical spacing

                    const Text(
                      "For educational purposes only.", // Disclaimer text
                      style: TextStyle(
                        fontSize: 14, // Smaller text size
                        fontStyle: FontStyle.italic, // Italic style
                        color: Color(0xFF3E2C1C), // Dark brown text color
                      ),
                    ),
                    const SizedBox(height: 20), // Add vertical spacing

                    // Disclaimer section
                    Container(
                      padding: const EdgeInsets.all(
                          10), // Add padding inside container
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(
                            51), // Light orange background (opacity 0.2 ≈ 51/255)
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                        border:
                            Border.all(color: Colors.orange), // Orange border
                      ),
                      child: const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Left-align content
                        children: [
                          Text(
                            "Disclaimer:", // Disclaimer header
                            style: TextStyle(
                              fontSize: 16, // Medium text size
                              fontWeight: FontWeight.bold, // Bold text
                              color: Color(0xFF3E2C1C), // Dark brown text color
                            ),
                          ),
                          SizedBox(height: 5), // Add small vertical spacing
                          Text(
                            "This app provides an estimate based on visual appearance and should not be the sole factor in determining food safety. Always use proper food handling practices and when in doubt, throw it out.", // Disclaimer text
                            style: TextStyle(
                              fontSize: 14, // Smaller text size
                              color: Color(0xFF3E2C1C), // Dark brown text color
                            ),
                          ),
                        ],
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

  /// Helper method to build a feature list item with a bullet point
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Add space below each item
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
        children: [
          const Text("• ",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)), // Bullet point
          Expanded(
            // Allow text to fill remaining space and wrap if needed
            child: Text(
              text, // Feature description text
              style: const TextStyle(fontSize: 16), // Medium text size
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build a developer profile with image and details
  Widget _buildDeveloperProfile({
    required String name,
    required String role,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          // Developer profile image
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(imagePath),
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback if image fails to load
              return;
            },
          ),
          const SizedBox(width: 12),
          // Developer details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2C1C),
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF3E2C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
