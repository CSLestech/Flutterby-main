// This file defines a simple settings page for the application
// Currently, it's a placeholder that can be expanded with actual settings in future versions

import 'package:flutter/material.dart'; // Import Material Design package

/// SettingsPage is a placeholder widget for potential future settings functionality
class SettingsPage extends StatelessWidget {
  // Constructor with optional key parameter
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'), // Page title
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
      ),
      body: const Center(
        child: Text(
          'No settings available.', // Placeholder message
          style: TextStyle(
            fontSize: 20, // Large text size
            fontWeight: FontWeight.bold, // Bold text
            fontFamily: 'Garamond', // Match app font
            color: Color(0xFF3E2C1C), // Dark brown text color
          ),
        ),
      ),
    );
  }
}
