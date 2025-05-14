import 'package:flutter/material.dart';
import 'package:check_a_doodle_doo/backups/alternative_bounding_boxes.dart';

/// A class that returns different bounding box painters based on a predetermined condition.
/// This allows you to seamlessly switch between different bounding box styles without UI toggles.
class StealthBoundingBoxManager {
  // Singleton pattern to ensure consistent state
  static final StealthBoundingBoxManager _instance =
      StealthBoundingBoxManager._internal();
  factory StealthBoundingBoxManager() => _instance;
  StealthBoundingBoxManager._internal();

  // Possible modes:
  // "normal" - standard bounding boxes from BoundingBoxToggler
  // "minimal" - small, focused bounding boxes on portions only
  // "none" - no bounding boxes at all
  String _currentMode = "normal";

  // Change mode based on code
  void setMode(String mode) {
    if (["normal", "minimal", "none"].contains(mode)) {
      _currentMode = mode;
    }
  }

  // Get the appropriate painter based on the current mode
  CustomPainter getPainter({
    required List<Map<String, dynamic>> boundingBoxes,
    required Size imageSize,
    required Size containerSize,
  }) {
    switch (_currentMode) {
      case "minimal":
        return MinimalBoundingBoxPainter(
          boundingBoxes: boundingBoxes,
          imageSize: imageSize,
          containerSize: containerSize,
        );
      case "none":
        return EmptyBoundingBoxPainter(
          boundingBoxes: boundingBoxes,
          imageSize: imageSize,
          containerSize: containerSize,
        );
      case "normal":
      default:
        // This would be your normal BoundingBoxPainter from the toggler
        // You can replace with direct call if needed
        return MinimalBoundingBoxPainter(
          boundingBoxes: boundingBoxes,
          imageSize: imageSize,
          containerSize: containerSize,
        );
    }
  }
}
