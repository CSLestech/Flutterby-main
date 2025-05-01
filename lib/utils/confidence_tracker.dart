import 'dart:developer' as dev;

/// Debug utility class for tracking confidence scores throughout the app
/// This will help identify exactly where scores might be getting lost
class ConfidenceTracker {
  /// Log a confidence score at a specific point in the app flow
  static void logScore(String stage, dynamic score,
      [Map<String, dynamic>? context]) {
    // Format the score consistently for logging
    String formattedScore = "NULL";

    if (score != null) {
      if (score is double) {
        formattedScore = score.toStringAsFixed(4);
      } else if (score is num) {
        formattedScore = score.toDouble().toStringAsFixed(4);
      } else if (score is String) {
        formattedScore = "String: $score";
      } else {
        formattedScore = "Unknown type: ${score.runtimeType}";
      }
    }

    // Create context string if available
    String contextStr = "";
    if (context != null && context.isNotEmpty) {
      contextStr = " | Context: ${context.toString()}";
    }

    // Log with a distinctive emoji for easy filtering
    dev.log("🎯 CONFIDENCE TRACKER [$stage]: $formattedScore$contextStr",
        name: 'ConfidenceScore');
  }

  /// Format any value as a proper double confidence score
  static double normalizeScore(dynamic value) {
    if (value == null) return 0.0;

    double result = 0.0;

    if (value is double) {
      result = value;
    } else if (value is num) {
      result = value.toDouble();
    } else if (value is String) {
      result = double.tryParse(value) ?? 0.0;
    }

    // Ensure the score is within [0,1] range
    return result.clamp(0.0, 1.0);
  }
}
