import 'package:flutter/material.dart';

class GuideBookModal extends StatefulWidget {
  const GuideBookModal({super.key});

  @override
  State<GuideBookModal> createState() => _GuideBookModalState();
}

class _GuideBookModalState extends State<GuideBookModal> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _lessons = [
    {
      'title': 'How to Determine If the Prediction Is Right',
      'subtitle':
          'Follow a step-by-step guide to gauge the reliability of the prediction output.',
      'lessonNumber': 1,
      'lessonTitle': 'Is It Consumable or Not?',
      'lessonContent':
          'One key question to ask when assessing the visual parameters.',
      'options': [
        {
          'text': 'Consumable',
          'icon': Icons.check_circle,
          'color': Colors.green
        },
        {'text': 'Not Consumable', 'icon': Icons.cancel, 'color': Colors.red},
      ],
      'image': 'images/guide/visual_parameters.png',
    },
    {
      'title': 'Visual Parameters',
      'subtitle': 'Understanding key visual indicators',
      'lessonNumber': 2,
      'lessonTitle': 'Color Assessment',
      'lessonContent': 'Check for natural coloration and normal patterns.',
      'image': 'images/guide/color_assessment.png',
    },
    {
      'title': 'Texture Analysis',
      'subtitle': 'How to evaluate surface characteristics',
      'lessonNumber': 3,
      'lessonTitle': 'Surface Variations',
      'lessonContent':
          'Identifying concerning patterns versus normal variations.',
      'image': 'images/guide/texture_analysis.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5E6), // Parchment color
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77), // alpha 0-255 (0.3 * 255 ≈ 77)
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF8B7355), // Brown border
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Book content
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF8B7355).withAlpha(77),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _lessons.length,
                itemBuilder: (context, index) {
                  return _buildLessonPage(_lessons[index]);
                },
              ),
            ),

            // Close button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF3E2C1C)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),

            // Page indicator
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${_currentPage + 1} / ${_lessons.length}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Garamond',
                      color: Color(0xFF3E2C1C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Previous button
            if (_currentPage > 0)
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF3E2C1C),
                      size: 36,
                    ),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),

            // Next button
            if (_currentPage < _lessons.length - 1)
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF3E2C1C),
                      size: 36,
                    ),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonPage(Map<String, dynamic> lesson) {
    return Row(
      children: [
        // Left page
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Garamond',
                    color: Color(0xFF3E2C1C),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  lesson['subtitle'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontFamily: 'Garamond',
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                // Visual example with image
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Visual Parameters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Garamond',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Image.asset(
                            lesson['image'] ?? 'images/placeholder.png',
                            width: 140,
                            height: 100,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right page
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color(0xFF8B7355),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lesson header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3E2C1C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Lesson ${lesson['lessonNumber']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  lesson['lessonTitle'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2C1C),
                    fontFamily: 'Garamond',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lesson['lessonContent'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontFamily: 'Garamond',
                  ),
                ),
                const SizedBox(height: 24),
                // Display options if they exist
                if (lesson.containsKey('options') && lesson['options'] is List)
                  ...List<Widget>.from(
                    (lesson['options'] as List).map((option) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Icon(
                                option['icon'] ?? Icons.circle,
                                color: option['color'] ?? Colors.black,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                option['text'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: option['color'] ?? Colors.black,
                                  fontFamily: 'Garamond',
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
