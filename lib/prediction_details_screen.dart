import 'dart:io';

import 'package:check_a_doodle_doo/utils/analysis_visualizer.dart';
import 'package:check_a_doodle_doo/utils/bounding_box_painter.dart';
import 'package:flutter/material.dart';

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

  // Mock bounding box regions - in a real app, these would come from your model
  late List<Map<String, dynamic>> _boundingBoxes;

  // Class probabilities
  late Map<String, double> _classProbabilities;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize bounding boxes - in a real app would come from model
    _initializeBoundingBoxes();

    // Initialize probabilities based on prediction confidence
    _initializeProbabilities();
  }

  void _initializeBoundingBoxes() {
    // Create mock bounding boxes based on prediction type
    final String predictionType = widget.prediction['text'];

    if (predictionType == "Consumable") {
      _boundingBoxes = [
        {
          "label": "Normal tissue",
          "confidence": 0.95,
          "color": Colors.green,
          "rect": const Rect.fromLTWH(50, 100, 100, 70),
        },
        {
          "label": "Slight discolor",
          "confidence": 0.72,
          "color": Colors.orange,
          "rect": const Rect.fromLTWH(180, 120, 60, 40),
        },
      ];
    } else if (predictionType == "Consumable with Caution" ||
        predictionType == "Half-consumable") {
      _boundingBoxes = [
        {
          "label": "Normal tissue",
          "confidence": 0.75,
          "color": Colors.green,
          "rect": const Rect.fromLTWH(30, 90, 80, 60),
        },
        {
          "label": "Discoloration",
          "confidence": 0.85,
          "color": Colors.orange,
          "rect": const Rect.fromLTWH(150, 140, 100, 60),
        },
      ];
    } else {
      _boundingBoxes = [
        {
          "label": "Spoilage",
          "confidence": 0.92,
          "color": Colors.red,
          "rect": const Rect.fromLTWH(80, 90, 140, 80),
        },
        {
          "label": "Texture issue",
          "confidence": 0.86,
          "color": Colors.red,
          "rect": const Rect.fromLTWH(40, 180, 90, 50),
        },
      ];
    }
  }

  void _initializeProbabilities() {
    // In a real app, these would come from your model
    // Here we're simulating based on the confidence score
    final double confidence = widget.prediction['confidenceScore'] ?? 0.75;

    if (widget.prediction['text'] == "Consumable") {
      _classProbabilities = {
        "Consumable": confidence,
        "Consumable with Caution": (1.0 - confidence) * 0.8,
        "Not Consumable": (1.0 - confidence) * 0.2,
      };
    } else if (widget.prediction['text'] == "Consumable with Caution" ||
        widget.prediction['text'] == "Half-consumable") {
      _classProbabilities = {
        "Consumable": (1.0 - confidence) * 0.4,
        "Consumable with Caution": confidence,
        "Not Consumable": (1.0 - confidence) * 0.6,
      };
    } else {
      _classProbabilities = {
        "Consumable": (1.0 - confidence) * 0.1,
        "Consumable with Caution": (1.0 - confidence) * 0.3,
        "Not Consumable": confidence,
      };
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF3E5AB),
          labelColor: const Color(0xFFF3E5AB),
          unselectedLabelColor: const Color(0xFFF3E5AB).withAlpha(178),
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Breakdown"),
            Tab(text: "Details"),
          ],
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
        child: TabBarView(
          controller: _tabController,
          children: [
            // Image → Result Card → Analysis Summary
            _buildOverviewTab(),
            _buildBreakdownTab(),
            _buildDetailsTab(),
          ],
        ),
      ),
    );
  }

  // Overview tab: Visual Analysis -> Result Card -> Analysis Summary
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Visual Analysis section first (same for both layouts)
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
            color: Colors.white,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.contain,
                      height: 300,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
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
                  ),
                  // Bounding boxes overlay
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, 300),
                          painter:
                              BoundingBoxPainter(boundingBoxes: _boundingBoxes),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 2. Result Card second (Option 2)
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
                  if (widget.prediction.containsKey('processingTime'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Processing Time: ${(widget.prediction['processingTime'] as double).toStringAsFixed(2)} sec",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Garamond",
                          color: const Color(0xFF3E2C1C).withAlpha(200),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 3. Analysis Summary last (Option 2)
          const Text(
            "Analysis Summary",
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.prediction['text'] == "Consumable"
                        ? "This chicken breast appears fresh and safe for consumption."
                        : widget.prediction['text'] ==
                                    "Consumable with Caution" ||
                                widget.prediction['text'] == "Half-consumable"
                            ? "This chicken breast is at the transition stage. Cook thoroughly and consume soon."
                            : "This chicken breast shows signs of spoilage and is not recommended for consumption.",
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Key Factors:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var factor in _analysisFactors.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: AnalysisVisualizer.buildFactorBar(
                        factor.key,
                        factor.value,
                        AnalysisVisualizer.getColorFromFactor(factor.value),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Probabilities
          const Text(
            "Classification Probability",
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
                  const Text(
                    "Probability of each classification",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnalysisVisualizer.buildClassBar('Consumable',
                      _classProbabilities['Consumable']!, Colors.green),
                  const SizedBox(height: 12),
                  AnalysisVisualizer.buildClassBar(
                      'Consumable with Caution',
                      _classProbabilities['Consumable with Caution']!,
                      Colors.orange),
                  const SizedBox(height: 12),
                  AnalysisVisualizer.buildClassBar('Not Consumable',
                      _classProbabilities['Not Consumable']!, Colors.red),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Feature Importance
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
                  AnalysisVisualizer.buildFactorBar(
                      'Color',
                      _analysisFactors['Color']!,
                      AnalysisVisualizer.getColorFromFactor(
                          _analysisFactors['Color']!)),
                  const SizedBox(height: 8),
                  Text(
                    AnalysisVisualizer.getFactorDescription(
                        'Color', widget.prediction['text']),
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                  ),

                  const SizedBox(height: 16),

                  // Texture Analysis
                  AnalysisVisualizer.buildFactorBar(
                      'Texture',
                      _analysisFactors['Texture']!,
                      AnalysisVisualizer.getColorFromFactor(
                          _analysisFactors['Texture']!)),
                  const SizedBox(height: 8),
                  Text(
                    AnalysisVisualizer.getFactorDescription(
                        'Texture', widget.prediction['text']),
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                  ),

                  const SizedBox(height: 16),

                  // Moisture Analysis
                  AnalysisVisualizer.buildFactorBar(
                      'Moisture',
                      _analysisFactors['Moisture']!,
                      AnalysisVisualizer.getColorFromFactor(
                          _analysisFactors['Moisture']!)),
                  const SizedBox(height: 8),
                  Text(
                    AnalysisVisualizer.getFactorDescription(
                        'Moisture', widget.prediction['text']),
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                  ),

                  const SizedBox(height: 16),

                  // Shape Analysis
                  AnalysisVisualizer.buildFactorBar(
                      'Shape',
                      _analysisFactors['Shape']!,
                      AnalysisVisualizer.getColorFromFactor(
                          _analysisFactors['Shape']!)),
                  const SizedBox(height: 8),
                  Text(
                    AnalysisVisualizer.getFactorDescription(
                        'Shape', widget.prediction['text']),
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image timestamp section
          Card(
            color: const Color(0xFFF3E5AB),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Image Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.image,
                          color: Color(0xFF3E2C1C), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "File: ${widget.imagePath.split('/').last}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: "Garamond",
                            color: Color(0xFF3E2C1C),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Region of Interest Analysis
          const Text(
            "Region of Interest Analysis",
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
                  for (var box in _boundingBoxes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: box['color'],
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${box['label']} (${(box['confidence'] * 100).toStringAsFixed(0)}% confidence)",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Garamond",
                                    color: Color(0xFF3E2C1C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  box['label'].toString().contains("Normal")
                                      ? "This area shows characteristics of fresh chicken breast tissue with normal coloration and texture."
                                      : box['label']
                                              .toString()
                                              .contains("color")
                                          ? "This area shows changes in color that could indicate early-stage quality degradation."
                                          : box['label']
                                                  .toString()
                                                  .contains("Texture")
                                              ? "This area shows abnormal texture that suggests quality degradation."
                                              : "This area shows characteristics suggesting potential spoilage.",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Garamond",
                                    color: Color(0xFF3E2C1C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recommendation
          Builder(
            builder: (context) {
              final recommendation = AnalysisVisualizer.getRecommendation(
                  widget.prediction['text']);
              return Card(
                color: recommendation['bgColor'],
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['title'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Garamond",
                          color: recommendation['color'],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recommendation['text'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "Garamond",
                          color: Color(0xFF3E2C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
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
