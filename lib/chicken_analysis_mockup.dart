import 'package:flutter/material.dart';

class ChickenAnalysisMockup extends StatelessWidget {
  final String imagePath;
  const ChickenAnalysisMockup({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chicken Analysis Results'),
        backgroundColor: const Color(0xFF3E2C1C),
        foregroundColor: const Color(0xFFF3E5AB),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with Bounding Boxes Visualization
              const Text(
                'Visual Analysis',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2C1C),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      // Placeholder for image
                      Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Chicken breast image placeholder",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // Simulated bounding boxes
                      Positioned(
                        left: 50,
                        top: 80,
                        child: Container(
                          width: 100,
                          height: 70,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          alignment: Alignment.topLeft,
                          child: Container(
                            color: Colors.green.withAlpha(178),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: const Text(
                              'Normal tissue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 180,
                        top: 100,
                        child: Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange, width: 2),
                          ),
                          alignment: Alignment.topLeft,
                          child: Container(
                            color: Colors.orange.withAlpha(178),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: const Text(
                              'Discoloration',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Analysis Breakdown
              const Text(
                'Analysis Breakdown',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2C1C),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: const Color(0xFFF3E5AB),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Color Analysis
                      _buildFactorBar('Color', 0.85, Colors.green),
                      const SizedBox(height: 8),
                      const Text(
                        'The chicken breast shows healthy pink coloration consistent with fresh poultry. No discoloration or darkening was detected.',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                      ),

                      const SizedBox(height: 16),

                      // Texture Analysis
                      _buildFactorBar('Texture', 0.78, Colors.lightGreen),
                      const SizedBox(height: 8),
                      const Text(
                        'The texture appears firm and consistent, with normal muscle fiber structure. No sliminess or unusual patterns detected.',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                      ),

                      const SizedBox(height: 16),

                      // Moisture Analysis
                      _buildFactorBar('Moisture', 0.68, Colors.orange),
                      const SizedBox(height: 8),
                      const Text(
                        'Appropriate moisture level detected, with no excess liquid or dryness. This is consistent with properly stored fresh chicken.',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                      ),

                      const SizedBox(height: 16),

                      // Shape Analysis
                      _buildFactorBar('Shape', 0.92, Colors.green),
                      const SizedBox(height: 8),
                      const Text(
                        'Normal size and shape characteristics with typical muscle structure. No abnormal shapes or structural issues detected.',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF3E2C1C)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Result Card showing classification
              Card(
                color: const Color(0xFFF3E5AB),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 40),
                          const SizedBox(width: 12),
                          Text(
                            'Consumable',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Confidence Score: 86.0%',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF3E2C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Class Probabilities
              const Text(
                'Classification Probability',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2C1C),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: const Color(0xFFF3E5AB),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildClassBar('Consumable', 0.86, Colors.green),
                      const SizedBox(height: 12),
                      _buildClassBar(
                          'Consumable with Caution', 0.12, Colors.orange),
                      const SizedBox(height: 12),
                      _buildClassBar('Not Consumable', 0.02, Colors.red),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recommendation
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommendation: Safe to Consume',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This chicken breast appears fresh and suitable for all cooking methods. Always ensure chicken reaches an internal temperature of 165°F (74°C) when cooking.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF3E2C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFactorBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2C1C),
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2C1C),
          ),
        ),
      ],
    );
  }

  Widget _buildClassBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(value * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
