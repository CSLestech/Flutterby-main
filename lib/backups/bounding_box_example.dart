import 'package:flutter/material.dart';
import 'package:check_a_doodle_doo/backups/alternative_bounding_boxes.dart';

/// This example shows how to use the bounding box painters directly without a toggle
class BoundingBoxExample {
  /// Get a minimal bounding box painter that only shows on portions of the chicken
  static CustomPainter getMinimalPainter({
    required List<Map<String, dynamic>> boundingBoxes,
    required Size imageSize,
    required Size containerSize,
  }) {
    return MinimalBoundingBoxPainter(
      boundingBoxes: boundingBoxes,
      imageSize: imageSize,
      containerSize: containerSize,
    );
  }

  /// Get an empty painter that shows no bounding boxes
  static CustomPainter getEmptyPainter({
    required List<Map<String, dynamic>> boundingBoxes,
    required Size imageSize,
    required Size containerSize,
  }) {
    return EmptyBoundingBoxPainter(
      boundingBoxes: boundingBoxes,
      imageSize: imageSize,
      containerSize: containerSize,
    );
  }

  /// Example usage in a widget:
  ///
  /// ```dart
  /// // To use minimal box painter:
  /// CustomPaint(
  ///   size: Size(width, height),
  ///   painter: BoundingBoxExample.getMinimalPainter(
  ///     boundingBoxes: _boundingBoxes,
  ///     imageSize: Size(300, 280),
  ///     containerSize: Size(width, height),
  ///   ),
  /// )
  ///
  /// // To use empty painter (no boxes):
  /// CustomPaint(
  ///   size: Size(width, height),
  ///   painter: BoundingBoxExample.getEmptyPainter(
  ///     boundingBoxes: _boundingBoxes,
  ///     imageSize: Size(300, 280),
  ///     containerSize: Size(width, height),
  ///   ),
  /// )
  /// ```
}
