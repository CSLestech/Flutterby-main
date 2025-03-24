import 'package:flutter/material.dart';
import 'dart:io';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const HistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: history.isEmpty
          ? const Center(
              child: Text(
                "No history available.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final entry = history[index];
                final String? imagePath = entry["image"];
                final String prediction = entry["prediction"];

                // Extract the full timestamp (date and time) from the prediction
                final String timestamp = prediction.split(": ")[0];

                return GestureDetector(
                  onTap: () {
                    // Navigate to the detail page when the image is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryDetailPage(
                          imagePath: imagePath,
                          prediction: prediction,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (imagePath != null && File(imagePath).existsSync())
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: Image.file(
                                File(imagePath),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              timestamp, // Display the full timestamp (date and time)
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class HistoryDetailPage extends StatelessWidget {
  final String? imagePath;
  final String prediction;

  const HistoryDetailPage({
    super.key,
    required this.imagePath,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    // Extract only the prediction text (remove timestamp)
    final String predictionText = prediction.split(": ").sublist(1).join(": ");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction Details"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (imagePath != null && File(imagePath!).existsSync())
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(imagePath!),
                width: double.infinity,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              predictionText, // Display only the prediction text
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
