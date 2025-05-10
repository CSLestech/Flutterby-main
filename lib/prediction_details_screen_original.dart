// Original file backup created for reference
// This is the original prediction_details_screen.dart before adding bounding box and analysis breakdown features

import 'dart:io';

import 'package:flutter/material.dart';

class PredictionDetailsScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> prediction;
  final String timestamp;
  final Function(int) onNavigate;
  const PredictionDetailsScreen({
    super.key,
    required this.imagePath,
    required this.prediction,
    required this.timestamp,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Details'),
        backgroundColor: const Color(0xFF3E2C1C),
        foregroundColor: const Color(0xFFF3E5AB),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality could be implemented here
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/ui/main_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color(0xFFF3E5AB),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            prediction['icon'],
                            color: prediction['color'],
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            prediction['text'],
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: prediction['color'],
                              fontFamily: "Garamond",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Confidence Score: ${((prediction['confidenceScore'] ?? 0.0) * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: "Garamond",
                          color: Color(0xFF3E2C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Image taken on: $timestamp',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Garamond",
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
