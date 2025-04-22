import 'package:flutter/material.dart';

class HelpStep extends StatelessWidget {
  final String imagePath;
  final String text;

  const HelpStep(this.imagePath, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF3E2C1C), // Dark brown text
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 180,
                width: 300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpPage extends StatelessWidget {
  final VoidCallback onBackToHome;

  const HelpPage({super.key, required this.onBackToHome});

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
        title: const Text("Help"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackToHome,
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/ui/main_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay
          Container(
            color: Colors.black.withAlpha(77),
          ),

          // Help content
          DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'Garamond',
              fontSize: 16,
              color: Color(0xFF3E2C1C),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5AB), // Light beige background
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "How to use the application:",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2C1C),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Help Steps
                    const HelpStep(
                      'assets/images/help/step1.png',
                      "1. Click on the camera icon to take a picture or select an image from the gallery.",
                    ),
                    const HelpStep(
                      'assets/images/help/step2.png',
                      "2. Wait for the application to classify the image.",
                    ),
                    const HelpStep(
                      'assets/images/help/step3.png',
                      "3. View the prediction result displayed on the screen.",
                    ),
                    const HelpStep(
                      'assets/images/help/step4.png',
                      "4. You can view the history of previous predictions by clicking on the history icon.",
                    ),
                    const HelpStep(
                      'assets/images/help/step5.png',
                      "5. For more information about the application, click on the info icon.",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
