import 'package:flutter/material.dart';

/// A class that paints minimal bounding boxes only on specific portions of the chicken
class MinimalBoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> boundingBoxes;
  final Size imageSize;
  final Size containerSize;

  MinimalBoundingBoxPainter({
    required this.boundingBoxes,
    required this.imageSize,
    required this.containerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (boundingBoxes.isEmpty) return;

    // Calculate scale factors between the image size and the container size
    final double scaleX = containerSize.width / imageSize.width;
    final double scaleY = containerSize.height / imageSize.height;

    // Select only the most critical bounding box to display
    // If there are multiple boxes, just show the first one at 1/3 the size
    if (boundingBoxes.isNotEmpty) {
      final box = boundingBoxes[0];

      // Get original rect
      final Rect originalRect = box['rect'] as Rect;

      // Create a smaller rect (1/3 the size) focused on a specific portion
      final Rect scaledRect = Rect.fromCenter(
        center: Offset(
          originalRect.center.dx * scaleX,
          originalRect.center.dy * scaleY,
        ),
        width: originalRect.width * scaleX * 0.33, // Only 1/3 the width
        height: originalRect.height * scaleY * 0.33, // Only 1/3 the height
      );      // Draw the box
      final paint = Paint()
        ..color = (box['color'] as Color).withAlpha(179) // 0.7 opacity = 179/255
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(scaledRect, paint);

      // Draw a subtle translucent fill
      final fillPaint = Paint()
        ..color = (box['color'] as Color).withAlpha(26) // 0.1 opacity = 26/255
        ..style = PaintingStyle.fill;

      canvas.drawRect(scaledRect, fillPaint);

      // Draw the label
      final textPainter = TextPainter(
        text: TextSpan(
          text: box['label'] as String,          style: TextStyle(
            color: box['color'] as Color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black.withAlpha(128),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          scaledRect.left,
          scaledRect.top - textPainter.height - 4,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// A class that renders no bounding boxes at all
class EmptyBoundingBoxPainter extends CustomPainter {
  // These parameters are kept for API compatibility
  final List<Map<String, dynamic>> boundingBoxes;
  final Size imageSize;
  final Size containerSize;

  EmptyBoundingBoxPainter({
    required this.boundingBoxes,
    required this.imageSize,
    required this.containerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Do not draw anything
    return;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
