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
import 'package:check_a_doodle_doo/utils/confidence_tracker.dart';

import 'about_page.dart';
import 'history_page.dart';
import 'help_page.dart';
import 'widgets/guide_book_button.dart';
import 'widgets/guide_book_modal.dart'; // Add this import for GuideBookModal
import 'utils/performance_monitor.dart'; // Import the performance monitor
import 'widgets/custom_loading_screen.dart'; // Add this import

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

// Create a separate hoverable card widget at the top of the file
class HoverableCard extends StatefulWidget {
  final String title;
  final String description;
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const HoverableCard({
    super.key,
    required this.title,
    required this.description,
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: Tooltip(
        message: widget.tooltip,
        textStyle: const TextStyle(
          color: Color(0xFFF3E5AB),
          fontSize: 14,
          fontFamily: "Garamond",
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF3E2C1C),
          borderRadius: BorderRadius.circular(8),
        ),
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(seconds: 2),
        preferBelow: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHovering
                ? const Color(0xFFF3E5AB)
                : const Color(0xFFF3E5AB).withAlpha(230),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: isHovering
                    ? Colors.black.withAlpha(40)
                    : Colors.black.withAlpha(26),
                spreadRadius: isHovering ? 2 : 1,
                blurRadius: isHovering ? 6 : 4,
                offset: isHovering ? const Offset(0, 3) : const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isHovering
                  ? const Color(0xFF3E2C1C).withAlpha(40)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Garamond",
                          color: const Color(0xFF3E2C1C),
                          letterSpacing: isHovering ? 0.5 : 0,
                        ),
                      ),
                      Icon(
                        widget.icon,
                        color: const Color(0xFF3E2C1C),
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "Garamond",
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: isHovering ? 24 : 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isHovering)
                          const Text(
                            "Click to access",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: "Garamond",
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF3E2C1C),
                            ),
                          ),
                        if (isHovering) const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: const Color(0xFF3E2C1C),
                          size: isHovering ? 18 : 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

// 2. Loading Screen Wrapper
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
    await Future.delayed(
        const Duration(seconds: 3)); // Changed from 15 to 3 seconds
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const CustomLoadingScreen();
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _history = [];
  int _selectedIndex = 0;
  int _navigationIndex = 0; // Track the current navigation bar index
  bool _isPermissionDialogVisible = false;
  ImageSource? _lastRequestedSource; // Track the last requested source

  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  // Add these constants at the class level
  static const IconData consumableIcon = Icons.check_circle;
  static const IconData halfConsumableIcon = Icons.warning;
  static const IconData notConsumableIcon = Icons.cancel;
  static const IconData defaultIcon = Icons.error;

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
    // Make sure to stop any active monitoring
    _performanceMonitor.stopCpuMonitoring();
    _performanceMonitor.stopFrameMonitoring();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (_isPermissionDialogVisible) {
        // Check both storage and camera permissions
        final storageStatus = await Permission.storage.status;
        final cameraStatus = await Permission.camera.status;

        if ((storageStatus.isGranted || cameraStatus.isGranted) && mounted) {
          Navigator.of(context).pop();
          _isPermissionDialogVisible = false;

          // If camera permission was just granted, proceed with camera action
          if (cameraStatus.isGranted &&
              _lastRequestedSource == ImageSource.camera) {
            _pickImageAfterPermission(ImageSource.camera);
          }
          // If storage permission was just granted, proceed with gallery action
          else if (storageStatus.isGranted &&
              _lastRequestedSource == ImageSource.gallery) {
            _pickImageAfterPermission(ImageSource.gallery);
          }
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
            final Map<String, dynamic> historyItem =
                Map<String, dynamic>.from({});

            // Text
            historyItem['text'] = item['text'];

            // Icon - convert from integer code back to IconData
            if (item.containsKey('iconCode')) {
              int iconCode = item['iconCode'];
              // Map to constant IconData objects
              if (iconCode == Icons.check_circle.codePoint) {
                historyItem['icon'] = consumableIcon;
              } else if (iconCode == Icons.warning.codePoint) {
                historyItem['icon'] = halfConsumableIcon;
              } else if (iconCode == Icons.cancel.codePoint) {
                historyItem['icon'] = notConsumableIcon;
              } else {
                historyItem['icon'] = defaultIcon;
              }
            }

            // Color - convert from integer back to Color
            if (item.containsKey('colorARGB')) {
              final int colorInt = item['colorARGB'] as int;
              historyItem['color'] = Color.fromARGB(
                (colorInt >> 24) & 0xFF, // Alpha
                (colorInt >> 16) & 0xFF, // Red
                (colorInt >> 8) & 0xFF, // Green
                colorInt & 0xFF, // Blue
              );
            } else if (item.containsKey('colorValue')) {
              // Handle legacy format (for backward compatibility)
              final int colorInt = item['colorValue'] as int;
              historyItem['color'] = Color.fromARGB(
                255, // Full opacity for legacy colors
                (colorInt >> 16) & 0xFF, // Red
                (colorInt >> 8) & 0xFF, // Green
                colorInt & 0xFF, // Blue
              );
            }

            // Image path
            historyItem['imagePath'] = item['imagePath'];

            // Timestamp
            historyItem['timestamp'] = item['timestamp'];

            // CRITICAL FIX: Better confidence score handling
            try {
              // Step 1: Get the raw value
              final dynamic rawConfidence = item['confidenceScore'];

              // Step 2: Handle different types properly
              if (rawConfidence != null) {
                if (rawConfidence is double) {
                  historyItem['confidenceScore'] = rawConfidence;
                } else if (rawConfidence is num) {
                  historyItem['confidenceScore'] = rawConfidence.toDouble();
                } else if (rawConfidence is String) {
                  historyItem['confidenceScore'] =
                      double.tryParse(rawConfidence) ?? 0.75;
                } else {
                  // If type is unexpected, use a reasonable default
                  historyItem['confidenceScore'] = 0.75;
                }
              } else {
                // If confidence score is missing or null, set a reasonable default
                historyItem['confidenceScore'] = 0.75;
              }

              // Step 3: Ensure it's in a valid range
              historyItem['confidenceScore'] =
                  (historyItem['confidenceScore'] as double).clamp(0.0, 1.0);
            } catch (e) {
              // Recovery in case of deserialization issues
              dev.log("Error parsing confidence score: $e",
                  name: 'HistoryLoader');
              historyItem['confidenceScore'] = 0.75;
            }

            dev.log(
                "Loaded history item: ${item['text']} with confidence: ${historyItem['confidenceScore']}",
                name: 'HistoryLoader');

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
    _lastRequestedSource = source; // Track the last requested source

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
      // For camera permission - ensure we show the permission dialog
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
          // This is the critical fix - ensure dialog is always shown
          _showPermissionDialog(isCamera: true);
          return;
        }
      }
    }

    // Proceed with image picking after permissions are confirmed
    _pickImageAfterPermission(source);
  }

  Future<void> _pickImageAfterPermission(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        final String fileExtension =
            pickedFile.path.split('.').last.toLowerCase();
        const List<String> allowedExtensions = ['jpg', 'png'];

        if (!allowedExtensions.contains(fileExtension)) {
          // Invalid file format handling
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor:
                    const Color(0xFFF3E5AB), // Warm cream background
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
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
                title: const Text('Invalid File Format'),
                content:
                    const Text('Only JPG and PNG file formats are allowed.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
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
          debugPrint("Invalid file format: $fileExtension");
          return;
        }

        setState(() {
          _pickedImage = File(pickedFile.path);
        });

        await _sendImageToServer(_pickedImage!);
      } else {
        log("No file selected.");
      }
    } catch (e) {
      log("Error picking image: ${e.toString()}");

      if (mounted) {
        // Show a user-friendly error message based on the error type
        if (e.toString().contains("camera") || source == ImageSource.camera) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFFF3E5AB),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
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
              title: const Text('Camera Error'),
              content: const Text(
                  'Unable to access the camera. The camera may be in use by another application or your device may need to be restarted.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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
        } else {
          _showErrorDialog('Error accessing media: ${e.toString()}');
        }
      }
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
    // Instead of setting _isLoading state, show the full-screen loading overlay
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: Duration.zero,
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) {
        return const CustomLoadingScreen(
          message: "Analyzing chicken image...",
        );
      },
    );

    // Start the timer for total round-trip time
    final Stopwatch timer = Stopwatch()..start();

    // Start performance monitoring
    await _performanceMonitor.startCpuMonitoring();
    _performanceMonitor.startFrameMonitoring(this);

    dev.log("🔍 Starting image classification performance test",
        name: 'PerformanceTest');

    final uri = Uri.parse("http://192.168.1.11:5000/predict");

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

      // Stop timer and calculate elapsed time
      timer.stop();

      // Stop performance monitoring and get results
      await _performanceMonitor.stopCpuMonitoring();
      _performanceMonitor.stopFrameMonitoring();

      // Close the loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Log full raw response for debugging
        dev.log("FULL SERVER RESPONSE: ${response.body}", name: 'ServerDebug');

        // Track raw response for debugging confidence issues
        ConfidenceTracker.logScore(
            "1_RAW_SERVER_RESPONSE",
            data.containsKey('confidenceScore')
                ? data['confidenceScore']
                : null,
            {'response_keys': data.keys.toList()});

        // Extract confidence score from the server response
        // Use the consistent 'confidenceScore' field name from the server
        double confidenceScore = 0.0;

        if (data.containsKey('confidenceScore')) {
          // Direct extraction from our standard field name
          confidenceScore = _extractDoubleValue(data['confidenceScore']);
          ConfidenceTracker.logScore(
              "2_FOUND_CONFIDENCE_SCORE", confidenceScore);
          dev.log("Using confidenceScore field: $confidenceScore",
              name: 'ModelConfidence');
        }
        // Fallback to class probabilities if available
        else if (data.containsKey('class_probabilities')) {
          final Map<String, dynamic> probabilities =
              data['class_probabilities'];
          dev.log("Class probabilities found: $probabilities",
              name: 'ModelConfidence');
          confidenceScore = probabilities.values
              .map((v) => _extractDoubleValue(v))
              .reduce((a, b) => a > b ? a : b);
          ConfidenceTracker.logScore(
              "2_USING_CLASS_PROBABILITIES", confidenceScore, probabilities);
          dev.log("Using highest probability: $confidenceScore",
              name: 'ModelConfidence');
        }
        // Try legacy field names
        else if (data.containsKey('confidence')) {
          confidenceScore = _extractDoubleValue(data['confidence']);
          ConfidenceTracker.logScore(
              "2_USING_LEGACY_CONFIDENCE", confidenceScore);
          dev.log("Using legacy confidence field: $confidenceScore",
              name: 'ModelConfidence');
        } else if (data.containsKey('score')) {
          confidenceScore = _extractDoubleValue(data['score']);
          ConfidenceTracker.logScore("2_USING_SCORE_FIELD", confidenceScore);
          dev.log("Using score field: $confidenceScore",
              name: 'ModelConfidence');
        }
        // Handle case when no confidence data is available
        else {
          dev.log(
              "No confidence data found in model response. Using default value.",
              name: 'ModelConfidence');
          dev.log("Available fields: ${data.keys.toList()}",
              name: 'ModelConfidence');
          confidenceScore =
              0.75; // Default reasonable value if no confidence provided
          ConfidenceTracker.logScore("2_USING_DEFAULT_VALUE", confidenceScore);
        }

        // Ensure confidence score is within valid range [0,1]
        confidenceScore = confidenceScore.clamp(0.0, 1.0);
        ConfidenceTracker.logScore("3_AFTER_CLAMP", confidenceScore);

        // Log final confidence for debugging
        dev.log("FINAL CONFIDENCE: $confidenceScore", name: 'ConfidenceDebug');

        // Create prediction with guaranteed double confidence score
        final Map<String, dynamic> prediction = {
          "text": data['prediction'],
          "icon": _getPredictionIcon(data['prediction']),
          "color": _getPredictionColor(data['prediction']),
          "imagePath": imageFile.path,
          "timestamp": DateTime.now().toString(),
          "processingTime": data.containsKey('processing_time_sec')
              ? _extractDoubleValue(data['processing_time_sec'])
              : null,
          "confidenceScore": confidenceScore,
        };

        ConfidenceTracker.logScore(
            "4_PREDICTION_OBJECT",
            prediction["confidenceScore"],
            {'prediction_type': prediction["text"]});

        // Log prediction object before saving to history
        dev.log("PREDICTION TO SAVE: ${prediction.toString()}",
            name: 'HistoryDebug');

        // Create a direct, separate copy specifically for history to avoid reference issues
        final Map<String, dynamic> historyItem = Map<String, dynamic>.from({
          "text": prediction["text"],
          "icon": prediction["icon"],
          "color": prediction["color"],
          "imagePath": imageFile.path,
          "timestamp": DateTime.now().toString(),
          // PERMANENT FIX: Always ensure confidence score is a proper double
          "confidenceScore": double.parse(confidenceScore.toString()),
        });

        // Debug verification
        dev.log("CONFIDENCE BEFORE HISTORY: $confidenceScore", name: 'FIX');
        dev.log("CONFIDENCE IN HISTORY ITEM: ${historyItem['confidenceScore']}",
            name: 'FIX');

        ConfidenceTracker.logScore(
            "5_HISTORY_ITEM", historyItem["confidenceScore"]);

        // Save to history with direct copy
        await _addToHistory(historyItem);

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
      } else if (response.statusCode == 400) {
        // Handle 400 Bad Request - Likely not a chicken breast image
        if (!mounted) return;
        _showErrorDialog(
            'Unable to analyze this image. Please ensure you are uploading a clear image of chicken breast.',
            title: 'Analysis Failed');
      } else if (response.statusCode == 500) {
        // Handle 500 Internal Server Error
        if (!mounted) return;
        _showErrorDialog(
            'The server encountered an internal error. Please try again later.',
            title: 'Server Error');
      } else {
        // Handle other status codes
        if (!mounted) return;
        _showErrorDialog('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Stop performance monitoring in case of error
      await _performanceMonitor.stopCpuMonitoring();
      _performanceMonitor.stopFrameMonitoring();

      // Close the loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;
      _showErrorDialog('Network error: ${e.toString()}');
    }
  }

  // Helper method to safely extract double values from any data type
  double _extractDoubleValue(dynamic value) {
    double result = 0.0;
    if (value == null) {
      return result;
    }

    if (value is double) {
      result = value;
    } else if (value is int) {
      result = value.toDouble();
    } else if (value is String) {
      result = double.tryParse(value) ?? 0.0;
    }

    ConfidenceTracker.logScore("EXTRACT_VALUE", result, {
      'input_type': value.runtimeType.toString(),
      'raw_value': value.toString()
    });

    return result;
  }

  void _showErrorDialog(String message, {String title = 'Error'}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF3E5AB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
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

  Future<void> _addToHistory(Map<String, dynamic> prediction) async {
    try {
      // Create a deep copy for history
      final Map<String, dynamic> historyCopy = {
        'text': prediction['text'],
        'icon': prediction['icon'],
        'color': prediction['color'],
        'imagePath': prediction['imagePath'],
        'timestamp': prediction['timestamp'],
      };

      // Handle confidence score explicitly
      if (prediction.containsKey('confidenceScore')) {
        final dynamic rawScore = prediction['confidenceScore'];
        if (rawScore is double) {
          historyCopy['confidenceScore'] = rawScore;
        } else if (rawScore is num) {
          historyCopy['confidenceScore'] = rawScore.toDouble();
        } else if (rawScore is String) {
          historyCopy['confidenceScore'] = double.tryParse(rawScore) ?? 0.85;
        } else {
          historyCopy['confidenceScore'] = 0.85; // Default fallback
        }
      } else {
        historyCopy['confidenceScore'] = 0.85; // Default if missing
      }

      // Ensure confidence score is within valid range
      historyCopy['confidenceScore'] =
          (historyCopy['confidenceScore'] as double).clamp(0.0, 1.0);

      setState(() {
        _history.insert(0, historyCopy);
        if (_history.length > 10) {
          _history.removeLast();
        }
      });

      // Save to SharedPreferences immediately
      await _saveHistory();
    } catch (e) {
      dev.log("Error adding to history: $e", name: 'HomeView');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert history to a serializable format with explicit confidence score handling
      final List<Map<String, dynamic>> serializedHistory = _history.map((item) {
        // First, ensure we have a valid confidence score
        double confidenceScore = 0.85; // Default value
        if (item.containsKey('confidenceScore')) {
          if (item['confidenceScore'] is double) {
            confidenceScore = item['confidenceScore'];
          } else if (item['confidenceScore'] is num) {
            confidenceScore = (item['confidenceScore'] as num).toDouble();
          } else if (item['confidenceScore'] is String) {
            confidenceScore = double.tryParse(item['confidenceScore']) ?? 0.85;
          }
        }

        // Clamp the confidence score to valid range
        confidenceScore = confidenceScore.clamp(0.0, 1.0);

        return {
          'text': item['text'],
          'iconCode': (item['icon'] as IconData).codePoint,
          'iconFontFamily': (item['icon'] as IconData).fontFamily,
          // Fix: Replace deprecated 'value' with toARGB32()
          'colorARGB': (item['color'] as Color).toARGB32(),
          'imagePath': item['imagePath'],
          'timestamp': item['timestamp'],
          'confidenceScore': confidenceScore, // Store as double
        };
      }).toList();

      // Debug log the confidence scores being saved
      for (var item in serializedHistory) {
        dev.log(
            "Saving history item with confidence: ${item['confidenceScore']}",
            name: 'HistorySerializer');
      }

      await prefs.setString('history', jsonEncode(serializedHistory));
    } catch (e) {
      dev.log("Error saving history: $e", name: 'HomeView');
    }
  }

  IconData _getPredictionIcon(String prediction) {
    switch (prediction) {
      case "Consumable":
        return consumableIcon;
      case "Half-consumable":
        return halfConsumableIcon;
      case "Not consumable":
        return notConsumableIcon;
      default:
        return defaultIcon;
    }
  }

  Color _getPredictionColor(String prediction) {
    switch (prediction) {
      case "Consumable":
        return Colors.green;
      case "Half-consumable":
        return Colors.orange;
      case "Not consumable":
        return Colors.red;
      default:
        return Colors.grey;
    }
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
            const SizedBox(height: 20),
            // Add chicken pattern background with testimonials section
            // _buildTestimonialsSection(),  // Removed Food Safety Insights section
            const SizedBox(height: 30),
            // Removed the image display section since users are redirected to prediction details
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionalCards() {
    final List<Map<String, dynamic>> features = [
      {
        "title": "Chicken Analysis",
        "description":
            "Classify chicken breast as consumable, half-consumable, or not consumable.",
        "tooltip":
            "Scan chicken breast to determine freshness and quality level",
        "icon": Icons.check_circle_outline,
        "action": () =>
            _showImageSourceDialog(), // Navigate to camera/gallery selection
      },
      {
        "title": "History Tracking",
        "description": "Keep track of your previous uploads and predictions.",
        "tooltip": "View your past scans and analysis results",
        "icon": Icons.history,
        "action": () => navigateToTab(1), // Navigate to History tab
      },
      {
        "title": "User-Friendly",
        "description": "Simple and intuitive interface for easy navigation.",
        "tooltip": "Access our comprehensive user guide for app instructions",
        "icon": Icons.menu_book,
        "action": () {
          // Open GuideBook modal
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const GuideBookModal();
            },
          );
        },
      },
      {
        "title": "Fast Processing",
        "description": "Get predictions in seconds with high accuracy.",
        "tooltip": "View detailed results of your latest scan",
        "icon": Icons.speed,
        "action": () {
          // If there's at least one item in history, navigate to the latest prediction details
          if (_history.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PredictionDetailsScreen(
                  imagePath: _history.first['imagePath'],
                  prediction: _history.first,
                  timestamp: _history.first['timestamp'],
                  onNavigate: (index) {
                    navigateToTab(index);
                  },
                ),
              ),
            );
          } else {
            // If no history, show a dialog suggesting to try the camera
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: const Color(0xFFF3E5AB),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text(
                    "No Predictions Yet",
                    style: TextStyle(
                      color: Color(0xFF3E2C1C),
                      fontFamily: "Garamond",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    "Take a picture or select an image to see prediction results.",
                    style: TextStyle(
                      color: Color(0xFF3E2C1C),
                      fontFamily: "Garamond",
                      fontSize: 16,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFF3E2C1C),
                          fontFamily: "Garamond",
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showImageSourceDialog();
                      },
                      child: const Text(
                        "Take Picture",
                        style: TextStyle(
                          color: Color(0xFF3E2C1C),
                          fontFamily: "Garamond",
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      },
    ];

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: HoverableCard(
              title: feature["title"],
              description: feature["description"],
              tooltip: feature["tooltip"],
              icon: feature["icon"],
              onTap: feature["action"],
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
              // Add the guide book button here
              actions: const [
                GuideBookButton(),
              ],
            )
          : null, // No AppBar for other pages
      body: BackgroundWrapper(
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
