import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How to use the application:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "1. Click on the camera icon to take a picture or select an image from the gallery.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "2. Wait for the application to classify the image.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "3. View the prediction result displayed on the screen.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "4. You can view the history of previous predictions by clicking on the history icon.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "5. For more information about the application, click on the info icon.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
