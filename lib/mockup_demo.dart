import 'dart:io';
import 'package:flutter/material.dart';
import 'mockup_analysis_screen.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MockupDemoApp());
}

class MockupDemoApp extends StatelessWidget {
  const MockupDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analysis Screen Mockup',
      theme: ThemeData(
        primaryColor: const Color(0xFF3E2C1C),
        scaffoldBackgroundColor: const Color(0xFFF3E5AB),
        fontFamily: 'Garamond',
      ),
      home: const MockupLauncher(),
    );
  }
}

class MockupLauncher extends StatefulWidget {
  const MockupLauncher({super.key});

  @override
  State<MockupLauncher> createState() => MockupLauncherState();
}

class MockupLauncherState extends State<MockupLauncher> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        if (_selectedImage != null) {
          // Navigate to mockup screen with the selected image
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MockupAnalysisScreen(
                imagePath: _selectedImage!.path,
                // You can provide custom predictionData here if needed
                predictionData: {
                  'text': 'Consumable',
                  'color': Colors.green,
                  'confidenceScore': 0.86,
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2C1C),
        title: const Text(
          'Analysis Screen Demo',
          style: TextStyle(
            color: Color(0xFFF3E5AB),
            fontFamily: "Garamond",
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tap the button below to select an image\nand test the analysis screen mockup',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF3E2C1C),
                fontFamily: "Garamond",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E2C1C),
                foregroundColor: const Color(0xFFF3E5AB),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Select Image',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Garamond",
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // This button will simulate the analysis screen with default images
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MockupAnalysisScreen(
                              // Default path - will use placeholder unless you modify this
                              imagePath: 'path/to/sample/image.jpg',
                            )));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4513),
                foregroundColor: const Color(0xFFF3E5AB),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Demo without Image',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Garamond",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
