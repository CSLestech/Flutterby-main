import 'package:flutter/material.dart';
import 'guide_book_button.dart';

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

  @override
  void initState() {
    super.initState();
    _contentPages = GuideBookContent.getContentPages();
    _totalPages = _contentPages.isNotEmpty
        ? _contentPages[0]['visualParameters'].length +
            _contentPages[0]['lessons'].length
        : 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_contentPages.isEmpty) return const SizedBox.shrink();

    final currentContent = _contentPages[0];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F1E8), // Warm cream background
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF3E2C1C),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(
                  77), // Fixed: using withAlpha instead of withOpacity
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Space for balance
                  Expanded(
                    child: Center(
                      child: Text(
                        currentContent['title'] ?? 'Guide Book',
                        style: const TextStyle(
                          fontFamily: 'Garamond',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2C1C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF3E2C1C),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                currentContent['subtitle'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Garamond',
                  fontSize: 14,
                  color: Color(0xFF3E2C1C),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Main content with PageView
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFD9D0C1), width: 1),
                    right: BorderSide(color: Color(0xFFD9D0C1), width: 1),
                  ),
                ),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    // Lessons pages
                    ...List.generate(
                      currentContent['lessons'].length,
                      (index) =>
                          _buildLessonPage(currentContent['lessons'][index]),
                    ),

                    // Visual Parameters pages
                    ...List.generate(
                      currentContent['visualParameters'].length,
                      (index) => _buildVisualParameterPage(
                          currentContent['visualParameters'][index]),
                    ),
                  ],
                ),
              ),
            ),

            // Page indicator and navigation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFD9D0C1), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page counter
                  Text(
                    "${_currentPage + 1} / $_totalPages",
                    style: const TextStyle(
                      fontFamily: 'Garamond',
                      fontSize: 14,
                      color: Color(0xFF3E2C1C),
                    ),
                  ),

                  // Navigation buttons
                  Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            size: 18, color: Color(0xFF3E2C1C)),
                        onPressed: _currentPage > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        color: _currentPage > 0
                            ? const Color(0xFF3E2C1C)
                            : Colors.grey,
                      ),
                      // Forward button
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            size: 18, color: Color(0xFF3E2C1C)),
                        onPressed: _currentPage < _totalPages - 1
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        color: _currentPage < _totalPages - 1
                            ? const Color(0xFF3E2C1C)
                            : Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonPage(Map<String, dynamic> lesson) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2C1C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Lesson ${lesson['number']}",
                style: const TextStyle(
                  fontFamily: 'Garamond',
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Lesson title
            Text(
              lesson['title'] ?? '',
              style: const TextStyle(
                fontFamily: 'Garamond',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2C1C),
              ),
            ),

            const SizedBox(height: 12),

            // Lesson content
            Text(
              lesson['content'] ?? '',
              style: const TextStyle(
                fontFamily: 'Garamond',
                fontSize: 16,
                color: Color(0xFF3E2C1C),
              ),
            ),

            const SizedBox(height: 24),

            // Options
            ...(lesson['options'] as List<dynamic>? ?? []).map((option) {
              final Color optionColor = option['color'] ?? Colors.grey;
              final IconData optionIcon = option['icon'] ?? Icons.circle;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      optionIcon,
                      color: optionColor,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['text'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Garamond',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3E2C1C),
                            ),
                          ),
                          if (option['description'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                option['description'],
                                style: const TextStyle(
                                  fontFamily: 'Garamond',
                                  fontSize: 14,
                                  color: Color(0xFF3E2C1C),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualParameterPage(Map<String, dynamic> parameter) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual parameter title
            const Text(
              "Visual Parameters",
              style: TextStyle(
                fontFamily: 'Garamond',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2C1C),
              ),
            ),

            const SizedBox(height: 16),

            // Parameter title
            Text(
              parameter['title'] ?? '',
              style: const TextStyle(
                fontFamily: 'Garamond',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2C1C),
              ),
            ),

            const SizedBox(height: 12),

            // Parameter description
            Text(
              parameter['description'] ?? '',
              style: const TextStyle(
                fontFamily: 'Garamond',
                fontSize: 16,
                color: Color(0xFF3E2C1C),
              ),
            ),

            const SizedBox(height: 24),

            // Parameter image - no longer in Expanded widget to work with SingleChildScrollView
            Container(
              height: 250, // Fixed height for image
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E0D5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: parameter['image'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        parameter['image'],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image,
                              size: 64,
                              color: Color(0xFFBFB5A1),
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Color(0xFFBFB5A1),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
