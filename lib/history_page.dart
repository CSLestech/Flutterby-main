// This file implements the history page that displays a list of past predictions
// It includes two widget classes: HistoryPage for the main list view and HistoryDetailPage for viewing individual predictions

import 'package:flutter/material.dart'; // Import Flutter's Material Design package
import 'dart:io'; // Import for File handling to display saved images
import 'package:check_a_doodle_doo/background_wrapper.dart'; // Import custom background wrapper component
import 'package:check_a_doodle_doo/prediction_details_screen.dart'; // Import screen to display prediction details
import 'dart:developer' as dev; // Import developer tools for logging
import 'widgets/guide_book_button.dart'; // Import custom guide book button widget
import 'package:check_a_doodle_doo/utils/confidence_tracker.dart'; // Import confidence tracker utility

/// HistoryPage displays a scrollable list of past prediction results
class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history; // List of prediction history items
  final VoidCallback onBackToHome; // Callback function to navigate back to home

  // Constructor requiring history data and back navigation callback
  const HistoryPage({
    super.key,
    required this.history,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF3E2C1C), // Dark brown app bar background
        elevation: 4, // Add shadow beneath the app bar
        iconTheme: const IconThemeData(
            color: Color(0xFFF3E5AB)), // Light beige icon color
        titleTextStyle: const TextStyle(
          color: Color(0xFFF3E5AB), // Light beige text color
          fontFamily: 'Garamond', // Custom font family
          fontSize: 22, // Larger font size for title
          fontWeight: FontWeight.w600, // Semi-bold font weight
        ),
        title: const Text("History"), // Page title
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
      body: BackgroundWrapper(
        // Apply custom background styling
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding around the list
          child: history.isEmpty
              ? const Center(
                  // Display message when no history is available
                  child: Text(
                    "No history available.",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Garamond",
                      color: Colors.white,
                    ),
                  ),
                )
              : ListView.builder(
                  // Create scrollable list of history items
                  itemCount: history.length, // Number of items to display
                  itemBuilder: (context, index) {
                    final item = history[index]; // Get current history item

                    // Debug validation for confidence score
                    final dynamic rawConfidence = item['confidenceScore'];
                    double confidenceScore = 0.0;
                    if (rawConfidence != null) {
                      if (rawConfidence is double) {
                        confidenceScore = rawConfidence;
                      } else if (rawConfidence is num) {
                        confidenceScore = rawConfidence.toDouble();
                      } else if (rawConfidence is String) {
                        confidenceScore = double.tryParse(rawConfidence) ?? 0.0;
                      }
                    }

                    dev.log("History item $index confidence: $confidenceScore",
                        name: 'HistoryPage');

                    return Card(
                      // Create card for each history item
                      margin: const EdgeInsets.only(
                          bottom: 12), // Add space between cards
                      color: const Color(
                          0xFFF3E5AB), // Light beige card background
                      elevation: 4, // Add shadow to the card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            12), // Rounded corners for cards
                      ),
                      child: InkWell(
                        // Make card clickable with ripple effect
                        borderRadius: BorderRadius.circular(
                            12), // Round corners for ripple
                        onTap: () {
                          // Track confidence before navigation
                          ConfidenceTracker.logScore("HISTORY_ITEM_TAP",
                              item['confidenceScore'], {'index': index});
                          Navigator.push(
                            // Navigate to details screen when tapped
                            context,
                            MaterialPageRoute(
                              builder: (context) => PredictionDetailsScreen(
                                imagePath: item['imagePath'], // Pass image path
                                prediction: {
                                  'text': item['text'], // Pass prediction text
                                  'icon': item['icon'], // Pass prediction icon
                                  'color':
                                      item['color'], // Pass prediction color

                                  // CRITICAL FIX: Pass confidence score from history item
                                  'confidenceScore':
                                      item['confidenceScore'] ?? 0.75,

                                  // CRITICAL FIX: Also pass processing time from history item
                                  'processingTime': item['processingTime'],

                                  // Mark this as coming from history to help with fallbacks
                                  'fromHistory': true,
                                },
                                timestamp: item['timestamp'], // Pass timestamp
                                onNavigate:
                                    (int _) {}, // Add empty onNavigate callback
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(
                              12.0), // Add padding inside the card
                          child: Row(
                            children: [
                              if (item['imagePath'] !=
                                  null) // Display image if available
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      8), // Round corners for image
                                  child: Image.file(
                                    File(item[
                                        'imagePath']), // Load image from file path
                                    width: 80, // Fixed image width
                                    height: 80, // Fixed image height
                                    fit: BoxFit
                                        .cover, // Scale image to cover dimensions
                                    errorBuilder: (context, error, stackTrace) {
                                      dev.log(
                                          "Error loading image: $error", // Log errors
                                          name: 'HistoryPage');
                                      return Container(
                                        // Show placeholder on error
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                            Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                )
                              else // Show placeholder if no image path
                                Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              const SizedBox(
                                  width: 16), // Add horizontal spacing
                              Expanded(
                                // Flexible content that fills available space
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // Left-align text
                                  children: [
                                    Row(
                                      children: [
                                        if (item['icon'] !=
                                            null) // Display icon if available
                                          Icon(
                                            item['icon'],
                                            color: item[
                                                'color'], // Use prediction color for icon
                                          ),
                                        const SizedBox(
                                            width: 8), // Add horizontal spacing
                                        Expanded(
                                          // Allow text to fill remaining space and wrap if needed
                                          child: Text(
                                            item['text'] ??
                                                'Unknown', // Display prediction text
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: item[
                                                  'color'], // Use prediction color for text
                                              fontFamily: "Garamond",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height: 8), // Add vertical spacing
                                    Text(
                                      "Uploaded on: ${item['timestamp'] ?? 'Unknown date'}", // Show timestamp
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Garamond",
                                      ),
                                    ),

                                    // Add confidence score display in history list
                                    if (item.containsKey('confidenceScore') &&
                                        item['confidenceScore'] != null &&
                                        (item['confidenceScore'] as num)
                                                .toDouble() >
                                            0)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          "Confidence: ${((item['confidenceScore'] as num).toDouble() * 100).toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontFamily: "Garamond",
                                            fontStyle: FontStyle.italic,
                                            color: _getConfidenceColor(
                                                (item['confidenceScore'] as num)
                                                    .toDouble()),
                                          ),
                                        ),
                                      ),

                                    // Display processing time if available
                                    if (item.containsKey('processingTime') &&
                                        item['processingTime'] != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          "Processing: ${(item['processingTime'] as num).toStringAsFixed(2)}s",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontFamily: "Garamond",
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(Icons
                                  .chevron_right), // Right chevron indicator for navigation
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  // Get color based on confidence level
  Color _getConfidenceColor(double score) {
    if (score >= 0.85) return Colors.green;
    if (score >= 0.70) return Colors.orange;
    if (score > 0.0) return Colors.red;
    return Colors.grey;
  }
}

/// HistoryDetailPage displays detailed information about a single prediction
class HistoryDetailPage extends StatelessWidget {
  final String? imagePath; // Path to the prediction image
  final Map<String, dynamic>
      prediction; // Prediction details including text, icon, and color
  final String timestamp; // When the prediction was made

  // Constructor requiring image path, prediction data, and timestamp
  const HistoryDetailPage({
    super.key,
    required this.imagePath,
    required this.prediction,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Details"), // Page title
        centerTitle: true, // Center align the title
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/ui/main_bg.png', // Background image path
              fit: BoxFit.cover, // Scale image to cover entire background
            ),
          ),

          // Dark overlay to improve text readability
          Container(
            color:
                Colors.black.withAlpha(77), // Add semi-transparent dark overlay
          ),

          // Foreground content
          SingleChildScrollView(
            // Make content scrollable
            padding: const EdgeInsets.all(16), // Add padding around content
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center-align content
              children: [
                if (imagePath != null &&
                    File(imagePath!)
                        .existsSync()) // Display image if available and exists
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 12), // Add space below image
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12), // Round corners for image
                      child: Image.file(
                        File(imagePath!), // Load image from file path
                        width: double.infinity, // Use full width
                        height: 300, // Fixed image height
                        fit: BoxFit.contain, // Scale image to fit dimensions
                      ),
                    ),
                  ),
                Text(
                  "Uploaded on: $timestamp", // Display timestamp
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Garamond",
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16), // Add vertical spacing
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center-align row contents
                  children: [
                    Icon(
                      prediction["icon"], // Display prediction icon
                      color:
                          prediction["color"], // Use prediction color for icon
                      size: 28, // Larger icon size
                    ),
                    const SizedBox(width: 8), // Add horizontal spacing
                    Text(
                      prediction["text"], // Display prediction text
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: prediction[
                            "color"], // Use prediction color for text
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
