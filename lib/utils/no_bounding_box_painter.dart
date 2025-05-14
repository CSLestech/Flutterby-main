import 'package:flutter/material.dart';

/// A custom painter class that accepts the same parameters as BoundingBoxPainter
/// but doesn't draw any bounding boxes - used to toggle visibility of boxes
class NoBoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> boundingBoxes;
  final Size? imageSize;
  final Size? containerSize;

  NoBoundingBoxPainter({
    required this.boundingBoxes,
    this.imageSize,
    this.containerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Intentionally left empty - doesn't draw anything
  }

  @override
  bool shouldRepaint(NoBoundingBoxPainter oldDelegate) {
    return oldDelegate.boundingBoxes != boundingBoxes;
  }
}
