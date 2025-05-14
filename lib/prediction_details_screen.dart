import 'dart:io';
import 'package:flutter/material.dart';
import 'package:check_a_doodle_doo/utils/analysis_visualizer.dart';

class PredictionDetailsScreen extends StatefulWidget {
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
  State<PredictionDetailsScreen> createState() =>
      _PredictionDetailsScreenState();
}

class _PredictionDetailsScreenState extends State<PredictionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Analysis factors with mock values - in a real app, these would come from your model
  final Map<String, double> _analysisFactors = {
    "Color": 0.85,
    "Texture": 0.78,
    "Moisture": 0.68,
    "Shape": 0.92,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Get consistent confidence score using the same mechanism as history page
    if (widget.prediction.containsKey('confidenceScore')) {
      // Simply preserve the confidence score from the widget
      // This ensures consistency between history view and details screen
      // No need to modify the score if it's already set, particularly if coming from history
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Format datetime as a readable string
  String formatDateTime(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return "${_getMonthName(dateTime.month)} ${dateTime.day}, ${dateTime.year} - "
        "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} "
        "${dateTime.hour >= 12 ? 'PM' : 'AM'}";
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }

  // Combined single view with all important information
  Widget _buildSingleView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Visual Analysis section
          const Text(
            "Visual Analysis",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2C1C),
              fontFamily: "Garamond",
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.transparent, // Make background transparent
            elevation: 0, // Remove elevation for cleaner look
            margin: EdgeInsets.zero, // Remove margins
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0), // Small vertical padding only
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate an ideal height based on available width
                  // This maintains image proportions while keeping size reasonable
                  final double idealHeight = constraints.maxWidth * 0.75;

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit
                          .contain, // Changed to contain to show full image
                      height: idealHeight,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: idealHeight,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Text(
                              "Image not found or cannot be displayed.\nPlease select a valid image.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF3E2C1C),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Image Information
          Card(
            color: const Color(0xFFF3E5AB),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFF3E2C1C), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Analyzed: ${formatDateTime(widget.timestamp)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "Garamond",
                          color: Color(0xFF3E2C1C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 8), // Removed file naming row as requested
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. Result Card
          Card(
            color: const Color(0xFFF3E5AB),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.prediction['icon'],
                        color: widget.prediction['color'],
                        size: 32,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.prediction['text'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: widget.prediction['color'],
                            fontFamily: "Garamond",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Confidence Score: ${((widget.prediction['confidenceScore'] ?? 0.0) * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24), // 4. Analysis Breakdown section
          const Text(
            "Analysis Breakdown",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2C1C),
              fontFamily: "Garamond",
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFFF3E5AB),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color Analysis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Color:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Garamond",
                          color: AnalysisVisualizer.getColorFromFactor(
                              _analysisFactors['Color']!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AnalysisVisualizer.getFactorDescription(
                        'Color', widget.prediction['text'],
                        imagePath: widget.imagePath,
                        timestamp: widget.timestamp),
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                  ),

                  const SizedBox(height: 16),

                  // Texture Analysis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Texture:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Garamond",
                          color: AnalysisVisualizer.getColorFromFactor(
                              _analysisFactors['Texture']!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AnalysisVisualizer.getFactorDescription(
                        'Texture', widget.prediction['text'],
                        imagePath: widget.imagePath,
                        timestamp: widget.timestamp),
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                  ),

                  const SizedBox(height: 16),

                  // Moisture Analysis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Moisture:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Garamond",
                          color: AnalysisVisualizer.getColorFromFactor(
                              _analysisFactors['Moisture']!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AnalysisVisualizer.getFactorDescription(
                        'Moisture', widget.prediction['text'],
                        imagePath: widget.imagePath,
                        timestamp: widget.timestamp),
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                  ),

                  const SizedBox(height: 16), // Shape Analysis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Shape:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Garamond",
                          color: AnalysisVisualizer.getColorFromFactor(
                              _analysisFactors['Shape']!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AnalysisVisualizer.getFactorDescription(
                        'Shape', widget.prediction['text'],
                        imagePath: widget.imagePath,
                        timestamp: widget.timestamp),
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                  ), // No additional parameters beyond the four main ones
                ],
              ),
            ),
          ), // Recommendation section removed
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2C1C),
        foregroundColor: const Color(0xFFF3E5AB),
        title: const Text(
          "Analysis Results",
          style: TextStyle(
            color: Color(0xFFF3E5AB),
            fontFamily: "Garamond",
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResults,
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
        child: _buildSingleView(),
      ),
    );
  }

  void _shareResults() {
    String resultType = widget.prediction['text'];
    double confidenceScore = widget.prediction['confidenceScore'] ?? 0.0;

    String shareText = "Check-A-Doodle-Doo Analysis Results:\n"
        "Classification: $resultType\n"
        "Confidence: ${(confidenceScore * 100).toStringAsFixed(1)}%\n"
        "Analyzed on: ${formatDateTime(widget.timestamp)}";

    // For Flutter apps without share_plus, we just show a dialog with the text
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF3E5AB),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Share Results",
            style: TextStyle(
              color: Color(0xFF3E2C1C),
              fontFamily: "Garamond",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Here's your analysis result:",
                style: TextStyle(
                  color: Color(0xFF3E2C1C),
                  fontFamily: "Garamond",
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFF3E2C1C).withAlpha(100)),
                ),
                child: SelectableText(
                  shareText,
                  style: const TextStyle(
                    color: Color(0xFF3E2C1C),
                    fontFamily: "Garamond",
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Long-press to copy the text",
                style: TextStyle(
                  color: Color(0xFF3E2C1C),
                  fontFamily: "Garamond",
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Close",
                style: TextStyle(
                  color: Color(0xFF3E2C1C),
                  fontFamily: "Garamond",
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
