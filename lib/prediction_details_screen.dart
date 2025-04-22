import 'package:flutter/material.dart';
import 'dart:io';

class PredictionDetailsScreen extends StatelessWidget {
  final String? imagePath;
  final Map<String, dynamic> prediction;
  final String timestamp;

  const PredictionDetailsScreen({
    super.key,
    required this.imagePath,
    required this.prediction,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Details"),
        centerTitle: true,
        backgroundColor: const Color(0xFF3E2C1C), // Warm brown color
        titleTextStyle: const TextStyle(
          fontFamily: "Garamond",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF3E5AB), // Light cream color
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/ui/main_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay
          Container(
            color: Colors.black.withAlpha(77), // ~30% opacity
          ),

          // Foreground content
          SingleChildScrollView(
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
        ],
      ),
    );
  }
}
