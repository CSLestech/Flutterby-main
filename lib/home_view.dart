import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'dart:developer' as dev;
import 'package:check_a_doodle_doo/prediction_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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

// 1. Background Wrapper
class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final bool showOverlay;

  const BackgroundWrapper({
    super.key,
    required this.child,
    this.showOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'images/ui/main_bg.png',
            fit: BoxFit.cover,
          ),
        ),
        if (showOverlay)
          Container(
            color: Colors.black.withAlpha(100),
          ),
        child,
      ],
    );
  }
}

// 2. Loading Screen
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
    await Future.delayed(const Duration(seconds: 15));
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
      body: BackgroundWrapper(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/chick2.png',
                height: 150,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                color: Color.fromRGBO(128, 94, 2, 1),
              ),
            ],
          ),
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
  int _navigationIndex = 0; // Track the current navigation bar index
  bool _isPermissionDialogVisible = false;
  bool _isLoading = false; // Loading indicator

  // 4. Updated Carousel Images
  final List<String> _carouselImages = [
    'images/ui/scan.png',
    'images/ui/results.png',
    'images/ui/food_safety.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (_isPermissionDialogVisible) {
        final status = await Permission.storage.status;
        if (status.isGranted && mounted) {
          Navigator.of(context).pop();
          _isPermissionDialogVisible = false;
        }
      }
    }
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString('history');

      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);

        setState(() {
          _history.clear();
          _history.addAll(decoded.map((item) {
            final Map<String, dynamic> historyItem = {};

            // Text
            historyItem['text'] = item['text'];

            // Icon - convert from integer code back to IconData
            if (item.containsKey('iconCode')) {
              historyItem['icon'] = IconData(
                item['iconCode'],
                fontFamily: item['iconFontFamily'] ?? 'MaterialIcons',
                fontPackage: null,
              );
            }

            // Color - convert from integer back to Color
            if (item.containsKey('colorARGB')) {
              historyItem['color'] = Color(item['colorARGB']);
            } else if (item.containsKey('colorValue')) {
              // Handle legacy format (for backward compatibility)
              historyItem['color'] = Color(item['colorValue']);
            }

            // Image path
            historyItem['imagePath'] = item['imagePath'];

            // Timestamp
            historyItem['timestamp'] = item['timestamp'];

            return historyItem;
          }).toList());
        });

        dev.log("Loaded ${_history.length} history items", name: 'HomeView');
      }
    } catch (e) {
      dev.log("Error loading history: $e", name: 'HomeView');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      // Check if permission is already granted
      final status = await Permission.storage.status;
      if (status.isDenied) {
        // Show custom dialog first
        final bool? shouldProceed = await _showCustomPermissionDialog();
        if (shouldProceed != true) {
          return; // User canceled
        }
        // Now request actual permission
        final permissionStatus = await Permission.storage.request();
        if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
          _showPermissionDialog();
          return;
        }
      }
    } else if (source == ImageSource.camera) {
      // For camera permission
      final cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        // Show custom dialog first
        final bool? shouldProceed =
            await _showCustomPermissionDialog(isCamera: true);
        if (shouldProceed != true) {
          return; // User canceled
        }
        // Now request actual permission
        final permissionStatus = await Permission.camera.request();
        if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
          _showPermissionDialog(isCamera: true);
          return;
        }
      }
    }

    // Rest of your image picking code
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final String fileExtension =
          pickedFile.path.split('.').last.toLowerCase();
      const List<String> allowedExtensions = ['jpg', 'png'];

      if (!allowedExtensions.contains(fileExtension)) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Invalid File Format'),
              content: const Text('Only JPG and PNG file formats are allowed.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
        _prediction = null;
      });

      await _sendImageToServer(_pickedImage!);
    } else {
      log("No file selected.");
    }
  }

  // Custom pre-permission dialog
  Future<bool?> _showCustomPermissionDialog({bool isCamera = false}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF3E5AB), // Warm cream background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF3E2C1C),
          fontFamily: "Garamond",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFF3E2C1C),
          fontFamily: "Garamond",
          fontSize: 16,
        ),
        title: Text(isCamera ? 'Camera Access' : 'Gallery Access'),
        content: Text(isCamera
            ? 'This app needs camera access to take photos for analysis.'
            : 'This app needs storage permission to access your gallery.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Not Now',
              style: TextStyle(
                color: Color(0xFF3E2C1C),
                fontFamily: "Garamond",
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Color(0xFF3E2C1C),
                fontFamily: "Garamond",
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Update existing permission dialog to handle both storage and camera
  void _showPermissionDialog({bool isCamera = false}) {
    _isPermissionDialogVisible = true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF3E5AB), // Warm cream background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF3E2C1C),
          fontFamily: "Garamond",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFF3E2C1C),
          fontFamily: "Garamond",
          fontSize: 16,
        ),
        title: const Text('Permission Required'),
        content: Text(isCamera
            ? 'Camera permission is required to take photos. Please enable it in the app settings.'
            : 'Storage permission is required to access files. Please enable it in the app settings.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isPermissionDialogVisible = false;
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF3E2C1C),
                fontFamily: "Garamond",
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text(
              'Settings',
              style: TextStyle(
                color: Color(0xFF3E2C1C),
                fontFamily: "Garamond",
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendImageToServer(File imageFile) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final uri = Uri.parse("http://192.168.1.10:5000/predict");

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Hide loading indicator regardless of result
      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prediction = {
          "text": data['prediction'],
          "icon": _getPredictionIcon(data['prediction']),
          "color": _getPredictionColor(data['prediction']),
          "imagePath": imageFile.path,
          "timestamp": DateTime.now().toString(),
        };

        // Save to history
        _addToHistory({
          "text": prediction["text"],
          "icon": prediction["icon"],
          "color": prediction["color"],
          "imagePath": imageFile.path,
          "timestamp": DateTime.now().toString(),
        });

        // Navigate to History after showing prediction details
        setState(() {
          _navigationIndex = 1; // Set to History tab
          _selectedIndex = 1;
        });

        // Immediately navigate to prediction details screen
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PredictionDetailsScreen(
              imagePath: imageFile.path,
              prediction: prediction,
              timestamp: DateTime.now().toString(),
              onNavigate: (index) {
                navigateToTab(index);
              },
            ),
          ),
        );
      } else {
        // Handle server error
        if (!mounted) return;
        _showErrorDialog('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Hide loading indicator and show error dialog
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      _showErrorDialog('Network error: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF3E5AB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Error',
          style: TextStyle(
            color: Color(0xFF3E2C1C),
            fontFamily: "Garamond",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Color(0xFF3E2C1C),
            fontFamily: "Garamond",
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF3E2C1C),
                fontFamily: "Garamond",
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToHistory(Map<String, dynamic> prediction) {
    try {
      // Create a deep copy to avoid reference issues
      final Map<String, dynamic> historyCopy = {
        'text': prediction['text'],
        'icon': prediction['icon'],
        'color': prediction['color'],
        'imagePath': prediction['imagePath'],
        'timestamp': prediction['timestamp'],
      };

      setState(() {
        _history.insert(0, historyCopy);
        if (_history.length > 10) {
          _history.removeLast(); // Keep only 10 most recent entries
        }
      });

      // Now save to persistent storage
      _saveHistory();

      // Replace print statements with dev.log
      dev.log("Added to history. Current history size: ${_history.length}",
          name: 'HomeView');
      dev.log("Item added: ${prediction['text']}", name: 'HomeView');
    } catch (e) {
      dev.log("Error adding to history: $e", name: 'HomeView');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert history to a serializable format
      final List<Map<String, dynamic>> serializedHistory = _history.map((item) {
        final Map<String, dynamic> serializedItem = {};

        // Text
        serializedItem['text'] = item['text'];

        // Icon - convert to integer code
        if (item['icon'] != null && item['icon'] is IconData) {
          serializedItem['iconCode'] = (item['icon'] as IconData).codePoint;
          serializedItem['iconFontFamily'] =
              (item['icon'] as IconData).fontFamily;
        }

        // Color - convert to integer (using proper approach instead of deprecated 'value')
        if (item['color'] != null && item['color'] is Color) {
          final Color color = item['color'] as Color;
          serializedItem['colorARGB'] = color.value;
        }

        // Image path
        serializedItem['imagePath'] = item['imagePath'];

        // Timestamp
        serializedItem['timestamp'] = item['timestamp'];

        return serializedItem;
      }).toList();

      // Save as JSON
      await prefs.setString('history', jsonEncode(serializedHistory));
      dev.log("History saved successfully", name: 'HomeView');
    } catch (e) {
      dev.log("Error saving history: $e", name: 'HomeView');
    }
  }

  IconData _getPredictionIcon(String prediction) {
    switch (prediction) {
      case "Consumable":
        return Icons.check_circle;
      case "Half-Consumable":
        return Icons.warning;
      case "Not Consumable":
        return Icons.cancel;
      default:
        return Icons.error;
    }
  }

  Color _getPredictionColor(String prediction) {
    switch (prediction) {
      case "Consumable":
        return Colors.green;
      case "Half-Consumable":
        return Colors.orange;
      case "Not Consumable":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void addToHistory(Map<String, dynamic> prediction) async {
    final String timestamp = DateTime.now().toString();

    setState(() {
      _history.add({
        "imagePath": _pickedImage?.path,
        "prediction": prediction,
        "timestamp": timestamp,
      });
      if (_history.length > 5) {
        _history.removeAt(0);
      }
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedHistory = jsonEncode(_history);
    await prefs.setString('history', encodedHistory);
  }

  void navigateToTab(int index) {
    if (index == 2) {
      _showImageSourceDialog();
    } else if (index > 2) {
      setState(() {
        _navigationIndex = index;
        _selectedIndex = index - 1;
      });
    } else {
      setState(() {
        _navigationIndex = index;
        _selectedIndex = index;
      });
    }
  }

  List<Widget> get _widgetOptions => <Widget>[
        _buildHomePage(),
        HistoryPage(
          history: _history,
          onBackToHome: () {
            setState(() {
              _selectedIndex = 0;
              _navigationIndex = 0; // Add this line
            });
          },
        ),
        AboutPage(
          onBackToHome: () {
            setState(() {
              _selectedIndex = 0;
              _navigationIndex = 0; // Add this line
            });
          },
        ),
        HelpPage(
          onBackToHome: () {
            setState(() {
              _selectedIndex = 0;
              _navigationIndex = 0; // Add this line
            });
          },
        ),
      ];

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
                          color: Colors.black
                              .withAlpha(26), // Changed from withOpacity(0.1)
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
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
                color: Color.fromARGB(255, 128, 94, 2),
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
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(
                    0xFFF3E5AB), // Warm cream background - same as camera dialog
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withAlpha(26), // Changed from withOpacity(0.1)
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature["title"]!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C), // Match text color with dialog
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature["description"]!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C), // Match text color with dialog
                    ),
                  ),
                ],
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
              backgroundColor: const Color(0xFF3E2C1C), // Deep warm brown
              elevation: 4,
              iconTheme:
                  const IconThemeData(color: Color(0xFFF3E5AB)), // Warm accent
              titleTextStyle: const TextStyle(
                color: Color(0xFFF3E5AB),
                fontFamily: 'Garamond',
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              title: const Text("Home"),
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
      body: Stack(
        children: [
          BackgroundWrapper(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _widgetOptions[_selectedIndex],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(100),
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF3E5AB),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // Disable ripple effect
          highlightColor: Colors.transparent, // Disable highlight effect
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor:
              const Color.fromARGB(255, 194, 184, 146), // Warm cream background
          selectedItemColor: const Color.fromARGB(
              255, 98, 72, 46), // Inactive item: soft brown
          unselectedItemColor: Colors.black
              .withAlpha(77), // ~30% opacity // Active item: dark brown
          selectedIconTheme:
              const IconThemeData(size: 28), // Highlight selected icon
          unselectedIconTheme:
              const IconThemeData(size: 24), // Standard unselected size
          currentIndex: _navigationIndex,
          onTap: (int index) {
            navigateToTab(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: _navigationIndex == 0 ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: _navigationIndex == 1 ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.history),
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: _navigationIndex == 2 ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.camera_alt),
              ),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: _navigationIndex == 3
                    ? 1.2
                    : 1.0, // Use navigation index now
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.info),
              ),
              label: 'About',
            ),
            BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: _navigationIndex == 4
                    ? 1.2
                    : 1.0, // Use navigation index now
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.help),
              ),
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
          backgroundColor: const Color(0xFFF3E5AB),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titleTextStyle: const TextStyle(
            color: Color(0xFF3E2C1C),
            fontFamily: "Garamond",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: Color(0xFF3E2C1C),
            fontFamily: "Garamond",
            fontSize: 16,
          ),
          title: const Text("Exit App"),
          content: const Text("Are you sure you want to exit the app?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFF3E2C1C),
                  fontFamily: "Garamond",
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Exit",
                style: TextStyle(
                  color: Color(0xFF3E2C1C),
                  fontFamily: "Garamond",
                ),
              ),
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
          backgroundColor: const Color(0xFFF3E5AB), // Warm cream background
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titleTextStyle: const TextStyle(
            color: Color(0xFF3E2C1C),
            fontFamily: "Garamond",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          title: const Text("Select Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera, color: Color(0xFF3E2C1C)),
                title: const Text(
                  "Take a Picture",
                  style: TextStyle(
                    color: Color(0xFF3E2C1C),
                    fontFamily: "Garamond",
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_album, color: Color(0xFF3E2C1C)),
                title: const Text(
                  "Select from Gallery",
                  style: TextStyle(
                    color: Color(0xFF3E2C1C),
                    fontFamily: "Garamond",
                    fontSize: 16,
                  ),
                ),
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
        backgroundColor:
            const Color(0xFF3E2C1C), // Deep warm brown - same as About page
        elevation: 4,
        iconTheme: const IconThemeData(color: Color(0xFFF3E5AB)), // Warm accent
        titleTextStyle: const TextStyle(
          color: Color(0xFFF3E5AB),
          fontFamily: 'Garamond',
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        title: const Text("History"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackToHome,
        ),
      ),
      body: BackgroundWrapper(
        child: history.isEmpty
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
                            imagePath: entry["imagePath"],
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
                            if (imagePath != null &&
                                File(imagePath).existsSync())
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
      ),
    );
  }
}
