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
          return "The color looks good, with a healthy pinkish-white appearance typical of fresh chicken. Any small color variations are normal.";
        } else {
          return "The chicken has a nice, even color that looks fresh and healthy. Only minor natural variations in shade are visible.";
        }
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        if (variation == 0) {
          return "The chicken breast appears to have some minor discoloration in certain areas. This visual change often suggests the beginning of quality changes.";
        } else if (variation == 1) {
          return "Some areas show slight color changes that might mean the chicken is starting to lose freshness. These changes are still within acceptable ranges.";
        } else {
          return "The color is slightly off in certain spots, which typically happens when chicken has been stored for a while but is still usable.";
        }
      } else {
        if (variation == 0) {
          return "The visual analysis suggests concerning color variations throughout the chicken breast. These patterns typically indicate quality issues.";
        } else if (variation == 1) {
          return "The chicken shows obvious discoloration that usually means it's no longer fresh. These color changes suggest it should not be eaten.";
        } else {
          return "There are noticeable color problems across the chicken surface that indicate it's past its prime for safe consumption.";
        }
      }
    } else if (factorName == "Texture") {
      if (predictionType == "Consumable") {
        if (variation == 0) {
          return "Based on visual assessment, the texture appears consistent with fresh chicken breast. The surface looks smooth and firm in the image.";
        } else if (variation == 1) {
          return "The chicken looks to have a nice, smooth surface with the firmness you'd expect from fresh poultry.";
        } else {
          return "The surface appearance suggests good texture quality, looking smooth and evenly formed like properly fresh chicken should.";
        }
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        if (variation == 0) {
          return "The visual appearance suggests possible changes in texture consistency in some areas. These visual cues might indicate early stage quality changes.";
        } else if (variation == 1) {
          return "Some parts of the chicken look slightly different in texture, which often happens when chicken is still okay but not at peak freshness.";
        } else {
          return "The surface doesn't look perfectly even throughout - some areas appear to be changing texture, which can happen as chicken begins to age.";
        }
      } else {
        if (variation == 0) {
          return "The visual characteristics of the surface suggest texture issues. The appearance differs from what you'd expect in fresh chicken.";
        } else if (variation == 1) {
          return "The chicken surface looks problematic, with an uneven texture that suggests it's no longer fresh enough for consumption.";
        } else {
          return "The texture appears abnormal with visible changes that indicate the chicken is likely past its usable state.";
        }
      }
    } else if (factorName == "Moisture") {
      if (predictionType == "Consumable") {
        if (variation == 0) {
          return "The visual appearance suggests normal moisture characteristics, consistent with properly stored fresh chicken based on visual assessment.";
        } else if (variation == 1) {
          return "The chicken looks to have a healthy level of moisture - not too dry and not too wet, as fresh chicken should appear.";
        } else {
          return "From what we can see, the chicken has a good balance of moisture, appearing neither dried out nor excessively wet.";
        }
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        if (variation == 0) {
          return "The appearance suggests potential moisture-related changes. Visual indicators might point to changes that occur during extended storage.";
        } else if (variation == 1) {
          return "The chicken shows some signs that its moisture level isn't ideal - either slightly too dry or a bit too moist on the surface.";
        } else {
          return "There are visual hints that the moisture balance is starting to change, which typically happens when chicken has been stored for some time.";
        }
      } else {
        if (variation == 0) {
          return "The visual assessment notes surface appearance that may suggest moisture-related issues, similar to patterns seen in improperly stored chicken.";
        } else if (variation == 1) {
          return "The chicken appears to have problematic moisture levels - either too dry and tough or showing excess liquid that shouldn't be there.";
        } else {
          return "The visible moisture characteristics don't look right for safe chicken - showing signs typical of chicken that shouldn't be consumed.";
        }
      }
    } else if (factorName == "Shape") {
      if (predictionType == "Consumable") {
        if (variation == 0) {
          return "The overall shape and appearance of the chicken breast seems normal based on visual assessment. No obvious issues are visible in the image.";
        } else if (variation == 1) {
          return "The chicken has a natural, well-formed shape that looks as fresh chicken should, with no concerning irregularities.";
        } else {
          return "The chicken piece maintains its proper form and structure, looking like a quality cut of fresh poultry.";
        }
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        if (variation == 0) {
          return "Some visual cues suggest minor changes in the structural appearance, though the overall shape remains within expected parameters based on the image.";
        } else if (variation == 1) {
          return "The chicken's shape shows slight irregularities in some areas, which can happen as chicken begins to age but is still usable.";
        } else {
          return "There are some minor changes to the chicken's form, though it still mostly maintains its proper structure.";
        }
      } else {
        if (variation == 0) {
          return "The visual assessment indicates potential structural issues. The appearance shows characteristics that differ from typical fresh chicken.";
        } else if (variation == 1) {
          return "The chicken's shape looks noticeably altered from what fresh chicken should look like, suggesting it's past its prime.";
        } else {
          return "The chicken has lost its proper form in ways that suggest it shouldn't be used, showing signs of breakdown that indicate spoilage.";
        }
      }
    } else if (factorName == "Surface Pattern") {
      if (predictionType == "Consumable") {
        if (variation == 0) {
          return "The chicken shows a uniform surface pattern that's consistent across the entire piece, which is typical of fresh, quality poultry.";
        } else if (variation == 1) {
          return "The surface pattern appears even and consistent throughout, displaying the natural grain and texture expected in fresh chicken.";
        } else {
          return "Visual assessment shows a well-distributed, regular pattern across the surface, indicating good quality chicken.";
        }
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        if (variation == 0) {
          return "Some minor inconsistencies are visible in the surface pattern, though most areas still maintain normal appearance.";
        } else if (variation == 1) {
          return "The chicken shows slight variations in its surface pattern in certain areas, which can occur as freshness begins to decline.";
        } else {
          return "While mostly consistent, there are some areas where the surface pattern shows early signs of change from the ideal uniform appearance.";
        }
      } else {
        if (variation == 0) {
          return "The surface pattern shows significant irregularities and disruptions that indicate the chicken has undergone notable quality changes.";
        } else if (variation == 1) {
          return "Visual examination reveals an uneven, inconsistent surface pattern that differs markedly from what fresh chicken should display.";
        } else {
          return "The chicken's surface pattern appears highly irregular with noticeable disruptions, suggesting it's no longer suitable for consumption.";
        }
      }
    } else if (factorName == "Edge Integrity") {
      if (predictionType == "Consumable") {
        if (variation == 0) {
          return "The edges of the chicken piece appear well-defined and firm, maintaining clear boundaries that indicate proper freshness.";
        } else if (variation == 1) {
          return "Visual assessment shows good edge definition throughout the chicken, with the clean, distinct borders expected in quality poultry.";
        } else {
          return "The chicken maintains proper edge clarity and definition, showing the firm boundaries characteristic of fresh meat.";
        }
      } else if (predictionType == "Consumable with Caution" ||
          predictionType == "Half-consumable") {
        if (variation == 0) {
          return "Some edges appear slightly less defined than others, showing early signs of softening that can occur as chicken begins to age.";
        } else if (variation == 1) {
          return "The chicken shows minor edge softening in certain areas, though most boundaries remain relatively well-defined.";
        } else {
          return "Visual examination indicates some reduction in edge clarity, with slight blurring of boundaries in specific regions.";
        }
      } else {
        if (variation == 0) {
          return "The chicken's edges appear poorly defined with significant boundary deterioration, suggesting advanced quality decline.";
        } else if (variation == 1) {
          return "Visual assessment shows concerning loss of edge definition, with borders that appear too soft and poorly maintained.";
        } else {
          return "The edges lack proper definition and clarity, displaying the boundary breakdown typically seen in chicken that shouldn't be consumed.";
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
