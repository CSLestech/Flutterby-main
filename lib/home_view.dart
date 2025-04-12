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
    if (!mounted) return; // Ensure the widget is still mounted
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

class HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  File? _pickedImage;
  Map<String, dynamic>? _prediction;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _history = [];
  int _selectedIndex = 0;
  bool _isPermissionDialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    _loadHistory(); // Load history when the app starts
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Check storage permission when the app resumes
      if (_isPermissionDialogVisible) {
        final status = await Permission.storage.status;
        if (status.isGranted && mounted) {
          Navigator.of(context).pop(); // Dismiss the dialog
          _isPermissionDialogVisible = false;
        }
      }
    }
  }

  Future<void> _loadHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedHistory = prefs.getString('history');
    if (encodedHistory != null) {
      setState(() {
        _history.clear();
        _history.addAll(
            List<Map<String, dynamic>>.from(jsonDecode(encodedHistory)));
      });
    }
  }

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
        Container(), // Placeholder for the camera button
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

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      // Check and request storage permission
      final status = await Permission.storage.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        _showPermissionDialog();
        return; // Exit if permission is not granted
      }
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final String fileExtension =
          pickedFile.path.split('.').last.toLowerCase();
      const List<String> allowedExtensions = ['jpg', 'png']; // Allowed formats

      if (!allowedExtensions.contains(fileExtension)) {
        if (mounted) {
          // Ensure the widget is still mounted before using context
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Invalid File Format'),
              content: const Text('Only JPG and PNG file formats are allowed.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        debugPrint("Invalid file format: $fileExtension");
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

    // Clear the home page after 60 seconds
    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        _pickedImage = null;
        _prediction = null;
      });
    });
  }

  void _addToHistory(Map<String, dynamic> prediction) async {
    final String timestamp = DateTime.now().toString();

    setState(() {
      _history.add({
        "imagePath": _pickedImage?.path,
        "prediction": prediction,
        "timestamp": timestamp,
      });
      if (_history.length > 5) {
        _history.removeAt(0); // Keep only the last 5 entries
      }
    });

    // Save history to SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedHistory = jsonEncode(_history);
    await prefs.setString('history', encodedHistory);
  }

  void _showPermissionDialog() {
    _isPermissionDialogVisible = true;
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
              _isPermissionDialogVisible = false;
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
                viewportFraction: 0.9,
                aspectRatio: 16 / 9,
                autoPlayInterval: const Duration(seconds: 2),
                autoPlayAnimationDuration: const Duration(milliseconds: 400),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              items: _carouselImages.map((imagePath) {
                log("Loading image: $imagePath");
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _prediction!["icon"],
                              color: _prediction!["color"],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _prediction!["text"],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _prediction!["color"],
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
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
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // Disable ripple effect
          highlightColor: Colors.transparent, // Disable highlight effect
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white, // Set the background color to blend
          selectedItemColor: Colors.purple, // Active item color
          unselectedItemColor: Colors.grey, // Inactive item color
          currentIndex: _selectedIndex,
          onTap: (int index) {
            if (index == 2) {
              // Handle camera button tap
              _showImageSourceDialog();
            } else {
              setState(() {
                _selectedIndex = index; // Update the selected index
              });
            }
          },
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
              icon: Icon(Icons.camera_alt), // Camera button in the center
              label: 'Camera',
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

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final VoidCallback onBackToHome;

  const HistoryPage({
    super.key,
    required this.history,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackToHome,
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
                final String? imagePath = entry["imagePath"];
                final Map<String, dynamic> prediction = entry["prediction"];
                final String timestamp = entry["timestamp"];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryDetailPage(
                          imagePath: entry[
                              "imagePath"], // Ensure this key matches the data structure
                          prediction: entry["prediction"],
                          timestamp: entry["timestamp"],
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: prediction["color"],
                                  ),
                                ),
                              ],
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
