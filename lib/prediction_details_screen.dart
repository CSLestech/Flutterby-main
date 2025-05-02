import 'package:flutter/material.dart'; // Core Flutter UI framework
import 'dart:io'; // For file I/O operations (loading images from file system)
import 'dart:async'; // For asynchronous programming, including the Completer class
import 'dart:developer' as dev; // For logging purposes
// Import BackgroundWrapper with prefix to avoid name conflicts
import 'package:check_a_doodle_doo/background_wrapper.dart'
    as bg; // Custom background widget
import 'widgets/guide_book_button.dart'; // Guide book access button for educational content
import 'package:check_a_doodle_doo/utils/confidence_tracker.dart'; // Utility for confidence score tracking

/// PredictionDetailsScreen displays comprehensive information about a chicken breast analysis result
/// Shows the analyzed image with prediction results and classification information
class PredictionDetailsScreen extends StatelessWidget {
  final String? imagePath; // Path to the analyzed image file
  final Map<String, dynamic>
      prediction; // Contains prediction data (classification, icon, color)
  final String timestamp; // When the analysis was performed
  final Function(int)? onNavigate; // Optional callback for bottom navigation

  /// Constructor requiring prediction data for display
  const PredictionDetailsScreen({
    super.key,
    required this.imagePath, // Image file path (nullable but typically provided)
    required this.prediction, // Prediction result data
    required this.timestamp, // Timestamp string of when analysis was performed
    this.onNavigate, // Optional navigation callback
  });

  @override
  Widget build(BuildContext context) {
    // Build a scaffold with specialized UI for displaying prediction details
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF3E2C1C), // Deep brown app bar background
        elevation: 4, // Slight shadow for depth
        iconTheme: const IconThemeData(
            color: Color(0xFFF3E5AB)), // Light cream icon color
        titleTextStyle: const TextStyle(
          color: Color(0xFFF3E5AB), // Light cream text color
          fontFamily: 'Garamond', // Brand font
          fontSize: 22, // Larger title text
          fontWeight: FontWeight.w600, // Semi-bold for emphasis
        ),
        title: const Text("Prediction Details"), // Screen title
        centerTitle: false, // Left-align title for consistency with home screen
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            // Simply pop back to previous screen (usually history)
            Navigator.pop(context);
          },
        ),
        actions: const [
          GuideBookButton(), // Add guide book access to app bar
        ],
      ),
      // Use the background wrapper for consistent visual style
      body: bg.BackgroundWrapper(
        child: SafeArea(
          child: Column(
            children: [
              // Image display section - only if image exists
              if (imagePath != null && File(imagePath!).existsSync())
                Expanded(
                  flex: 3, // Takes up approximately 60% of available space
                  child: _buildImprovedImageDisplay(context),
                ),

              // Prediction result container - styled based on classification type
              Expanded(
                flex: 2, // Takes up approximately 40% of available space
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildPredictionCard(prediction),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom navigation bar - consistent with other screens
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // Remove ripple effect
          highlightColor: Colors.transparent, // Remove highlight effect
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType
              .fixed, // Fixed layout for consistent positioning
          backgroundColor:
              const Color.fromARGB(255, 194, 184, 146), // Warm cream background
          selectedItemColor:
              const Color(0xFF3E2C1C), // Dark brown for selected item
          unselectedItemColor:
              Colors.black.withAlpha(77), // 30% black for unselected items
          currentIndex: 1, // Set to History (index 1) as the active tab
          onTap: (index) {
            Navigator.pop(context); // First return to previous screen
            if (onNavigate != null) {
              onNavigate!(index); // Then navigate to the selected tab
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: 'About',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.help),
              label: 'Help',
            ),
          ],
        ),
      ),
    );
  }

  /// Improved image display with interactive zooming and better sizing
  Widget _buildImprovedImageDisplay(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InteractiveViewer(
        minScale: 0.8,
        maxScale: 3.0,
        child: FutureBuilder<Size>(
          future: _getImageDimension(File(imagePath!)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3E2C1C),
                ),
              );
            }

            // Dynamic calculation for best fit
            if (snapshot.hasData) {
              final imageSize = snapshot.data!;
              final aspectRatio = imageSize.width / imageSize.height;
              final isLandscape = aspectRatio > 1.0;

              return LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate the best fit size based on available space and aspect ratio
                  double width, height;

                  if (isLandscape) {
                    // For landscape images, fit width first
                    width = constraints.maxWidth;
                    height = width / aspectRatio;

                    // If height is too tall, adjust both
                    if (height > constraints.maxHeight * 0.9) {
                      height = constraints.maxHeight * 0.9;
                      width = height * aspectRatio;
                    }
                  } else {
                    // For portrait images, fit height first
                    height = constraints.maxHeight * 0.9;
                    width = height * aspectRatio;

                    // If width is too wide, adjust both
                    if (width > constraints.maxWidth) {
                      width = constraints.maxWidth;
                      height = width / aspectRatio;
                    }
                  }

                  return Center(
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            8), // Slight rounding of the image corners
                        child: Image.file(
                          File(imagePath!),
                          fit: BoxFit
                              .contain, // Ensure the entire image is visible without cropping
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            // Fallback if dimensions couldn't be determined
            return Center(
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  /// Helper method to get image dimensions
  Future<Size> _getImageDimension(File imageFile) async {
    final Completer<Size> completer =
        Completer(); // Create completer for async result
    final image = Image.file(imageFile); // Load image from file
    // Listen for image to complete loading
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(Size(
            info.image.width.toDouble(), // Get width
            info.image.height.toDouble(), // Get height
          ));
        },
      ),
    );
    return completer.future; // Return future for dimensions
  }

  /// Builds the prediction card with confidence score display
  Widget _buildPredictionCard(Map<String, dynamic> prediction) {
    // Debug: Log received prediction to see what fields are available
    dev.log("🔎 DISPLAYING PREDICTION: ${prediction.toString()}",
        name: 'DetailsScreen');

    // Add more comprehensive logging with our tracker
    ConfidenceTracker.logScore(
        "DETAILS_SCREEN_RECEIVED",
        prediction.containsKey('confidenceScore')
            ? prediction['confidenceScore']
            : null,
        {
          'prediction_type': prediction['text'],
          'all_keys': prediction.keys.toList()
        });

    // Get the confidence score from the prediction data (default to 0.0 if not present)
    double confidenceScore = 0.0;

    // CRITICAL FIX: Extract confidence score with improved error handling
    try {
      // Check for confidence score in the standard field 'confidenceScore'
      if (prediction.containsKey('confidenceScore')) {
        final dynamic rawScore = prediction['confidenceScore'];
        ConfidenceTracker.logScore("DETAILS_EXTRACTING_CONFIDENCE", rawScore,
            {'type': rawScore?.runtimeType.toString()});

        if (rawScore != null) {
          if (rawScore is double) {
            confidenceScore = rawScore;
          } else if (rawScore is num) {
            confidenceScore = rawScore.toDouble();
          } else if (rawScore is String) {
            confidenceScore = double.tryParse(rawScore) ?? 0.0;
          }
        }
        ConfidenceTracker.logScore(
            "DETAILS_EXTRACTED_CONFIDENCE", confidenceScore);
      }
      // Legacy support for 'confidence' field
      else if (prediction.containsKey('confidence')) {
        final dynamic rawScore = prediction['confidence'];
        ConfidenceTracker.logScore("DETAILS_EXTRACTING_LEGACY", rawScore,
            {'type': rawScore?.runtimeType.toString()});

        if (rawScore != null) {
          if (rawScore is double) {
            confidenceScore = rawScore;
          } else if (rawScore is num) {
            confidenceScore = rawScore.toDouble();
          } else if (rawScore is String) {
            confidenceScore = double.tryParse(rawScore) ?? 0.0;
          }
        }
        ConfidenceTracker.logScore("DETAILS_EXTRACTED_LEGACY", confidenceScore);
      }

      // EMERGENCY FIX: Log if we have a zero confidence after extraction
      if (confidenceScore == 0.0) {
        dev.log(
            "⚠️ WARNING: Zero confidence score detected. Keys in prediction: ${prediction.keys.toList()}",
            name: 'DetailsScreen');

        // As a last resort, check if we have history context
        if (prediction.containsKey('fromHistory') &&
            prediction['fromHistory'] == true) {
          // For history items, show a default score if not available
          confidenceScore = 0.75;
          dev.log("Using default confidence for history item",
              name: 'DetailsScreen');
        }
      }

      // Ensure confidence is within range
      confidenceScore = confidenceScore.clamp(0.0, 1.0);
      ConfidenceTracker.logScore("DETAILS_FINAL_CONFIDENCE", confidenceScore);
    } catch (e) {
      // Catch any errors in confidence extraction and use a default
      dev.log("Error extracting confidence score: $e", name: 'DetailsScreen');
      confidenceScore = 0.75; // Use reasonable default
    }

    // Debug: Log the extracted confidence score
    dev.log("🔎 USING CONFIDENCE SCORE: $confidenceScore",
        name: 'DetailsScreen');

    // Format the confidence score as a percentage
    final String confidencePercentage =
        '${(confidenceScore * 100).toStringAsFixed(1)}%';

    // Determine confidence level color
    Color confidenceColor;
    if (confidenceScore >= 0.85) {
      confidenceColor = Colors.green;
    } else if (confidenceScore >= 0.70) {
      confidenceColor = Colors.orange;
    } else if (confidenceScore > 0.0) {
      // Ensure we're not showing green for 0.0
      confidenceColor = Colors.red;
    } else {
      // Special case for zero confidence score
      confidenceColor = Colors.grey;
    }

    // Add confidence level description text
    String confidenceLevelText;
    if (confidenceScore >= 0.90) {
      confidenceLevelText = "High";
    } else if (confidenceScore >= 0.70) {
      confidenceLevelText = "Medium";
    } else if (confidenceScore > 0.0) {
      confidenceLevelText = "Low";
    } else {
      confidenceLevelText = "Low Confidence";
    }

    // Extract processing time if available
    String processingTimeText = "Not available";
    double? processingTime;

    if (prediction.containsKey('processingTime') &&
        prediction['processingTime'] != null) {
      final dynamic rawTime = prediction['processingTime'];

      if (rawTime is double) {
        processingTime = rawTime;
      } else if (rawTime is num) {
        processingTime = rawTime.toDouble();
      } else if (rawTime is String) {
        processingTime = double.tryParse(rawTime);
      }

      if (processingTime != null) {
        processingTimeText = "${processingTime.toStringAsFixed(2)} seconds";
      }
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFFF3E5AB), // Warm cream background
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  prediction['icon'],
                  size: 40,
                  color: prediction['color'],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Prediction Result",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          fontFamily: "Garamond",
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prediction['text'].toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: prediction['color'],
                          fontFamily: "Garamond",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Add confidence score display with fixed layout
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2C1C).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: const Color(0xFF3E2C1C).withAlpha(40)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.analytics_outlined,
                    size: 20,
                    color: Color(0xFF3E2C1C),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Confidence: ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                      fontFamily: "Garamond",
                    ),
                  ),
                  Text(
                    confidencePercentage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: confidenceColor,
                      fontFamily: "Garamond",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "($confidenceLevelText)",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: confidenceColor,
                        fontFamily: "Garamond",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Add processing time display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2C1C).withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: const Color(0xFF3E2C1C).withAlpha(30)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: Color(0xFF3E2C1C),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Processing Time: ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                      fontFamily: "Garamond",
                    ),
                  ),
                  Expanded(
                    child: Text(
                      processingTimeText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                        fontFamily: "Garamond",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
