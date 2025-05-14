import 'package:flutter/material.dart';
import 'package:check_a_doodle_doo/utils/bounding_box_painter.dart';
import 'package:check_a_doodle_doo/utils/no_bounding_box_painter.dart';

/// A utility class to toggle between bounding box display modes
class BoundingBoxToggler {
  // Singleton pattern
  static final BoundingBoxToggler _instance = BoundingBoxToggler._internal();
  factory BoundingBoxToggler() => _instance;
  BoundingBoxToggler._internal();

  // State variables
  bool _showBoundingBoxes = true;

  // Getter for current state
  bool get showBoundingBoxes => _showBoundingBoxes;

  // Toggle function
  void toggle() {
    _showBoundingBoxes = !_showBoundingBoxes;
  }

  // Get the appropriate painter based on current state
  CustomPainter getPainter({
    required List<Map<String, dynamic>> boundingBoxes,
    Size? imageSize,
    Size? containerSize,
  }) {
    if (_showBoundingBoxes) {
      return BoundingBoxPainter(
        boundingBoxes: boundingBoxes,
        imageSize: imageSize,
        containerSize: containerSize,
      );
    } else {
      return NoBoundingBoxPainter(
        boundingBoxes: boundingBoxes,
        imageSize: imageSize,
        containerSize: containerSize,
      );
    }
  }
}
