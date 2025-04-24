import 'package:flutter/material.dart';
import 'dart:io';
import 'package:check_a_doodle_doo/background_wrapper.dart';
import 'package:check_a_doodle_doo/prediction_details_screen.dart';
import 'dart:developer' as dev;

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final VoidCallback onBackToHome;

  const HistoryPage({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2C1C),
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFFF3E5AB)),
        titleTextStyle: const TextStyle(
          color: Color(0xFFF3E5AB),
          fontFamily: 'Garamond',
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        title: const Text("History"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackToHome,
        ),
      ),
      body: BackgroundWrapper(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: history.isEmpty
              ? const Center(
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
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: const Color(0xFFF3E5AB),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PredictionDetailsScreen(
                                imagePath: item['imagePath'],
                                prediction: {
                                  'text': item['text'],
                                  'icon': item['icon'],
                                  'color': item['color'],
                                },
                                timestamp: item['timestamp'],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              if (item['imagePath'] != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(item['imagePath']),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      dev.log("Error loading image: $error",
                                          name: 'HistoryPage');
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                            Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                )
                              else
                                Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (item['icon'] != null)
                                          Icon(
                                            item['icon'],
                                            color: item['color'],
                                          ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item['text'] ?? 'Unknown',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: item['color'],
                                              fontFamily: "Garamond",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Uploaded on: ${item['timestamp'] ?? 'Unknown date'}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Garamond",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
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
}

class HistoryDetailPage extends StatelessWidget {
  final String? imagePath;
  final Map<String, dynamic> prediction;
  final String timestamp;

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
        title: const Text("Prediction Details"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/ui/main_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay
          Container(
            color: Colors.black.withAlpha(77),
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
