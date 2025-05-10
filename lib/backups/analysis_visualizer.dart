/* 
 * Original file backup for reference 
 * 
 * This file will be created as:
 * c:\Users\user\Downloads\SECOND_TESTER\Flutterby-main\Flutterby-main\lib\utils\analysis_visualizer.dart
 */

import 'package:flutter/material.dart';

/// Utility class for building visualization components of chicken analysis
class AnalysisVisualizer {
  /// Returns a color based on the factor value (0.0-1.0)
  static Color getColorFromFactor(double factor) {
    if (factor > 0.85) return Colors.green;
    if (factor > 0.7) return Colors.lightGreen;
    if (factor > 0.5) return Colors.orange;
    return Colors.red;
  }

  /// Builds a horizontal factor bar with label and percentage
  static Widget buildFactorBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2C1C),
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2C1C),
          ),
        ),
      ],
    );
  }

  /// Builds a class probability bar with label and percentage
  static Widget buildClassBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(value * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Returns a text description for a factor based on quality level
  static String getFactorDescription(String factor, String quality) {
    switch (factor) {
      case 'Color':
        if (quality == 'Consumable') {
          return 'The chicken breast shows healthy pink coloration consistent with fresh poultry. No discoloration or darkening was detected.';
        } else if (quality == 'Consumable with Caution') {
          return 'The chicken breast shows some minor discoloration in certain areas. While not severe, this indicates the beginning of quality degradation.';
        } else {
          return 'The chicken breast shows significant discoloration, with gray/green areas that indicate bacterial growth or spoilage.';
        }

      case 'Texture':
        if (quality == 'Consumable') {
          return 'The texture appears firm and consistent, with normal muscle fiber structure. No sliminess or unusual patterns detected.';
        } else if (quality == 'Consumable with Caution') {
          return 'The texture shows some changes in consistency, with slight softening in certain areas. This suggests early stage quality degradation.';
        } else {
          return 'The texture shows significant changes including excessive softening, sliminess, or tacky surface characteristics indicative of spoilage.';
        }

      case 'Moisture':
        if (quality == 'Consumable') {
          return 'Appropriate moisture level detected, with no excess liquid or dryness. This is consistent with properly stored fresh chicken.';
        } else if (quality == 'Consumable with Caution') {
          return 'Some areas show changes in moisture level, either with excess liquid or slight drying. This indicates storage time affecting quality.';
        } else {
          return 'Significant moisture issues detected, either excessive dampness suggesting bacterial activity or severe drying indicating improper storage.';
        }

      case 'Shape':
        if (quality == 'Consumable') {
          return 'Normal size and shape characteristics with typical muscle structure. No abnormal shapes or structural issues detected.';
        } else if (quality == 'Consumable with Caution') {
          return 'Minor changes to the typical shape characteristics, with some deformation of the normal muscle structure.';
        } else {
          return 'Severe changes to the normal structure including significant deformation, unusual bulges or indentations.';
        }

      default:
        return 'Analysis information not available.';
    }
  }

  /// Gets a recommendation based on quality classification
  static Map<String, dynamic> getRecommendation(String quality) {
    switch (quality) {
      case 'Consumable':
        return {
          'title': 'Recommendation: Safe to Consume',
          'text':
              'This chicken breast appears fresh and suitable for all cooking methods. Always ensure chicken reaches an internal temperature of 165°F (74°C) when cooking.',
          'color': Colors.green.shade800,
          'bgColor': Colors.green.shade100,
        };
      case 'Consumable with Caution':
        return {
          'title': 'Recommendation: Cook Thoroughly',
          'text':
              'This chicken breast is at the transition stage. Cook thoroughly to an internal temperature of 165°F (74°C) and consume immediately. Avoid raw preparations.',
          'color': Colors.orange.shade800,
          'bgColor': Colors.orange.shade100,
        };
      default:
        return {
          'title': 'Recommendation: Discard',
          'text':
              'This chicken breast shows significant signs of spoilage and should be discarded. Consuming this may pose health risks.',
          'color': Colors.red.shade800,
          'bgColor': Colors.red.shade100,
        };
    }
  }
}
