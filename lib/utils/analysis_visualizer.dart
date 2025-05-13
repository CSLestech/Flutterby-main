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

  /// Returns a text description for a factor based on quality level and image variation
  static String getFactorDescription(String factorName, String predictionType) {
    // Use the image path or timestamp to create variation in descriptions
    final int variation =
        DateTime.now().millisecondsSinceEpoch % 3; // 0, 1, or 2

    // Return different descriptions based on the factor, prediction type, and variation
    if (factorName == "Color") {
      if (predictionType == "Consumable") {
        if (variation == 0) {
          return "The chicken breast shows normal coloration throughout most areas with minimal discoloration that is within acceptable limits for fresh poultry.";
        } else if (variation == 1) {
          return "The color profile of this chicken sample appears within normal parameters. Visual assessment shows good uniformity with only minor variations typical of fresh chicken.";
        } else {
          return "Visual examination indicates proper coloration consistent with fresh chicken. The minor color variations observed fall within expected ranges for high-quality poultry.";
        }
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        if (variation == 0) {
          return "The chicken breast appears to have some minor discoloration in certain areas. This visual characteristic often suggests the beginning of quality changes, similar to patterns described in food safety guidelines.";
        } else if (variation == 1) {
          return "Moderate color changes are visible in specific regions of this sample. These visual indicators suggest early-stage quality transitions that warrant attention.";
        } else {
          return "The coloration shows slight deviations from optimal freshness. The visual assessment reveals some areas with color changes that typically appear during the early stages of quality decline.";
        }
      } else {
        if (variation == 0) {
          return "The visual analysis suggests concerning color variations throughout the chicken breast. These visual patterns are similar to those associated with quality deterioration in poultry.";
        } else if (variation == 1) {
          return "Significant color abnormalities are visible across the surface of this sample. The visual patterns observed align with characteristics of chicken that has undergone substantial quality changes.";
        } else {
          return "The color profile displays marked variations inconsistent with fresh chicken. Visual assessment identifies widespread discoloration patterns typically associated with quality concerns.";
        }
      }
    } else if (factorName == "Texture") {
      if (predictionType == "Consumable") {
        if (variation == 0) {
          return "Based on visual assessment, the texture appears consistent with fresh chicken breast. The surface appears smooth and firm in the image.";
        } else if (variation == 1) {
          return "The visual texture characteristics suggest good fiber integrity and proper moisture retention. The surface appearance is consistent with high-quality fresh chicken.";
        } else {
          return "Surface examination indicates a texture profile that aligns with properly stored fresh chicken. Visual cues suggest appropriate firmness and tissue cohesion.";
        }
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        if (variation == 0) {
          return "The visual appearance suggests possible changes in texture consistency in some areas. These visual cues might indicate early stage quality changes.";
        } else if (variation == 1) {
          return "Some areas of the sample show visual indicators of textural variations. These characteristics often appear during the transitional phase of poultry quality changes.";
        } else {
          return "The surface appearance displays subtle textural inconsistencies in specific regions. Visual assessment identifies minor changes typical of chicken in the early stages of quality transition.";
        }
      } else {
        if (variation == 0) {
          return "The visual characteristics of the surface suggest potential texture issues. The appearance differs from what would typically be expected in fresh chicken.";
        } else if (variation == 1) {
          return "Visual examination reveals significant texture abnormalities across the sample. The surface appearance shows characteristics inconsistent with recommended quality standards.";
        } else {
          return "The texture profile visible in the image indicates substantial changes in the muscle fiber integrity. These visual patterns align with advanced quality concerns in poultry.";
        }
      }
    } else if (factorName == "Moisture") {
      if (predictionType == "Consumable") {
        if (variation == 0) {
          return "The visual appearance suggests normal moisture characteristics, consistent with properly stored fresh chicken based on visual assessment.";
        } else if (variation == 1) {
          return "Based on visual cues, the sample appears to have appropriate moisture distribution. The surface reflectivity and tissue appearance align with properly maintained chicken.";
        } else {
          return "Visual examination indicates suitable moisture characteristics. The surface appearance suggests proper hydration levels typical of fresh, quality poultry.";
        }
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        if (variation == 0) {
          return "The appearance suggests potential moisture-related changes. Visual indicators might point to changes that occur during extended refrigerated storage.";
        } else if (variation == 1) {
          return "Some visual cues indicate possible moisture distribution changes. The surface characteristics suggest moderate alterations that may affect overall quality.";
        } else {
          return "Visual assessment notes moderate variations in the apparent moisture characteristics. These visual patterns often emerge during the transitional phase of chicken quality changes.";
        }
      } else {
        if (variation == 0) {
          return "The visual assessment notes surface appearance that may suggest moisture-related issues. The visual characteristics are consistent with patterns seen in prolonged storage or improper handling.";
        } else if (variation == 1) {
          return "Visual examination indicates significant moisture-related concerns. The surface appearance shows characteristics typically associated with substantial quality deterioration.";
        } else {
          return "The visible surface characteristics suggest problematic moisture conditions. These visual patterns are frequently observed in chicken that has undergone significant quality changes.";
        }
      }
    } else if (factorName == "Shape") {
      if (predictionType == "Consumable") {
        if (variation == 0) {
          return "The overall shape and appearance of the chicken breast seems normal based on visual assessment. No obvious deformations are visible in the image.";
        } else if (variation == 1) {
          return "Visual examination indicates proper structural integrity throughout the sample. The form and contours appear consistent with high-quality fresh chicken.";
        } else {
          return "The morphological characteristics visible in the image align with normal, fresh chicken parameters. No concerning structural abnormalities are apparent.";
        }
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        if (variation == 0) {
          return "Some visual cues suggest minor changes in the structural appearance, though the overall shape remains within expected parameters based on the image.";
        } else if (variation == 1) {
          return "Visual assessment reveals subtle structural inconsistencies in limited areas. The majority of the sample maintains appropriate form, with only minor deviations.";
        } else {
          return "The image shows moderate shape variations in specific regions. These visual characteristics often indicate early-stage structural changes that merit attention.";
        }
      } else {
        if (variation == 0) {
          return "The visual assessment indicates potential structural issues. The appearance shows characteristics that differ from typical fresh chicken visual patterns.";
        } else if (variation == 1) {
          return "Significant structural abnormalities are visible in the sample. The visual patterns suggest substantial changes in muscle fiber integrity and overall form.";
        } else {
          return "The visible morphological characteristics indicate concerning structural alterations. The form and tissue integrity appear markedly different from recommended quality standards.";
        }
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
        "bgColor": Colors.green
            .withAlpha(26), // 0.1 opacity is approximately 26 as alpha
      };
    } else if (predictionType == "Consumable with Caution" ||
        predictionType == "Half-consumable") {
      return {
        "title": "Exercise Caution",
        "text":
            "This chicken is showing early signs of quality degradation. If used, ensure thorough cooking to at least 165°F (74°C) and consume immediately.",
        "color": Colors.orange,
        "bgColor": Colors.orange
            .withAlpha(26), // 0.1 opacity is approximately 26 as alpha
      };
    } else {
      return {
        "title": "Not Recommended for Consumption",
        "text":
            "This chicken shows significant signs of spoilage. Consuming it may pose health risks, even with thorough cooking.",
        "color": Colors.red,
        "bgColor": Colors.red
            .withAlpha(26), // 0.1 opacity is approximately 26 as alpha
      };
    }
  }
}
