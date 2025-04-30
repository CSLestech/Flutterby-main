import 'package:flutter/material.dart'; // Core Flutter UI framework

/// BackgroundWrapper creates a consistent visual background for application screens
/// It applies a textured background image with an optional darker overlay for better readability of foreground content
class BackgroundWrapper extends StatelessWidget {
  final Widget
      child; // The foreground content to display on top of the background

  /// Constructor requiring the foreground child widget
  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Stack widget to layer background, overlay, and content
      children: [
        // Background image - fills the entire screen
        SizedBox.expand(
          // Expand to fill available space
          child: Image.asset(
            'images/ui/main_bg.png', // Path to the background texture image
            fit: BoxFit
                .cover, // Scale image to cover the entire area without distortion
          ),
        ),

        // Optional overlay - adds slight darkening for better foreground visibility
        Container(
          color: Colors.black
              .withAlpha(77), // Semi-transparent black (30% opacity)
        ),

        // The foreground content
        child, // Display the provided widget on top of background and overlay
      ],
    );
  }
}
