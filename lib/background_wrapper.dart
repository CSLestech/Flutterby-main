// This file defines the BackgroundWrapper widget that provides consistent background styling
// It's used across multiple screens to maintain visual consistency in the app

import 'package:flutter/material.dart'; // Import Material Design package

/// BackgroundWrapper applies a consistent background style to child widgets
/// It includes a background image and optional semi-transparent overlay for better readability
class BackgroundWrapper extends StatelessWidget {
  final Widget child; // The child widget to display on top of the background
  final bool
      showOverlay; // Whether to show a semi-transparent overlay over the background

  // Constructor requiring child widget with optional overlay parameter
  const BackgroundWrapper({
    super.key,
    required this.child,
    this.showOverlay = true, // Default to showing the overlay
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image layer - positioned to fill the entire container
        Positioned.fill(
          child: Image.asset(
            'images/ui/main_bg.png', // Background image path
            fit: BoxFit.cover, // Scale image to cover entire background
          ),
        ),

        // Optional semi-transparent overlay to improve text readability
        if (showOverlay)
          Container(
            color:
                Colors.black.withAlpha(100), // Semi-transparent black overlay
          ),

        // The main content displayed on top of the background
        child,
      ],
    );
  }
}
