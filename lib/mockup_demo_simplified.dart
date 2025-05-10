import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'chicken_analysis_mockup.dart';

void main() {
  runApp(const MockupDemoApp());
}

class MockupDemoApp extends StatelessWidget {
  const MockupDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chicken Analysis Mockup',
      theme: ThemeData(
        primaryColor: const Color(0xFF3E2C1C),
        scaffoldBackgroundColor: const Color(0xFFF3E5AB),
      ),
      home: const MockupLauncher(),
    );
  }
}

class MockupLauncher extends StatefulWidget {
  const MockupLauncher({super.key});

  @override
  State<MockupLauncher> createState() => _MockupLauncherState();
}

class _MockupLauncherState extends State<MockupLauncher> {
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
              builder: (context) => ChickenAnalysisMockup(
                imagePath: _selectedImage!.path,
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
          'Chicken Analysis Mockup',
          style: TextStyle(
            color: Color(0xFFF3E5AB),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tap the button below to select an image\nand see the analysis mockup',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF3E2C1C),
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
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // This button will show the mockup with a placeholder image
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChickenAnalysisMockup(
                              imagePath: 'placeholder_path.jpg',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
