import 'package:flutter/material.dart';
import 'dart:io';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final VoidCallback onBackToHome;

  const HistoryPage(
      {super.key, required this.history, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            onBackToHome(); // Navigate back to Home Page
          },
        ),
      ),
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
                final String timestamp = entry["timestamp"];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryDetailPage(
                          imagePath: imagePath,
                          prediction: entry["prediction"],
                          timestamp: timestamp,
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
                              "Uploaded on: $timestamp",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
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
              "Uploaded on: $timestamp",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  prediction["icon"],
                  color: prediction["color"],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  prediction["text"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: prediction["color"],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
