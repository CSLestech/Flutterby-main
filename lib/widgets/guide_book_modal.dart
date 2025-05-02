import 'package:flutter/material.dart'; // Core Flutter framework
import 'guide_book_button.dart'; // Import for accessing guide content data
import 'package:flutter_tts/flutter_tts.dart'; // Text-to-speech capabilities
import 'dart:developer' as dev; // Advanced logging functionality
import 'dart:async'; // For asynchronous operations
import 'package:url_launcher/url_launcher.dart'; // For launching external URLs (videos)

/// GuideBookModal is a dialog widget that presents educational content about chicken quality
/// Features include multi-page content, responsive design, and text-to-speech capabilities
class GuideBookModal extends StatefulWidget {
  const GuideBookModal({super.key}); // Default constructor

  @override
  State<GuideBookModal> createState() =>
      _GuideBookModalState(); // Create state object
}

/// State class for GuideBookModal that manages content pages and text-to-speech
class _GuideBookModalState extends State<GuideBookModal> {
  final PageController _pageController =
      PageController(); // Controls page navigation
  int _currentPage = 0; // Tracks which page is currently displayed
  int _totalPages = 0; // Stores total number of pages in the guide
  List<Map<String, dynamic>> _contentPages = []; // Holds all content data

  // Text to speech variables
  FlutterTts? _flutterTts; // TTS engine instance
  bool _isSpeaking = false; // Tracks if TTS is currently active
  String? _currentlyReadingText; // Currently being read text
  bool _ttsInitialized = false; // Flag for successful TTS initialization
  final double _volume = 1.0; // TTS volume (max)
  final double _pitch = 1.0; // TTS pitch (normal)
  final double _rate = 0.5; // TTS speech rate (slower for better comprehension)
  final String _selectedLanguage = "en-US"; // TTS language

  @override
  void initState() {
    super.initState();
    // Load content data from GuideBookContent class
    _contentPages = GuideBookContent.getContentPages();

    // Calculate total pages by counting tips and visual parameters
    _totalPages = _contentPages.isNotEmpty
        ? _contentPages[0]['visualParameters'].length +
            (_contentPages[0]['tips']?.length ?? 0)
        : 0;

    // Initialize text-to-speech engine
    _initTts();
  }

  /// Initialize the text to speech engine with robust error handling
  Future<void> _initTts() async {
    dev.log("Initializing TTS...", name: 'TTS'); // Log initialization start

    try {
      _flutterTts = FlutterTts(); // Create new TTS instance

      // Configure TTS settings for optimal readability
      await _flutterTts!
          .setLanguage(_selectedLanguage); // Set language to English
      await _flutterTts!.setSpeechRate(_rate); // Set slower rate for clarity
      await _flutterTts!.setVolume(_volume); // Set full volume
      await _flutterTts!.setPitch(_pitch); // Set normal pitch

      // Set handlers for TTS events to update UI accordingly
      _flutterTts!.setStartHandler(() {
        dev.log("TTS Started", name: 'TTS'); // Log when speech starts
        setState(() {
          _isSpeaking = true; // Update UI to show speaking state
        });
      });

      _flutterTts!.setCompletionHandler(() {
        dev.log("TTS Completed", name: 'TTS'); // Log when speech completes
        setState(() {
          _isSpeaking = false; // Update UI to show speech ended
          _currentlyReadingText = null; // Clear current text
        });
      });

      _flutterTts!.setErrorHandler((error) {
        dev.log("TTS Error: $error", name: 'TTS'); // Log any TTS errors
        setState(() {
          _isSpeaking = false; // Update UI on error
          _currentlyReadingText = null; // Clear current text
        });
      });

      // Mark TTS as successfully initialized
      setState(() {
        _ttsInitialized = true;
      });

      dev.log("TTS initialized successfully", name: 'TTS');
    } catch (e) {
      dev.log("TTS Initialization Error: $e",
          name: 'TTS'); // Log initialization failure
      setState(() {
        _ttsInitialized = false; // Mark TTS as not available
      });
      _showTtsErrorDialog('$e'); // Show error to user
    }
  }

  /// Speak the given text with error handling and chunking for long text
  Future<void> _speak(String text) async {
    // Verify TTS is initialized or try to initialize it
    if (!_ttsInitialized || _flutterTts == null) {
      dev.log("TTS not initialized, attempting to initialize now", name: 'TTS');
      await _initTts();
      if (!_ttsInitialized) {
        dev.log("Failed to initialize TTS", name: 'TTS');
        if (mounted) {
          // Notify user if TTS is unavailable
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Text-to-speech not available"),
            duration: Duration(seconds: 2),
          ));
        }
        return;
      }
    }

    // If already speaking, stop current speech
    if (_isSpeaking) {
      await _stopSpeaking();
      // If requested to read the same text again, just stop (toggle behavior)
      if (_currentlyReadingText == text) {
        setState(() {
          _currentlyReadingText = null; // Clear current text
        });
        return;
      }
    }

    // Validate text isn't empty
    if (text.trim().isEmpty) {
      dev.log("Empty text provided, nothing to speak", name: 'TTS');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No text to read"),
          duration: Duration(seconds: 2),
        ));
      }
      return;
    }

    try {
      setState(() {
        _isSpeaking = true; // Update UI to show speaking state
        _currentlyReadingText = text; // Store current text
      });

      // Ensure any pending speech is stopped
      await _flutterTts!.stop();

      // For long text, break into chunks to improve stability
      if (text.length > 4000) {
        // TTS engines often have limits on text length
        // Break text into sentences for more natural pauses
        final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
        var currentChunk = "";

        for (var sentence in sentences) {
          // Build chunks of reasonable size
          if ((currentChunk + sentence).length < 3900) {
            currentChunk += "$sentence ";
          } else {
            // Speak current chunk and wait for completion
            await _flutterTts!.speak(currentChunk);
            await Future.delayed(const Duration(
                milliseconds: 500)); // Brief pause between chunks
            currentChunk = "$sentence "; // Start new chunk
          }
        }

        // Speak any remaining text
        if (currentChunk.isNotEmpty) {
          await _flutterTts!.speak(currentChunk);
        }
      } else {
        // For shorter text, speak it all at once
        await _flutterTts!.speak(text);
      }

      dev.log("TTS started successfully", name: 'TTS');
    } catch (e) {
      dev.log("Error speaking text: $e", name: 'TTS');
      setState(() {
        _isSpeaking = false;
        _currentlyReadingText = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Speech error: $e"),
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  /// Display error dialog when TTS fails to initialize
  void _showTtsErrorDialog(String error) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Text-to-Speech Error'),
          content: Text('Could not initialize text-to-speech: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Stop ongoing text-to-speech with error handling
  Future<void> _stopSpeaking() async {
    try {
      if (_flutterTts != null && _isSpeaking) {
        await _flutterTts!.stop(); // Stop the TTS engine
        setState(() {
          _isSpeaking = false; // Update UI state
        });
      }
    } catch (e) {
      dev.log("Error stopping TTS: $e", name: 'TTS');
    }
  }

  /// Clean up resources to prevent memory leaks
  @override
  void dispose() {
    _pageController.dispose(); // Dispose of page controller
    _stopTts(); // Stop any ongoing TTS
    super.dispose();
  }

  /// Properly clean up TTS resources
  Future<void> _stopTts() async {
    if (_flutterTts != null) {
      try {
        await _flutterTts!.stop(); // Stop any ongoing speech
        await _flutterTts!.awaitSpeakCompletion(false); // Release resources
      } catch (e) {
        dev.log("Error disposing TTS: $e", name: 'TTS');
      }
    }
  }

  /// Get the appropriate text to read aloud for the current page
  String _getTextToReadForCurrentPage() {
    if (_contentPages.isEmpty) return ''; // No content to read

    final currentContent = _contentPages[0];
    final lessonLength = currentContent['tips']?.length ?? 0;

    String textToRead = '';

    if (_currentPage < lessonLength) {
      // We're on a tip page - format the tip content for speech
      final lesson = currentContent['tips'][_currentPage];
      textToRead =
          'Tip ${lesson['number']}. ${lesson['title']}. ${lesson['content']} ';

      // Add additional information if available
      if (lesson['additionalInformation'] != null &&
          lesson['additionalInformation'] is List) {
        for (var option in lesson['additionalInformation']) {
          textToRead += '${option['text']}. ';
          if (option['description'] != null) {
            textToRead += '${option['description']}. ';
          }
        }
      }
    } else {
      // We're on a visual parameter page - format the parameter for speech
      final paramIndex = _currentPage - lessonLength;
      if (paramIndex < currentContent['visualParameters'].length) {
        final parameter = currentContent['visualParameters'][paramIndex];
        textToRead = '${parameter['title']}. ${parameter['description']} ';
      }
    }

    return textToRead; // Return formatted text for TTS
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Set responsive size variables based on screen dimensions
    final bool isSmallScreen = screenWidth < 360; // Very narrow phone screens
    final bool isVerySmallScreen =
        screenWidth < 320; // Extremely narrow screens
    final bool isNarrowScreen = screenWidth < 400; // Standard narrow screens
    final bool isShortScreen = screenHeight < 700; // Shorter screen heights

    // Dynamic text sizing based on screen width
    final double titleSize = isVerySmallScreen
        ? 14.0
        : (isSmallScreen
            ? 16.0
            : (isNarrowScreen ? 17.0 : 18.0)); // Largest for title
    final double subtitleSize =
        isSmallScreen ? 12.0 : 14.0; // Smaller for subtitle
    final double contentSize =
        isSmallScreen ? 14.0 : 16.0; // Main content text size
    final double optionTitleSize =
        isSmallScreen ? 14.0 : 16.0; // Option heading size
    final double optionDescSize =
        isSmallScreen ? 12.0 : 14.0; // Option description size
    final double buttonTextSize =
        isSmallScreen ? 12.0 : 14.0; // Size for button labels

    // Dynamic padding and spacing
    final double dialogPadding = isSmallScreen
        ? 8.0
        : (isNarrowScreen ? 12.0 : 16.0); // Outer dialog padding
    final double contentPadding =
        isSmallScreen ? 6.0 : 8.0; // Inner content padding
    final double verticalSpacing =
        isShortScreen ? 6.0 : 10.0; // Spacing between elements

    // Dynamic image height
    final double imageHeight = isShortScreen
        ? 120.0
        : (isSmallScreen ? 150.0 : 180.0); // Adjust image size for screen

    // Define cream color for the guidebook background
    const Color creamBackground = Color.fromARGB(255, 255, 252,
        220); // Lighter cream/beige color for better app integration

    // Build the dialog
    return Dialog(
      backgroundColor: Colors.transparent, // Transparent background
      elevation: 0, // No shadow
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03, // Small margin on sides (3% of screen)
        vertical:
            screenHeight * 0.02, // Small margin on top/bottom (2% of screen)
      ),
      child: Container(
        width: screenWidth * 0.94, // Use 94% of screen width
        height: screenHeight * 0.85, // Use 85% of screen height
        padding: EdgeInsets.all(dialogPadding),
        decoration: BoxDecoration(
          color: creamBackground, // Lighter cream color
          borderRadius: BorderRadius.circular(15), // Rounded corners
          // Add a subtle border for better definition against light backgrounds
          border: Border.all(
            color: const Color(0xFF8B4513)
                .withAlpha(60), // Reduced opacity for lighter border
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Header row with title and controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5, // Give more space to title
                  child: Text(
                    _contentPages.isNotEmpty
                        ? _contentPages[0]['title'] // Display guide title
                        : 'Guide Book', // Fallback title
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines:
                        isSmallScreen ? 2 : 1, // Allow 2 lines on small screens
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text-to-speech button - toggles reading content aloud
                    IconButton(
                      icon: Icon(
                        _isSpeaking
                            ? Icons.volume_up // Shows solid icon when speaking
                            : Icons
                                .volume_up_outlined, // Shows outline when silent
                        color: _isSpeaking
                            ? const Color(0xFF8B4513)
                            : const Color(0xFF8B4513).withAlpha(
                                153), // 60% opacity (0.6 * 255 ≈ 153)
                        size:
                            isSmallScreen ? 18 : 22, // Smaller on small screens
                      ),
                      onPressed: () {
                        final text = _getTextToReadForCurrentPage();
                        if (_isSpeaking) {
                          _stopSpeaking(); // Stop if already speaking
                        } else {
                          _speak(text); // Start reading text
                        }
                      },
                      tooltip: _isSpeaking
                          ? 'Stop Reading'
                          : 'Read Aloud', // Tooltip changes with state
                      constraints: BoxConstraints(
                          minWidth: isSmallScreen ? 32 : 40,
                          minHeight: isSmallScreen
                              ? 32
                              : 40), // Minimum tap target size
                      padding: EdgeInsets.all(isSmallScreen
                          ? 4
                          : 6), // Smaller padding on small screens
                    ),
                    // Close button
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size:
                            isSmallScreen ? 18 : 22, // Smaller on small screens
                        color: const Color(
                            0xFF8B4513), // Brown color for the close icon
                      ),
                      onPressed: () {
                        _stopSpeaking(); // Stop speaking when closing
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      constraints: BoxConstraints(
                          minWidth: isSmallScreen ? 32 : 40,
                          minHeight: isSmallScreen
                              ? 32
                              : 40), // Minimum tap target size
                      padding: EdgeInsets.all(isSmallScreen
                          ? 4
                          : 6), // Smaller padding on small screens
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: verticalSpacing / 2), // Half-space after header

            // Subtitle
            if (_contentPages.isNotEmpty &&
                _contentPages[0]['subtitle'] != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: dialogPadding / 2),
                child: Text(
                  _contentPages[0]['subtitle'], // Display guide subtitle
                  style: TextStyle(
                    fontSize: subtitleSize,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3, // Allow up to 3 lines
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            SizedBox(height: verticalSpacing), // Space after subtitle

            // Main content - PageView for swiping between pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalPages,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index; // Update current page index
                    // Stop speaking when page changes
                    if (_isSpeaking) {
                      _stopSpeaking();
                    }
                  });
                },
                itemBuilder: (context, index) {
                  if (_contentPages.isEmpty) {
                    return const Center(
                        child: Text('No content available')); // Empty state
                  }

                  final currentContent = _contentPages[0];
                  final lessonLength = currentContent['tips']?.length ?? 0;

                  if (index < lessonLength) {
                    // Tips pages - show tip content, options, and images
                    final lesson = currentContent['tips'][index];
                    return _buildLessonPage(
                        lesson,
                        contentSize,
                        optionTitleSize,
                        optionDescSize,
                        contentPadding,
                        imageHeight);
                  } else {
                    // Visual parameters pages - show visual guides and explanations
                    final paramIndex = index - lessonLength;
                    if (paramIndex <
                        currentContent['visualParameters'].length) {
                      return _buildVisualizationCard(
                          currentContent['visualParameters'][paramIndex]);
                    }
                  }
                  return const Center(
                      child:
                          Text('Page not found')); // Fallback for invalid index
                },
              ),
            ),
            SizedBox(height: verticalSpacing / 2), // Space before navigation

            // Navigation controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                SizedBox(
                  height: isSmallScreen ? 30 : 36, // Smaller on small screens
                  child: ElevatedButton(
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(
                                  milliseconds: 300), // Animation duration
                              curve: Curves.easeInOut, // Smooth animation curve
                            );
                          }
                        : null, // Disable on first page
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF3E2C1C), // Brown background
                      foregroundColor: Colors.white, // White text
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen
                            ? 6
                            : 10, // Smaller padding on small screens
                        vertical: isSmallScreen ? 2 : 4,
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(
                          fontSize: buttonTextSize), // Responsive text size
                    ),
                  ),
                ),
                // Page indicator
                Text(
                  '${_currentPage + 1} / $_totalPages', // Show current page number
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: buttonTextSize,
                  ),
                ),
                // Forward button
                SizedBox(
                  height: isSmallScreen ? 30 : 36, // Smaller on small screens
                  child: ElevatedButton(
                    onPressed: _currentPage < _totalPages - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(
                                  milliseconds: 300), // Animation duration
                              curve: Curves.easeInOut, // Smooth animation curve
                            );
                          }
                        : null, // Disable on last page
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF3E2C1C), // Brown background
                      foregroundColor: Colors.white, // White text
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen
                            ? 6
                            : 10, // Smaller padding on small screens
                        vertical: isSmallScreen ? 2 : 4,
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                          fontSize: buttonTextSize), // Responsive text size
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build a lesson page with title, content, and formatted options
  Widget _buildLessonPage(
    Map<String, dynamic> lesson,
    double contentSize,
    double optionTitleSize,
    double optionDescSize,
    double contentPadding,
    double imageHeight,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tip ${lesson['number']}: ${lesson['title']}', // Changed "Lesson" to "Tip"
            style: TextStyle(
              fontSize: contentSize + 4, // Slightly larger than content text
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3E2C1C), // Brown color for headings
            ),
          ),
          SizedBox(height: contentPadding),
          Text(
            lesson['content'], // Main lesson content/description
            style: TextStyle(fontSize: contentSize),
          ),
          SizedBox(height: contentPadding * 2), // Double spacing

          // Display the image below description if available
          if (lesson['image'] != null) ...[
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(12), // Rounded corners for image
              child: AspectRatio(
                aspectRatio: 16 / 9, // Consistent aspect ratio
                child: SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    lesson['image'], // Load image from assets
                    fit: BoxFit.cover, // Fill available space
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback for missing images
                      return Container(
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: contentSize * 2,
                              color: Colors.grey,
                            ),
                            SizedBox(height: contentPadding),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: contentSize - 2),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: contentPadding * 2),
          ],

          // Add YouTube video if available
          if (lesson['videoUrl'] != null && lesson['thumbnailUrl'] != null) ...[
            InkWell(
              onTap: () {
                _launchYoutubeURL(lesson['videoUrl']); // Open video when tapped
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Video thumbnail with play button overlay
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                        child: AspectRatio(
                          aspectRatio: 16 / 9, // Standard video aspect ratio
                          child: Image.network(
                            lesson['thumbnailUrl'], // YouTube thumbnail
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                child: Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    size: contentSize * 2,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        width: 60, // Fixed size for play button
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red, // YouTube red
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: contentPadding),
                  // Video title
                  Text(
                    lesson['videoTitle'] ??
                        'Watch Video', // Title or default text
                    style: TextStyle(
                      fontSize: contentSize - 2,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E2C1C),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: contentPadding * 2),
          ],

          // Display lesson options (cards with information)
          if (lesson['additionalInformation'] != null &&
              lesson['additionalInformation']
                  is List) // Changed from 'options' to 'additionalInformation'
            ...lesson['additionalInformation'].map<Widget>((option) {
              // Changed from 'options' to 'additionalInformation'
              return Padding(
                padding: EdgeInsets.only(bottom: contentPadding),
                child: Card(
                  color: option['color'] != null
                      ? (option['color'] as Color).withAlpha(
                          25) // Very light background based on option color
                      : Colors.grey.shade100, // Default light grey
                  elevation: 1, // Slight shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    side: BorderSide(
                      color: option['color'] ??
                          Colors.grey, // Border color matches option color
                      width: 1, // Thin border
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (option['icon'] != null)
                              Icon(
                                option['icon'], // Option-specific icon
                                color: option[
                                    'color'], // Icon color matches option color
                                size: contentSize +
                                    8, // Slightly larger than text
                              ),
                            SizedBox(width: contentPadding),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['text'], // Option title/heading
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: optionTitleSize,
                                    ),
                                  ),
                                  if (option['description'] != null)
                                    Text(
                                      option[
                                          'description'], // Option description
                                      style:
                                          TextStyle(fontSize: optionDescSize),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Add the image below the text if it exists
                        if (option['imagePath'] != null) ...[
                          SizedBox(height: contentPadding),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                8), // Rounded corners for image
                            child: AspectRatio(
                              aspectRatio: 16 / 9, // Consistent aspect ratio
                              child: Image.asset(
                                option['imagePath'], // Load image from assets
                                fit: BoxFit.cover, // Fill available space
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 100,
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  /// Builds a visualization card for experimental parameters with better image handling
  Widget _buildVisualizationCard(Map<String, dynamic> parameter) {
    // Handle multiple images if the 'images' list is present
    if (parameter.containsKey('images') && parameter['images'] is List) {
      return Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: const Color(0xFF8B4513).withAlpha(60), width: 1),
        ),
        color: const Color(
            0xFFFFFCDC), // Match the cream background color of the guide book
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parameter['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Garamond',
                    color: Color(0xFF3E2C1C),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  parameter['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Garamond',
                    color: Color(0xFF3E2C1C),
                  ),
                ),
                const SizedBox(height: 20),
                // Show multiple images in a column for better visibility
                ...List.generate(
                  (parameter['images'] as List).length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF8B4513).withAlpha(60),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            minHeight: 180, // Ensure minimum height
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              parameter['images'][index],
                              fit: BoxFit
                                  .contain, // Changed to contain to prevent cropping
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Image not available",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontFamily: 'Garamond',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Show label with improved styling if available
                        if (parameter.containsKey('imageLabels') &&
                            parameter['imageLabels'] is List &&
                            index < (parameter['imageLabels'] as List).length)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3E2C1C).withAlpha(200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              parameter['imageLabels'][index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Garamond',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF3E5AB),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Single image visualization card with improved styling
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            BorderSide(color: const Color(0xFF8B4513).withAlpha(60), width: 1),
      ),
      color: const Color(0xFFFFFCDC), // Match the cream background color
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parameter['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Garamond',
                  color: Color(0xFF3E2C1C),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                parameter['description'],
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Garamond',
                  color: Color(0xFF3E2C1C),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF8B4513).withAlpha(60),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 180, // Ensure minimum height
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    parameter['image'],
                    fit: BoxFit
                        .contain, // Changed to contain to prevent cropping
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Image not available",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Garamond',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Launch a YouTube URL in external browser or YouTube app
  void _launchYoutubeURL(String url) async {
    try {
      final Uri uri = Uri.parse(url); // Parse the string URL to URI
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri,
            mode: LaunchMode.externalApplication); // Launch in external app
      } else {
        dev.log("Could not launch $url", name: 'URL Launcher'); // Log failure
      }
    } catch (e) {
      dev.log("Error launching URL: $e",
          name: 'URL Launcher'); // Log any errors
    }
  }
}
