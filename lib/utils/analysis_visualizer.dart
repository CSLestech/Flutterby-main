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
  static String getFactorDescription(String factor, String predictionClass) {
    // Return tailored descriptions based on the factor and prediction class
    if (factor == 'Color') {
      if (predictionClass == 'Consumable') {
        return "The chicken breast shows typical pale pink coloration with minimal discoloration, indicating freshness. This assessment is based on established USDA visual inspection guidelines for fresh poultry.";
      } else if (predictionClass == 'Consumable with Caution' ||
          predictionClass == 'Half-consumable') {
        return "The chicken breast shows some minor discoloration in certain areas. While not severe, this indicates the beginning of quality degradation. This aligns with FSIS guidelines on color changes in poultry at the transitional stage.";
      } else {
        return "The chicken breast shows significant discoloration (grayish or greenish tints), indicating bacterial growth and spoilage. This matches documented spoilage patterns in scientific literature on poultry deterioration.";
      }
    } else if (factor == 'Texture') {
      if (predictionClass == 'Consumable') {
        return "The texture appears firm and springy with good elasticity - typical of fresh poultry muscle tissue. This assessment follows standard food safety inspection criteria for meat texture evaluation.";
      } else if (predictionClass == 'Consumable with Caution' ||
          predictionClass == 'Half-consumable') {
        return "The texture shows some changes in consistency, with slight softening in certain areas. This suggests early stage quality degradation, consistent with scientific observations of protein breakdown in aging poultry.";
      } else {
        return "The texture shows significant sliminess or stickiness, indicating advanced bacterial action and protein breakdown. This matches documented characteristics of spoiled poultry in food safety literature.";
      }
    } else if (factor == 'Moisture') {
      if (predictionClass == 'Consumable') {
        return "The chicken breast shows appropriate moisture levels, neither excessively dry nor wet. This assessment follows standard moisture content guidelines for fresh poultry established by food regulatory bodies.";
      } else if (predictionClass == 'Consumable with Caution' ||
          predictionClass == 'Half-consumable') {
        return "Some areas show changes in moisture level, either with excess liquid or slight drying. This indicates storage time affecting quality, consistent with documented studies on moisture changes during refrigerated storage of poultry.";
      } else {
        return "Significant abnormal moisture content detected - either excess surface wetness indicating purge or excessive dryness. This matches documented indicators of spoilage in food safety inspection protocols.";
      }
    } else if (factor == 'Shape') {
      if (predictionClass == 'Consumable') {
        return "The chicken breast maintains its typical anatomical shape and structure, with muscle fibers intact. This is consistent with quality indicators for fresh poultry as outlined in food industry quality assessment standards.";
      } else if (predictionClass == 'Consumable with Caution' ||
          predictionClass == 'Half-consumable') {
        return "Minor changes to the typical shape characteristics, with some deformation of the normal muscle structure. This reflects early protein breakdown documented in food science literature on poultry aging.";
      } else {
        return "Significant loss of structural integrity and abnormal shape characteristics, indicating advanced degradation. This is consistent with documented physical changes in spoiled poultry tissue.";
      }
    }
    return "Analysis information not available for this factor.";
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
