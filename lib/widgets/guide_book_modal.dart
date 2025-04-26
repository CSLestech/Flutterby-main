import 'package:flutter/material.dart';
import 'guide_book_button.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as dev;
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class GuideBookModal extends StatefulWidget {
  const GuideBookModal({super.key});

  @override
  State<GuideBookModal> createState() => _GuideBookModalState();
}

class _GuideBookModalState extends State<GuideBookModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _totalPages = 0;
  List<Map<String, dynamic>> _contentPages = [];

  // Text to speech variables
  FlutterTts? _flutterTts;
  bool _isSpeaking = false;
  String? _currentlyReadingText;
  bool _ttsInitialized = false;
  final double _volume = 1.0;
  final double _pitch = 1.0;
  final double _rate = 0.5;
  final String _selectedLanguage = "en-US";

  @override
  void initState() {
    super.initState();
    _contentPages = GuideBookContent.getContentPages();
    _totalPages = _contentPages.isNotEmpty
        ? _contentPages[0]['visualParameters'].length +
            _contentPages[0]['lessons'].length
        : 0;

    // Initialize TTS engine
    _initTts();
  }

  // Initialize the text to speech engine with better error handling
  Future<void> _initTts() async {
    dev.log("Initializing TTS...", name: 'TTS');

    try {
      _flutterTts = FlutterTts();

      // Set up TTS configuration
      await _flutterTts!.setLanguage(_selectedLanguage);
      await _flutterTts!.setSpeechRate(_rate);
      await _flutterTts!.setVolume(_volume);
      await _flutterTts!.setPitch(_pitch);

      // Set handlers for TTS events
      _flutterTts!.setStartHandler(() {
        dev.log("TTS Started", name: 'TTS');
        setState(() {
          _isSpeaking = true;
        });
      });

      _flutterTts!.setCompletionHandler(() {
        dev.log("TTS Completed", name: 'TTS');
        setState(() {
          _isSpeaking = false;
          _currentlyReadingText = null;
        });
      });

      _flutterTts!.setErrorHandler((error) {
        dev.log("TTS Error: $error", name: 'TTS');
        setState(() {
          _isSpeaking = false;
          _currentlyReadingText = null;
        });
      });

      // Mark TTS as initialized
      setState(() {
        _ttsInitialized = true;
      });

      dev.log("TTS initialized successfully", name: 'TTS');
    } catch (e) {
      dev.log("TTS Initialization Error: $e", name: 'TTS');
      setState(() {
        _ttsInitialized = false;
      });
      _showTtsErrorDialog('$e');
    }
  }

  // Speak the given text with improved error handling
  Future<void> _speak(String text) async {
    if (!_ttsInitialized || _flutterTts == null) {
      dev.log("TTS not initialized, attempting to initialize now", name: 'TTS');
      await _initTts();
      if (!_ttsInitialized) {
        dev.log("Failed to initialize TTS", name: 'TTS');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Text-to-speech not available"),
            duration: Duration(seconds: 2),
          ));
        }
        return;
      }
    }

    if (_isSpeaking) {
      await _stopSpeaking();
      // If we were already reading the same text, just stop
      if (_currentlyReadingText == text) {
        setState(() {
          _currentlyReadingText = null;
        });
        return;
      }
    }

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
        _isSpeaking = true;
        _currentlyReadingText = text;
      });

      // First check for any pending speech and stop it
      await _flutterTts!.stop();

      // Break text into chunks if it's too long (helps with stability)
      if (text.length > 4000) {
        // Logic for breaking text into reasonable chunks
        final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
        var currentChunk = "";

        for (var sentence in sentences) {
          if ((currentChunk + sentence).length < 3900) {
            currentChunk += "$sentence ";
          } else {
            // Speak the current chunk and wait for completion
            await _flutterTts!.speak(currentChunk);
            await Future.delayed(const Duration(milliseconds: 500));
            currentChunk = "$sentence ";
          }
        }

        // Speak the final chunk if any text remains
        if (currentChunk.isNotEmpty) {
          await _flutterTts!.speak(currentChunk);
        }
      } else {
        // For shorter text, just speak it directly
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

  // Show error dialog
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

  // Stop speaking with improved error handling
  Future<void> _stopSpeaking() async {
    try {
      if (_flutterTts != null && _isSpeaking) {
        await _flutterTts!.stop();
        setState(() {
          _isSpeaking = false;
        });
      }
    } catch (e) {
      dev.log("Error stopping TTS: $e", name: 'TTS');
    }
  }

  // Clean up resources
  @override
  void dispose() {
    _pageController.dispose();
    _stopTts();
    super.dispose();
  }

  Future<void> _stopTts() async {
    if (_flutterTts != null) {
      try {
        await _flutterTts!.stop();
        await _flutterTts!.awaitSpeakCompletion(false);
      } catch (e) {
        dev.log("Error disposing TTS: $e", name: 'TTS');
      }
    }
  }

  // Helper method to get text to read for current page
  String _getTextToReadForCurrentPage() {
    if (_contentPages.isEmpty) return '';

    final currentContent = _contentPages[0];
    final lessonLength = currentContent['lessons'].length;

    String textToRead = '';

    if (_currentPage < lessonLength) {
      // We're on a lesson page
      final lesson = currentContent['lessons'][_currentPage];
      textToRead =
          'Lesson ${lesson['number']}. ${lesson['title']}. ${lesson['content']} ';

      // Add options if available
      if (lesson['options'] != null && lesson['options'] is List) {
        for (var option in lesson['options']) {
          textToRead += '${option['text']}. ';
          if (option['description'] != null) {
            textToRead += '${option['description']}. ';
          }
        }
      }
    } else {
      // We're on a visual parameter page
      final paramIndex = _currentPage - lessonLength;
      if (paramIndex < currentContent['visualParameters'].length) {
        final parameter = currentContent['visualParameters'][paramIndex];
        textToRead = '${parameter['title']}. ${parameter['description']} ';
      }
    }

    return textToRead;
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Set sizes based on screen dimensions
    final bool isSmallScreen = screenWidth < 360;
    final bool isVerySmallScreen = screenWidth < 320;
    final bool isNarrowScreen = screenWidth < 400;
    final bool isShortScreen = screenHeight < 700;

    // Dynamic text sizing based on screen width
    final double titleSize = isVerySmallScreen
        ? 14.0
        : (isSmallScreen ? 16.0 : (isNarrowScreen ? 17.0 : 18.0));
    final double subtitleSize = isSmallScreen ? 12.0 : 14.0;
    final double contentSize = isSmallScreen ? 14.0 : 16.0;
    final double optionTitleSize = isSmallScreen ? 14.0 : 16.0;
    final double optionDescSize = isSmallScreen ? 12.0 : 14.0;
    final double buttonTextSize = isSmallScreen ? 12.0 : 14.0;

    // Dynamic padding and spacing
    final double dialogPadding =
        isSmallScreen ? 8.0 : (isNarrowScreen ? 12.0 : 16.0);
    final double contentPadding = isSmallScreen ? 6.0 : 8.0;
    final double verticalSpacing = isShortScreen ? 6.0 : 10.0;

    // Dynamic image height
    final double imageHeight =
        isShortScreen ? 120.0 : (isSmallScreen ? 150.0 : 180.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03, // 3% of screen width
        vertical: screenHeight * 0.02, // 2% of screen height
      ),
      child: Container(
        width: screenWidth * 0.94, // 94% of screen width
        height: screenHeight * 0.85, // 85% of screen height
        padding: EdgeInsets.all(dialogPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            // Header with responsive spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5, // Give more space to the title
                  child: Text(
                    _contentPages.isNotEmpty
                        ? _contentPages[0]['title']
                        : 'Guide Book',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: isSmallScreen
                        ? 2
                        : 1, // Allow two lines on small screens
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text-to-speech button
                    IconButton(
                      icon: Icon(
                        _isSpeaking
                            ? Icons.volume_up
                            : Icons.volume_up_outlined,
                        color: _isSpeaking ? Colors.blue : Colors.grey,
                        size: isSmallScreen ? 18 : 22,
                      ),
                      onPressed: () {
                        final text = _getTextToReadForCurrentPage();
                        if (_isSpeaking) {
                          _stopSpeaking();
                        } else {
                          _speak(text);
                        }
                      },
                      tooltip: _isSpeaking ? 'Stop Reading' : 'Read Aloud',
                      constraints: BoxConstraints(
                          minWidth: isSmallScreen ? 32 : 40,
                          minHeight: isSmallScreen ? 32 : 40),
                      padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                    ),
                    // Close button
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: isSmallScreen ? 18 : 22,
                      ),
                      onPressed: () {
                        _stopSpeaking(); // Stop speaking when closing
                        Navigator.of(context).pop();
                      },
                      constraints: BoxConstraints(
                          minWidth: isSmallScreen ? 32 : 40,
                          minHeight: isSmallScreen ? 32 : 40),
                      padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: verticalSpacing / 2),
            // Subtitle
            if (_contentPages.isNotEmpty &&
                _contentPages[0]['subtitle'] != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: dialogPadding / 2),
                child: Text(
                  _contentPages[0]['subtitle'],
                  style: TextStyle(
                    fontSize: subtitleSize,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3, // Allow more lines for subtitle
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            SizedBox(height: verticalSpacing),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalPages,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    // Stop speaking when page changes
                    if (_isSpeaking) {
                      _stopSpeaking();
                    }
                  });
                },
                itemBuilder: (context, index) {
                  if (_contentPages.isEmpty) {
                    return const Center(child: Text('No content available'));
                  }

                  final currentContent = _contentPages[0];
                  final lessonLength = currentContent['lessons'].length;

                  if (index < lessonLength) {
                    // Lessons pages
                    final lesson = currentContent['lessons'][index];
                    return _buildLessonPage(
                        lesson,
                        contentSize,
                        optionTitleSize,
                        optionDescSize,
                        contentPadding,
                        imageHeight);
                  } else {
                    // Visual parameters pages
                    final paramIndex = index - lessonLength;
                    if (paramIndex <
                        currentContent['visualParameters'].length) {
                      return _buildVisualParameterPage(
                          currentContent['visualParameters'][paramIndex],
                          contentSize,
                          imageHeight);
                    }
                  }
                  return const Center(child: Text('Page not found'));
                },
              ),
            ),
            SizedBox(height: verticalSpacing / 2),
            // Navigation controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                SizedBox(
                  height: isSmallScreen ? 30 : 36,
                  child: ElevatedButton(
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E2C1C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 6 : 10,
                        vertical: isSmallScreen ? 2 : 4,
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(fontSize: buttonTextSize),
                    ),
                  ),
                ),
                // Page indicator
                Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: buttonTextSize,
                  ),
                ),
                // Forward button
                SizedBox(
                  height: isSmallScreen ? 30 : 36,
                  child: ElevatedButton(
                    onPressed: _currentPage < _totalPages - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E2C1C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 6 : 10,
                        vertical: isSmallScreen ? 2 : 4,
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(fontSize: buttonTextSize),
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
            'Lesson ${lesson['number']}: ${lesson['title']}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2C1C),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lesson['content'],
            style: TextStyle(fontSize: contentSize),
          ),
          const SizedBox(height: 20),

          // Add YouTube video if available
          if (lesson['videoUrl'] != null && lesson['thumbnailUrl'] != null) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                // Launch the URL
                _launchYoutubeURL(lesson['videoUrl']);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Video thumbnail with play button overlay
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          lesson['thumbnailUrl'],
                          width: double.infinity,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: imageHeight,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red,
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
                  const SizedBox(height: 8),
                  // Video title
                  Text(
                    lesson['videoTitle'] ?? 'Watch Video',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2C1C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (lesson['options'] != null && lesson['options'] is List)
            ...lesson['options'].map<Widget>((option) {
              return Padding(
                padding: EdgeInsets.only(bottom: contentPadding),
                child: Card(
                  color: option['color'] != null
                      ? (option['color'] as Color).withAlpha(25)
                      : Colors.grey.shade100,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: option['color'] ?? Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (option['icon'] != null)
                          Icon(
                            option['icon'],
                            color: option['color'],
                            size: 24,
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option['text'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: optionTitleSize,
                                ),
                              ),
                              if (option['description'] != null)
                                Text(
                                  option['description'],
                                  style: TextStyle(fontSize: optionDescSize),
                                ),
                            ],
                          ),
                        ),
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

  Widget _buildVisualParameterPage(
    Map<String, dynamic> parameter,
    double contentSize,
    double imageHeight,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parameter['title'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2C1C),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            parameter['description'],
            style: TextStyle(fontSize: contentSize),
          ),
          if (parameter['image'] != null) ...[
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                parameter['image'],
                height: imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox(
                    height: imageHeight,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _launchYoutubeURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        dev.log("Could not launch $url", name: 'URL Launcher');
      }
    } catch (e) {
      dev.log("Error launching URL: $e", name: 'URL Launcher');
    }
  }
}
