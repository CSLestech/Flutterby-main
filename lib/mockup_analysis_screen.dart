import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MockupAnalysisScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic>? predictionData;
  const MockupAnalysisScreen({
    super.key,
    required this.imagePath,
    this.predictionData,
  });
  @override
  MockupAnalysisScreenState createState() => MockupAnalysisScreenState();
}

class MockupAnalysisScreenState extends State<MockupAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _predictionClass;
  late Color _predictionColor;
  late double _confidenceScore;

  // Analysis factors
  final Map<String, double> _analysisFactors = {
    "Color": 0.85,
    "Texture": 0.78,
    "Moisture": 0.68,
    "Shape": 0.92,
  };

  // Mock bounding box regions
  final List<Map<String, dynamic>> _boundingBoxes = [
    {
      "label": "Normal tissue",
      "confidence": 0.95,
      "color": Colors.green,
      "rect": const Rect.fromLTWH(50, 80, 100, 70),
    },
    {
      "label": "Slight discoloration",
      "confidence": 0.72,
      "color": Colors.orange,
      "rect": const Rect.fromLTWH(180, 100, 60, 40),
    },
  ];

  // Class probabilities for all categories
  final Map<String, double> _classProbabilities = {
    "Consumable": 0.86,
    "Consumable with Caution": 0.12,
    "Not Consumable": 0.02,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Set defaults based on predictionData or use mockup data
    if (widget.predictionData != null) {
      _predictionClass = widget.predictionData!['text'] ?? "Consumable";
      _predictionColor = widget.predictionData!['color'] ?? Colors.green;
      _confidenceScore = widget.predictionData!['confidenceScore'] ?? 0.86;
    } else {
      // Default mockup values
      _predictionClass = "Consumable";
      _predictionColor = Colors.green;
      _confidenceScore = 0.86;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to generate a rainbow gradient color
  Color _getColorFromFactor(double factor) {
    if (factor > 0.85) return Colors.green;
    if (factor > 0.7) return Colors.lightGreen;
    if (factor > 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2C1C),
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
            _buildOverviewTab(),
            _buildBreakdownTab(),
            _buildDetailsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result Card with Confidence Score
          Card(
            color: const Color(0xFFF3E5AB),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _predictionClass == "Consumable"
                            ? Icons.check_circle
                            : _predictionClass == "Consumable with Caution"
                                ? Icons.warning
                                : Icons.cancel,
                        color: _predictionColor,
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _predictionClass,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _predictionColor,
                          fontFamily: "Garamond",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Confidence Score: ${(_confidenceScore * 100).toStringAsFixed(1)}%",
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

          // Image with Bounding Boxes
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: CustomPaint(
                      painter:
                          BoundingBoxPainter(boundingBoxes: _boundingBoxes),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Analysis Summary
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _predictionClass == "Consumable"
                        ? "This chicken breast appears fresh and safe for consumption."
                        : _predictionClass == "Consumable with Caution"
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
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              "${factor.key}:",
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "Garamond",
                                color: Color(0xFF3E2C1C),
                              ),
                            ),
                          ),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: factor.value,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getColorFromFactor(factor.value),
                              ),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${(factor.value * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(
                              fontSize: 16,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Probability of each classification",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 1,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                String text = '';
                                switch (value.toInt()) {
                                  case 0:
                                    text = 'Consumable';
                                    break;
                                  case 1:
                                    text = 'With Caution';
                                    break;
                                  case 2:
                                    text = 'Not Consumable';
                                    break;
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    text,
                                    style: const TextStyle(
                                      color: Color(0xFF3E2C1C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 38,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    color: Color(0xFF3E2C1C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: _classProbabilities['Consumable']!,
                                color: Colors.green,
                                width: 30,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: _classProbabilities[
                                    'Consumable with Caution']!,
                                color: Colors.orange,
                                width: 30,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: _classProbabilities['Not Consumable']!,
                                color: Colors.red,
                                width: 30,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Values in text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProbabilityText("Consumable",
                          _classProbabilities['Consumable']!, Colors.green),
                      _buildProbabilityText(
                          "With Caution",
                          _classProbabilities['Consumable with Caution']!,
                          Colors.orange),
                      _buildProbabilityText("Not Consumable",
                          _classProbabilities['Not Consumable']!, Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Feature Importance
          const Text(
            "Feature Importance",
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "How each feature contributed to the classification",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.polygon,
                        radarBackgroundColor: Colors.transparent,
                        borderData: FlBorderData(show: false),
                        radarBorderData:
                            const BorderSide(color: Colors.transparent),
                        titlePositionPercentageOffset: 0.2,
                        tickCount: 5,
                        ticksTextStyle:
                            const TextStyle(color: Colors.transparent),
                        tickBorderData: BorderSide(
                            color: const Color(0xFF3E2C1C).withAlpha(51)),
                        gridBorderData: BorderSide(
                            color: const Color(0xFF3E2C1C).withAlpha(51)),
                        titleTextStyle: const TextStyle(
                          color: Color(0xFF3E2C1C),
                          fontSize: 14,
                        ),
                        getTitle: (index, angle) {
                          switch (index) {
                            case 0:
                              return RadarChartTitle(
                                  text: 'Color', angle: angle);
                            case 1:
                              return RadarChartTitle(
                                  text: 'Texture', angle: angle);
                            case 2:
                              return RadarChartTitle(
                                  text: 'Moisture', angle: angle);
                            case 3:
                              return RadarChartTitle(
                                  text: 'Shape', angle: angle);
                            default:
                              return RadarChartTitle(text: '', angle: angle);
                          }
                        },
                        dataSets: [
                          RadarDataSet(
                            fillColor: _predictionColor.withAlpha(102),
                            borderColor: _predictionColor,
                            entryRadius: 4,
                            dataEntries: [
                              RadarEntry(value: _analysisFactors['Color']!),
                              RadarEntry(value: _analysisFactors['Texture']!),
                              RadarEntry(value: _analysisFactors['Moisture']!),
                              RadarEntry(value: _analysisFactors['Shape']!),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detailed Analysis
          const Text(
            "Detailed Analysis",
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Color Analysis:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _predictionClass == "Consumable"
                        ? "The chicken breast shows healthy pink coloration consistent with fresh poultry. No discoloration or darkening was detected."
                        : _predictionClass == "Consumable with Caution"
                            ? "The chicken breast shows some minor discoloration in certain areas. While not severe, this indicates the beginning of quality degradation."
                            : "The chicken breast shows significant discoloration, with gray/green areas that indicate bacterial growth or spoilage.",
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Texture Analysis:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _predictionClass == "Consumable"
                        ? "The texture appears firm and consistent, with normal muscle fiber structure visible. No sliminess or unusual surface patterns detected."
                        : _predictionClass == "Consumable with Caution"
                            ? "The texture shows some changes in consistency, with slight softening in certain areas. This suggests early stage quality degradation."
                            : "The texture shows significant changes including excessive softening, sliminess, or tacky surface characteristics indicative of spoilage.",
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Moisture Assessment:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _predictionClass == "Consumable"
                        ? "Appropriate moisture level detected, with no excess liquid or dryness. This is consistent with properly stored fresh chicken."
                        : _predictionClass == "Consumable with Caution"
                            ? "Some areas show changes in moisture level, either with excess liquid or slight drying. This indicates storage time affecting quality."
                            : "Significant moisture issues detected, either excessive dampness suggesting bacterial activity or severe drying indicating improper storage.",
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
                                  box['label'] == "Normal tissue"
                                      ? "This area shows characteristics of fresh chicken breast tissue with normal coloration and texture."
                                      : "This area shows slight changes in color or texture that could indicate early-stage quality degradation.",
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
          Card(
            color: _predictionClass == "Consumable"
                ? Colors.green.shade100
                : _predictionClass == "Consumable with Caution"
                    ? Colors.orange.shade100
                    : Colors.red.shade100,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _predictionClass == "Consumable"
                        ? "Recommendation: Safe to Consume"
                        : _predictionClass == "Consumable with Caution"
                            ? "Recommendation: Cook Thoroughly"
                            : "Recommendation: Discard",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Garamond",
                      color: _predictionClass == "Consumable"
                          ? Colors.green.shade800
                          : _predictionClass == "Consumable with Caution"
                              ? Colors.orange.shade800
                              : Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _predictionClass == "Consumable"
                        ? "This chicken breast appears fresh and suitable for all cooking methods. Always ensure chicken reaches an internal temperature of 165°F (74°C) when cooking."
                        : _predictionClass == "Consumable with Caution"
                            ? "This chicken breast is at the transition stage. Cook thoroughly to an internal temperature of 165°F (74°C) and consume immediately. Avoid raw preparations."
                            : "This chicken breast shows significant signs of spoilage and should be discarded. Consuming this may pose health risks.",
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
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

  Widget _buildProbabilityText(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          "${(value * 100).toStringAsFixed(1)}%",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "Garamond",
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: "Garamond",
            color: Color(0xFF3E2C1C),
          ),
        ),
      ],
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> boundingBoxes;

  BoundingBoxPainter({required this.boundingBoxes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final box in boundingBoxes) {
      final rect = Rect.fromLTWH(
        box['rect'].left,
        box['rect'].top,
        box['rect'].width,
        box['rect'].height,
      );

      // Calculate scaled rect
      final scaleX = size.width / 300; // Assuming the original width is 300
      final scaleY = size.height / 300; // Assuming the original height is 300

      final scaledRect = Rect.fromLTWH(
        rect.left * scaleX,
        rect.top * scaleY,
        rect.width * scaleX,
        rect.height * scaleY,
      );

      // Draw bounding box
      final paint = Paint()
        ..color = box['color']
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRect(scaledRect, paint);

      // Draw label background
      final labelBg = Paint()..color = box['color'].withAlpha(178);

      final labelRect = Rect.fromLTWH(
        scaledRect.left,
        scaledRect.top - 20,
        80,
        20,
      );

      canvas.drawRect(labelRect, labelBg);

      // Draw label text
      final textSpan = TextSpan(
        text: box['label'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: 80,
      );

      textPainter.paint(
        canvas,
        Offset(labelRect.left + 5, labelRect.top + 3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
