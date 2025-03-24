import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'about_page.dart';
import 'history_page.dart';
import 'help_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding and decoding

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  File? _pickedImage;
  String? _prediction;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _history = []; // Update the type of _history
  int _selectedIndex = 0;
  // Removed unused _buttonStates field

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
    _loadHistory(); // Load history when the app starts
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
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
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
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 5),
            if (_prediction != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    _prediction!,
                    textAlign: TextAlign.center, // Center the text
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          Colors.red, // Optional: Highlight invalid text in red
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
        title: Text(
          _selectedIndex == 0
              ? "Chicken Defect Classification"
              : _selectedIndex == 1
                  ? "History"
                  : _selectedIndex == 2
                      ? "About"
                      : "Help",
        ),
        centerTitle: true,
        elevation: 0,
        leading: _selectedIndex == 0
            ? null // No back arrow on the Home page
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0; // Navigate back to the Home page
                  });
                },
              ),
      ),
      body: _widgetOptions[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _showImageSourceDialog,
              backgroundColor:
                  Colors.transparent, // Make the button background transparent
              elevation: 0, // Remove the shadow
              child: const Icon(
                Icons.add_a_photo,
                color: Colors.purple, // Keep the icon visible with a color
              ),
            )
          : null,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // Disable ripple effect
        ),
        child: BottomNavigationBar(
          items: _selectedIndex == 0
              ? const <BottomNavigationBarItem>[
                  // Show only History, About, and Help on the Home page
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
                ]
              : const <BottomNavigationBarItem>[
                  // Show Home, History, About, and Help on other pages
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
          selectedItemColor: Colors.purple, // Purple for the selected item
          unselectedItemColor: Colors.grey, // Grey for unselected items
          onTap: (int index) {
            setState(() {
              if (_selectedIndex == 0) {
                // If on the Home page, adjust index for navigation
                _selectedIndex = index + 1;
              } else if (index == 0) {
                // Navigate back to the Home page
                _selectedIndex = 0;
              } else {
                // Navigate to other pages
                _selectedIndex = index;
              }
            });
          },
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Take a Picture"),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text("Select from Gallery"),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (!pickedFile.path.endsWith('.jpg') &&
          !pickedFile.path.endsWith('.png')) {
        setState(() {
          _prediction = "Invalid file format. Only JPG and PNG are allowed.";
        });
        return;
      }

      setState(() {
        _pickedImage = File(pickedFile.path);
        _prediction = null;
      });

      // Call the dummy model to generate a prediction
      _generateDummyPrediction();
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
      _prediction = prediction;
      _addToHistory(prediction); // Add the prediction to history
    });
  }

  Future<void> _saveHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedHistory =
        jsonEncode(_history); // Convert history to JSON
    await prefs.setString('history', encodedHistory); // Save to local storage
  }

  Future<void> _loadHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedHistory =
        prefs.getString('history'); // Load from local storage
    if (encodedHistory != null) {
      setState(() {
        _history.clear();
        _history.addAll(
            List<Map<String, dynamic>>.from(jsonDecode(encodedHistory)));
      });
    }
  }

  void _addToHistory(String prediction) {
    final String timestamp = DateTime.now().toString(); // Add timestamp
    setState(() {
      // Add the new entry
      _history.add({
        "image": _pickedImage
            ?.path, // Save the image path instead of the File object
        "prediction":
            "$timestamp: $prediction", // Save the prediction with timestamp
      });

      // Limit history to 5 entries
      if (_history.length > 5) {
        _history.removeAt(0); // Remove the oldest entry
      }
    });

    _saveHistory(); // Save the updated history to local storage
  }
}
