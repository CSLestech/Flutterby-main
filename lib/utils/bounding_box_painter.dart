import 'package:flutter/material.dart';

/// A custom painter class to draw bounding boxes on chicken breast images
/// to highlight areas of interest with their classification labels
class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> boundingBoxes;
  final Size? imageSize;
  final Size? containerSize;

  BoundingBoxPainter({
    required this.boundingBoxes,
    this.imageSize,
    this.containerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final box in boundingBoxes) {
      final rect = box['rect'] as Rect;
      final color = box['color'] as Color;
      final label = box['label'] as String;
      final confidence = box['confidence'] as double;

      // Adjust rect if imageSize and containerSize are provided
      Rect adjustedRect = rect;
      if (imageSize != null && containerSize != null) {
        double scaleX = containerSize!.width / imageSize!.width;
        double scaleY = containerSize!.height / imageSize!.height;

        // Center the image in the container
        double xOffset =
            (containerSize!.width - (imageSize!.width * scaleX)) / 2;
        double yOffset =
            (containerSize!.height - (imageSize!.height * scaleY)) / 2;

        adjustedRect = Rect.fromLTWH(
          rect.left * scaleX + xOffset,
          rect.top * scaleY + yOffset,
          rect.width * scaleX,
          rect.height * scaleY,
        );
      }

      // Paint for the bounding box
      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw the box
      canvas.drawRect(adjustedRect, boxPaint); // Paint for the label background
      final bgPaint = Paint()
        ..color =
            color.withAlpha(178); // 0.7 opacity is approximately 178 as alpha

      // Text style for the label
      const textStyle = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      );

      // Prepare text painter for the label
      final labelSpan = TextSpan(
          text: "$label (${(confidence * 100).round()}%)", style: textStyle);
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();

      // Draw label background
      canvas.drawRect(
        Rect.fromLTWH(
          adjustedRect.left,
          adjustedRect.top - labelPainter.height - 4,
          labelPainter.width + 8,
          labelPainter.height + 4,
        ),
        bgPaint,
      );

      // Draw the label text
      labelPainter.paint(
        canvas,
        Offset(
            adjustedRect.left + 4, adjustedRect.top - labelPainter.height - 2),
      );
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) {
    return oldDelegate.boundingBoxes != boundingBoxes;
  }
}
