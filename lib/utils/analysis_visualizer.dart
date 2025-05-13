import 'package:flutter/material.dart';

/// Utility class for building visualization components of chicken analysis
class AnalysisVisualizer {
  /// Returns a color based on the factor value (0.0-1.0)
  static Color getColorFromFactor(double factor) {
    if (factor >= 0.8) {
      return Colors.green;
    } else if (factor >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
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
  static String getFactorDescription(String factorName, String predictionType) {
    // Return different descriptions based on the factor and prediction type
    if (factorName == "Color") {
      if (predictionType == "Consumable") {
        return "The chicken breast shows normal coloration throughout most areas with minimal discoloration that is within acceptable limits for fresh poultry.";
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        return "The chicken breast shows some minor discoloration in certain areas. While not severe, this indicates the beginning of quality degradation. This aligns with FSIS guidelines on color changes in poultry at the transitional stage.";
      } else {
        return "Significant discoloration detected throughout the chicken breast. The color variations indicate possible spoilage and exceed acceptable thresholds according to food safety guidelines.";
      }
    } else if (factorName == "Texture") {
      if (predictionType == "Consumable") {
        return "The texture appears firm and smooth, consistent with fresh chicken breast. No sliminess or concerning textural issues detected.";
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        return "The texture shows some changes in consistency, with slight softening in certain areas. This suggests early stage quality degradation, consistent with scientific observations of protein breakdown in aging poultry.";
      } else {
        return "Abnormal texture detected with significant changes from fresh chicken. The surface shows signs of deterioration and possible bacterial growth that affects the structural integrity.";
      }
    } else if (factorName == "Moisture") {
      if (predictionType == "Consumable") {
        return "The moisture level appears normal, consistent with properly stored fresh chicken. No excessive dryness or wetness detected.";
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        return "Some areas show changes in moisture level, either with excess liquid or slight drying. This indicates storage time affecting quality, consistent with documented studies on moisture changes during refrigerated storage of poultry.";
      } else {
        return "Concerning moisture abnormalities detected. Either excessive surface moisture indicating bacterial activity or extreme dryness suggesting improper storage. Both conditions exceed safety thresholds.";
      }
    } else if (factorName == "Shape") {
      if (predictionType == "Consumable") {
        return "The shape and structural integrity of the chicken breast appear normal. No concerning deformations or structural breakdown detected.";
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        return "Minor changes in the structural integrity observed, though the overall shape remains acceptable. Some fiber breakdown may be beginning in isolated areas.";
      } else {
        return "Significant structural deterioration observed. The muscle fibers show breakdown and the overall shape integrity is compromised beyond acceptable limits for consumption.";
      }
    }

    // Default description if factor is not recognized
    return "Analysis not available for this factor.";
  }

  /// Gets a recommendation based on quality classification
  static Map<String, dynamic> getRecommendation(String predictionType) {
    if (predictionType == "Consumable") {
      return {
        "title": "Safe to Consume",
        "text":
            "This chicken breast appears fresh and safe to eat. Ensure proper cooking to at least 165°F (74°C) internal temperature for best safety.",
        "color": Colors.green,
        "bgColor": Colors.green.withOpacity(0.1),
      };
    } else if (predictionType == "Consumable with Caution" ||
        predictionType == "Half-consumable") {
      return {
        "title": "Exercise Caution",
        "text":
            "This chicken is showing early signs of quality degradation. If used, ensure thorough cooking to at least 165°F (74°C) and consume immediately.",
        "color": Colors.orange,
        "bgColor": Colors.orange.withOpacity(0.1),
      };
    } else {
      return {
        "title": "Not Recommended for Consumption",
        "text":
            "This chicken shows significant signs of spoilage. Consuming it may pose health risks, even with thorough cooking.",
        "color": Colors.red,
        "bgColor": Colors.red.withOpacity(0.1),
      };
    }
  }
}
