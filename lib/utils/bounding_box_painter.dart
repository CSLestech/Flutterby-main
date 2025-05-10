import 'package:flutter/material.dart';

/// A custom painter class to draw bounding boxes on chicken breast images
/// to highlight areas of interest with their classification labels
class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> boundingBoxes;

  BoundingBoxPainter({required this.boundingBoxes});
  @override
  void paint(Canvas canvas, Size size) {
    for (final box in boundingBoxes) {
      final rect = box['rect'] as Rect;

      // Calculate scaled rect based on canvas size
      final scaleX = size.width / 300; // Assuming the original width is 300
      final scaleY = size.height / 300; // Assuming the original height is 300

      // Make sure bounding boxes stay within image bounds
      final left = (rect.left * scaleX).clamp(0.0, size.width - 10);
      final top = (rect.top * scaleY)
          .clamp(25.0, size.height - 10); // Ensure room for label above
      final width =
          ((rect.width * scaleX) + left).clamp(20.0, size.width) - left;
      final height =
          ((rect.height * scaleY) + top).clamp(20.0, size.height - top) - top;

      final scaledRect = Rect.fromLTWH(
        left,
        top,
        width,
        height,
      );

      // Draw bounding box
      final paint = Paint()
        ..color = box['color']
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRect(scaledRect,
          paint); // Prepare for text measurement first to determine background size
      final textSpan = TextSpan(
        text: box['label'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      // Measure the text to determine background width
      textPainter.layout(minWidth: 0, maxWidth: size.width * 0.5);

      // Add padding for the text
      final labelWidth = textPainter.width + 10; // 5px padding on each side
      final labelHeight = 20.0; // fixed height for label

      // Draw label background with proper width
      final labelBg = Paint()..color = box['color'].withAlpha(220);

      // Check if label would go off-screen to the right
      double labelLeft = scaledRect.left;
      if (labelLeft + labelWidth > size.width) {
        labelLeft = size.width - labelWidth;
      }

      // Create label rectangle with appropriate width
      final labelRect = Rect.fromLTWH(
        labelLeft,
        scaledRect.top - labelHeight,
        labelWidth,
        labelHeight,
      );

      canvas.drawRect(labelRect, labelBg);

      // Now draw the text on top of the background
      textPainter.paint(
        canvas,
        Offset(labelRect.left + 5,
            labelRect.top + (labelHeight - textPainter.height) / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
