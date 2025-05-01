import 'package:flutter/material.dart'; // Importing Flutter's material design package

/// A custom loading screen widget that shows a branded loading experience
/// Features the app logo, name, and an optional message with a loading indicator
class CustomLoadingScreen extends StatelessWidget {
  final String? message; // Optional message to display during loading

  // Constructor with optional message parameter
  const CustomLoadingScreen({
    super.key,
    this.message, // Message to show below the app name (e.g., "Analyzing chicken image...")
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          const Color(0xFF3E2C1C), // App's primary brown color for background
      width: double.infinity, // Make container fill the width
      height: double.infinity, // Make container fill the height
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center content vertically
        children: [
          // Chicken logo in perfectly circular container
          Container(
            width: 120, // Fixed width for logo container
            height: 120, // Fixed height for logo container (square)
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Makes container perfectly circular
              color: const Color.fromRGBO(
                  255, 255, 255, 0.15), // Semi-transparent white background
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0), // Padding around the logo
              child: Image.asset(
                'images/ui/logo.png', // Path to the app logo image
                fit:
                    BoxFit.contain, // Ensure the logo fits within the container
              ),
            ),
          ),

          const SizedBox(
              height: 30), // Vertical spacing between logo and app name

          // App name text - explicitly no text decoration to avoid
          const Text(
            "Check-a-Doodle-Doo", // Name of the app displayed on loading screen
            style: TextStyle(
              color: Color(
                  0xFFF3E5AB), // Light beige color for contrast against brown
              fontFamily: 'Garamond', // Custom font for app branding
              fontSize: 24, // Larger font size for app name
              fontWeight: FontWeight.bold, // Bold for emphasis
              decoration: TextDecoration
                  .none, // Explicitly set no decoration to prevent underline
            ),
          ),

          const SizedBox(
              height: 10), // Spacing between app name and message (if any)

          // Optional message text - displayed only if provided
          if (message != null) // Conditional display of message
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 40.0), // Horizontal padding for message
              child: Text(
                message!, // Display the provided message
                textAlign: TextAlign.center, // Center-align text
                style: const TextStyle(
                  color: Color(
                      0xFFF3E5AB), // Same color as app name for consistency
                  fontFamily: 'Garamond', // Same font as app name
                  fontSize: 16, // Smaller than app name
                  decoration:
                      TextDecoration.none, // Explicitly prevent text decoration
                ),
              ),
            ),

          const SizedBox(
              height: 40), // Spacing between message and loading indicator

          // Loading indicator - circular progress animation
          const CircularProgressIndicator(
            color:
                Color(0xFFF3E5AB), // Color matches text for visual consistency
            strokeWidth: 3, // Thickness of the circular progress indicator
          ),
        ],
      ),
    );
  }
}
