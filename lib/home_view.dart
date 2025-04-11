import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

import 'about_page.dart';
import 'history_page.dart';
import 'help_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoadingScreenWrapper(),
    );
  }
}

class LoadingScreenWrapper extends StatefulWidget {
  const LoadingScreenWrapper({super.key});

  @override
  State<LoadingScreenWrapper> createState() => _LoadingScreenWrapperState();
}

class _LoadingScreenWrapperState extends State<LoadingScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 15)); // Adjust the time here
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen();
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/chick2.png', // Replace with your image path
              height: 150, // Adjust the size as needed
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.purple, // Optional: Customize the color
            ), // Loading indicator
          ],
        ),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  File? _pickedImage;
  Map<String, dynamic>? _prediction;
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
        HistoryPage(
          history: _history,
          onBackToHome: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
        ),
        AboutPage(
          onBackToHome: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
        ),
        HelpPage(
          onBackToHome: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
        ),
      ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _pickImage(ImageSource source) async {
    // Check if the source is gallery and request storage permission
    if (source == ImageSource.gallery) {
      final status = await Permission.storage.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        // Show a dialog if permission is denied
        _showPermissionDialog();
        return; // Exit the method if permission is not granted
      } else if (status.isGranted) {
        debugPrint('Storage permission granted.');
      }
    }

    // Proceed with picking the image
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      log("Picked file path: ${pickedFile.path}");

      // Validate file format
      final String fileExtension =
          pickedFile.path.split('.').last.toLowerCase();
      if (fileExtension != 'jpg' && fileExtension != 'png') {
        setState(() {
          _prediction = {
            "text": "Invalid file format. Only JPG and PNG are allowed.",
            "icon": Icons.error,
            "color": Colors.grey,
          };
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
    final List<Map<String, dynamic>> dummyPredictions = [
      {
        "text": "Safe to Eat (Consumable)",
        "icon": Icons.check_circle,
        "color": Colors.green,
      },
      {
        "text": "Consume with Risk (Half-Consumable)",
        "icon": Icons.warning,
        "color": Colors.orange,
      },
      {
        "text": "Not Safe to Eat (Not Consumable)",
        "icon": Icons.cancel,
        "color": Colors.red,
      },
      {
        "text": "Invalid: Not a chicken breast.",
        "icon": Icons.error,
        "color": Colors.grey,
      },
    ];

    final Map<String, dynamic> prediction = dummyPredictions[
        (DateTime.now().millisecondsSinceEpoch % dummyPredictions.length)];

    setState(() {
      _prediction = prediction; // Update the prediction
      _addToHistory(prediction); // Add the prediction to history
    });
  }

  void _addToHistory(Map<String, dynamic> prediction) async {
    // Add the prediction to the history list
    setState(() {
      _history.add(prediction);
      if (_history.length > 5) {
        _history.removeAt(0); // Keep only the last 5 entries
      }
    });

    // Save the updated history to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedHistory = jsonEncode(_history);
    await prefs.setString('history', encodedHistory);
    log("History updated: $encodedHistory");
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Storage permission is required to access files. Please enable it in the app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // Open app settings
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
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
                viewportFraction: 0.9, // Adjust the width of the carousel items
                aspectRatio: 16 / 9,
                autoPlayInterval: const Duration(seconds: 2),
                autoPlayAnimationDuration: const Duration(milliseconds: 400),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              items: _carouselImages.map((imagePath) {
                log("Loading image: $imagePath"); // Debug log
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(
                              (0.1 * 255).toInt()), // Fixed to use withAlpha
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text("Failed to load image."),
                        );
                      },
                    ),
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
                child: Column(
                  children: [
                    SizedBox(
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
                    const SizedBox(height: 10),
                    if (_prediction != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _prediction!["icon"],
                              color: _prediction!["color"],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _prediction!["text"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _prediction!["color"],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              )
            else
              const Center(
                child: Text("No image selected."),
              ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
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
            padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 // Show AppBar with back arrow only on Home
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  final shouldExit = await _showExitConfirmationDialog();
                  if (shouldExit ?? false) {
                    exit(0); // Exit the app
                  }
                },
              ),
            )
          : null, // No AppBar for other pages
      body: _widgetOptions[_selectedIndex], // Each page handles its own content
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showImageSourceDialog();
              },
              backgroundColor: Colors.purple,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // Disable ripple effect
          highlightColor: Colors.transparent, // Disable highlight effect
        ),
        child: BottomNavigationBar(
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
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Exit App"),
          content: const Text("Are you sure you want to exit the app?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Stay in the app
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Exit the app
              },
              child: const Text("Exit"),
            ),
          ],
        );
      },
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
                  _pickImage(
                      ImageSource.gallery); // Permission check happens here
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
