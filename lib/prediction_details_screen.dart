import 'package:flutter/material.dart'; // Core Flutter UI framework
import 'dart:io'; // For file I/O operations (loading images from file system)
import 'dart:async'; // For asynchronous programming, including the Completer class
// Import BackgroundWrapper with prefix to avoid name conflicts
import 'package:check_a_doodle_doo/background_wrapper.dart'
    as bg; // Custom background widget
import 'widgets/guide_book_button.dart'; // Guide book access button for educational content

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
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content vertically
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0), // Side margins
                child: Column(
                  children: [
                    // Image display section - only if image exists
                    if (imagePath != null && File(imagePath!).existsSync())
                      _buildImageDisplay(context),

                    // Dynamic spacing based on image type (portrait vs landscape)
                    FutureBuilder<Size>(
                      future: imagePath != null && File(imagePath!).existsSync()
                          ? _getImageDimension(File(
                              imagePath!)) // Get dimensions if image exists
                          : Future.value(
                              const Size(1, 1)), // Default size otherwise
                      builder: (context, snapshot) {
                        // Calculate aspect ratio to adjust spacing
                        final aspectRatio = snapshot.hasData
                            ? snapshot.data!.width / snapshot.data!.height
                            : 1.0; // Default to square if dimensions unknown

                        // Apply smaller spacing for portrait images, larger for landscape
                        final spacingHeight = aspectRatio < 1.0 ? 15.0 : 25.0;

                        return SizedBox(height: spacingHeight); // Apply spacing
                      },
                    ),

                    // Prediction result container - styled based on classification type
                    _buildPredictionCard(prediction),
                  ],
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

  /// Builds the image display section with appropriate sizing and error handling
  Widget _buildImageDisplay(BuildContext context) {
    // Calculate appropriate image height based on screen size
    final screenSize = MediaQuery.of(context).size;
    final imageMaxHeight =
        screenSize.height * 0.4; // Limit to 40% of screen height

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch horizontally
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: imageMaxHeight, // Apply maximum height constraint
          ),
          // Center the image in available space
          child: Center(
            child: FutureBuilder<Size>(
              future: _getImageDimensions(File(
                  imagePath!)), // Determine image dimensions asynchronously
              builder: (context, snapshot) {
                // Show loading indicator while getting image dimensions
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    color: Color(0xFFF3E5AB), // Light cream color loader
                  );
                }

                // Show fallback display if dimensions couldn't be determined
                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildImageWithFallback();
                }

                // Calculate aspect ratio from image dimensions
                final imageSize = snapshot.data!;
                final aspectRatio = imageSize.width / imageSize.height;

                // Display image with scroll capability if needed
                return SingleChildScrollView(
                  physics:
                      const ClampingScrollPhysics(), // Smooth physics for scrolling
                  child: AspectRatio(
                    aspectRatio: aspectRatio, // Apply correct aspect ratio
                    child:
                        _buildImageWithFallback(), // Display image with error handling
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Helper method to get image dimensions before displaying
  Future<Size> _getImageDimensions(File imageFile) async {
    final Completer<Size> completer =
        Completer(); // Create a completer for async resolution
    final image = Image.file(imageFile); // Load image from file
    // Listen for image to load and extract dimensions when available
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(), // Extract image width
          info.image.height.toDouble(), // Extract image height
        ));
      }),
    );
    return completer.future; // Return future that will resolve with dimensions
  }

  /// Builds the image display with error handling for missing or corrupt images
  Widget _buildImageWithFallback() {
    return Image.file(
      File(imagePath!), // Load image from file path
      fit: BoxFit.contain, // Preserve aspect ratio, fit within bounds
      errorBuilder: (context, error, stackTrace) {
        // Show fallback UI if image loading fails
        return Container(
          color: Colors.grey.shade300, // Light grey background
          child: const Center(
            child: Icon(
              Icons.broken_image, // Broken image icon
              size: 64, // Large icon size
              color: Colors.grey, // Grey color
            ),
          ),
        );
      },
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
    // Get the confidence score from the prediction data (default to 0.0 if not present)
    final double confidenceScore = prediction.containsKey('confidenceScore')
        ? prediction['confidenceScore']
        : 0.0;

    // Format the confidence score as a percentage
    final String confidencePercentage =
        '${(confidenceScore * 100).toStringAsFixed(1)}%';

    // Determine confidence level color
    Color confidenceColor;
    if (confidenceScore >= 0.85) {
      confidenceColor = Colors.green;
    } else if (confidenceScore >= 0.70) {
      confidenceColor = Colors.orange;
    } else {
      confidenceColor = Colors.red;
    }

    // Add confidence level description text
    String confidenceLevelText;
    if (confidenceScore >= 0.90) {
      confidenceLevelText = "High Confidence";
    } else if (confidenceScore >= 0.70) {
      confidenceLevelText = "Medium Confidence";
    } else {
      confidenceLevelText = "Low Confidence";
    }

    // Add recommendation based on prediction result
    String recommendationText;
    switch (prediction['text'].toString()) {
      case "Consumable":
        recommendationText = "Safe to cook.";
        break;
      case "Half-consumable":
        recommendationText = "Use caution. Check smell and texture.";
        break;
      case "Not consumable":
        recommendationText = "Not safe to eat.";
        break;
      default:
        recommendationText = "Unable to provide recommendation.";
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

            // Add confidence score display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2C1C).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: const Color(0xFF3E2C1C).withAlpha(40)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                  Text(
                    "($confidenceLevelText)",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: confidenceColor,
                      fontFamily: "Garamond",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Add recommendation message
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: prediction['color'].withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: prediction['color'].withAlpha(60),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: prediction['color'],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Recommendation: $recommendationText",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                        fontFamily: "Garamond",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
