/* 
 * Original file backup for reference 
 * 
 * This file will be created as:
 * c:\Users\user\Downloads\SECOND_TESTER\Flutterby-main\Flutterby-main\lib\utils\bounding_box_painter.dart
 */

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

      final scaledRect = Rect.fromLTWH(
        rect.left * scaleX,
        rect.top * scaleY,
        rect.width * scaleX,
        rect.height * scaleY,
      );

      // Draw bounding box
      final paint = Paint()
        ..color = box['color']
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawRect(scaledRect, paint);

      // Draw label background
      final labelBg = Paint()..color = box['color'].withAlpha(178);

      final labelRect = Rect.fromLTWH(
        scaledRect.left,
        scaledRect.top - 20,
        80,
        20,
      );

      canvas.drawRect(labelRect, labelBg);

      // Draw label text
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

      textPainter.layout(
        minWidth: 0,
        maxWidth: 80,
      );

      textPainter.paint(
        canvas,
        Offset(labelRect.left + 5, labelRect.top + 3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
