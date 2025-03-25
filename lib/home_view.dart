import 'dart:io';
import 'dart:convert';
import 'dart:developer'; // Import for logging
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'about_page.dart';
import 'history_page.dart';
import 'help_page.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  File? _pickedImage;
  String? _prediction;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _history = [];
  int _selectedIndex = 0;

  final List<String> _carouselImages = [
    'images/ui/sample.jpg',
    'images/ui/chick2.png',
    'images/ui/chickog.png',
  ];

  List<Widget> get _widgetOptions => <Widget>[
        _buildHomePage(),
        HistoryPage(history: _history),
        const AboutPage(),
        const HelpPage(),
      ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      log("Picked file path: ${pickedFile.path}");

      if (!pickedFile.path.toLowerCase().endsWith('.jpg') &&
          !pickedFile.path.toLowerCase().endsWith('.png')) {
        setState(() {
          _prediction = "Invalid file format. Only JPG and PNG are allowed.";
        });
        return;
      }

      setState(() {
        _pickedImage = File(pickedFile.path);
        _prediction = null; // Reset prediction before generating a new one
      });

      _generateDummyPrediction(); // Generate a prediction after selecting the image
    } else {
      log("No file selected.");
    }
  }

  void _generateDummyPrediction() {
    final List<String> dummyPredictions = [
      "Chicken breast is defect-free.",
      "Chicken breast has minor defects.",
      "Chicken breast is heavily damaged.",
      "Invalid: Not a chicken breast.",
    ];

    final String prediction = dummyPredictions[
        (DateTime.now().millisecondsSinceEpoch % dummyPredictions.length)];

    setState(() {
      _prediction = prediction; // Update the prediction
      _addToHistory(prediction); // Add the prediction to history
    });
  }

  Future<void> _loadHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedHistory = prefs.getString('history');
    if (encodedHistory != null) {
      log("Loaded history: $encodedHistory");
      setState(() {
        _history.clear();
        _history.addAll(
            List<Map<String, dynamic>>.from(jsonDecode(encodedHistory)));
      });
    } else {
      log("No history found.");
    }
  }

  void _addToHistory(String prediction) {
    final String timestamp = DateTime.now().toString();
    setState(() {
      _history.add({
        "image": _pickedImage?.path,
        "prediction": "$timestamp: $prediction",
      });

      if (_history.length > 5) {
        _history.removeAt(0);
      }
    });

    log("Updated history: $_history");
    _saveHistory();
  }

  Future<void> _saveHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedHistory = jsonEncode(_history);
    await prefs.setString('history', encodedHistory);
  }

  Widget _buildPromotionalCards() {
    final List<Map<String, String>> features = [
      {
        "title": "Defect Detection",
        "description": "Automatically detect defects in chicken breast images.",
      },
      {
        "title": "History Tracking",
        "description": "Keep track of your previous uploads and predictions.",
      },
      {
        "title": "User-Friendly",
        "description": "Simple and intuitive interface for easy navigation.",
      },
      {
        "title": "Fast Processing",
        "description": "Get predictions in seconds with high accuracy.",
      },
    ];

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Enables horizontal scrolling
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature["title"]!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature["description"]!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
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

  Widget _buildHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: _carouselImages.map((imagePath) {
                log("Loading image: $imagePath"); // Debug log
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text("Failed to load image."),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Features",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 10),
            _buildPromotionalCards(),
            const SizedBox(height: 30),
            if (_pickedImage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _pickedImage!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text("Failed to load image."),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              const Center(
                child: Text("No image selected."),
              ),
            const SizedBox(height: 5),
            if (_prediction != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    _prediction!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check-A-Doodle-Doo"),
        centerTitle: true,
      ),
      body: _widgetOptions[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showImageSourceDialog();
              },
              backgroundColor: Colors.purple,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Help',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Take a Picture"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text("Select from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
