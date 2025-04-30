import 'package:flutter/material.dart'; // Import Flutter material package for UI elements
import 'guide_book_modal.dart'; // Import the modal dialog implementation

/// GuideBookContent class stores all educational content for the app's guide
/// This includes lessons, categories, descriptions and visual parameters
class GuideBookContent {
  /// Returns a list of content pages for the guide book
  /// Each page contains lessons, visual parameters, and other educational content
  static List<Map<String, dynamic>> getContentPages() {
    return [
      {
        'title':
            'Understanding Chicken Quality Classifications', // Main title for this guide section
        'subtitle':
            'Learn how to identify the three categories of chicken breast quality', // Explanatory subtitle
        'lessons': [
          {
            'number': 1, // Lesson number for ordering
            'title':
                'Classification System Overview', // Title of this specific lesson
            'content':
                'Our app classifies chicken breast into three categories based on freshness and safety for consumption:', // Main descriptive content
            'options': [
              // List of classification options with their attributes
              {
                'text': 'Consumable', // Name of classification category
                'color': Colors
                    .green, // Visual color indicator for this category (green = safe)
                'icon': Icons.check_circle, // Icon representing this category
                'description':
                    'chicken that is safe to eat with normal cooking methods', // Detailed explanation
                'imagePath':
                    'images/consumable204.jpg', // Example image of consumable chicken
              },
              {
                'text': 'Half-Consumable', // Second classification category
                'color': Colors.orange, // Orange for caution indicator
                'icon': Icons.warning, // Warning icon for caution
                'description':
                    'Chicken showing early signs of deterioration but can still be safely eaten if thoroughly cooked', // Detailed explanation
                'imagePath':
                    'images/halfconsumable195.jpg', // Example image of half-consumable chicken
              },
              {
                'text': 'Not Consumable', // Third classification category
                'color': Colors.red, // Red for danger/warning
                'icon': Icons.cancel, // Cancel icon indicating unsafe
                'description':
                    'Spoiled chicken that should not be consumed under any circumstances', // Safety warning
                'imagePath':
                    'images/notconsumable408.jpg', // Example image of spoiled chicken
              },
            ],
          },
          {
            'number': 2, // Second lesson
            'title':
                'Consumable Chicken Characteristics', // Focus on consumable chicken traits
            'content':
                'Chicken classified as "Consumable" typically shows these qualities:', // Introduction to characteristics
            'options': [
              // List of characteristics for consumable chicken
              {
                'text': 'Color: Pink to light pink', // Color characteristic
                'color': Colors.green, // Green indicator for good quality
                'icon': Icons.check_circle, // Check icon for positive trait
                'description':
                    'Even coloration throughout with no discoloration' // Detailed description
              },
              {
                'text': 'Texture: Firm and springy', // Texture characteristic
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description':
                    'Meat springs back when touched, not slimy' // Description of good texture
              },
              {
                'text': 'Smell: Mild or neutral odor', // Smell characteristic
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description':
                    'No strong or sour smell' // Description of acceptable smell
              },
              {
                'text':
                    'Surface: Slight moisture is normal', // Surface characteristic
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description':
                    'Should not be excessively wet or dry' // Normal moisture level
              },
            ],
          },
          {
            'number': 3, // Third lesson
            'title':
                'Half-Consumable Chicken Characteristics', // Focus on half-consumable chicken
            'content':
                'Chicken classified as "Half-Consumable" shows early signs of quality decline:', // Introduction
            'options': [
              // List of characteristics for half-consumable chicken
              {
                'text':
                    'Color: Slightly darker pink or light gray spots', // Color indicators
                'color': Colors.orange, // Orange for caution
                'icon': Icons.warning,
                'description':
                    'May show small areas of discoloration' // Description of early discoloration
              },
              {
                'text': 'Texture: Slightly less firm', // Texture indicators
                'color': Colors.orange,
                'icon': Icons.warning,
                'description':
                    'May feel slightly tacky but not slimy' // Description of texture changes
              },
              {
                'text': 'Smell: Slightly stronger odor', // Smell indicators
                'color': Colors.orange,
                'icon': Icons.warning,
                'description':
                    'Noticeable but not strongly offensive' // Description of smell changes
              },
              {
                'text':
                    'Safety: Must be cooked thoroughly', // Safety requirement
                'color': Colors.orange,
                'icon': Icons.warning,
                'description':
                    'Internal temperature must reach at least 75°C/165°F' // Cooking safety guideline
              },
            ],
          },
          {
            'number': 4, // Fourth lesson
            'title':
                'Not Consumable Chicken Characteristics', // Focus on unsafe chicken
            'content':
                'Chicken classified as "Not Consumable" shows clear signs of spoilage:', // Introduction
            'options': [
              // List of characteristics for unsafe chicken
              {
                'text':
                    'Color: Gray, green, or purple discoloration', // Dangerous color changes
                'color': Colors.red, // Red for danger
                'icon': Icons.cancel,
                'description':
                    'Obvious discoloration indicates bacterial growth' // Explanation of discoloration
              },
              {
                'text': 'Texture: Slimy or sticky surface', // Dangerous texture
                'color': Colors.red,
                'icon': Icons.cancel,
                'description':
                    'Sliminess indicates bacterial contamination' // Explanation of texture issues
              },
              {
                'text':
                    'Smell: Sour, ammonia-like, or sulfur odor', // Bad smell indicators
                'color': Colors.red,
                'icon': Icons.cancel,
                'description':
                    'Strong offensive smell indicates spoilage' // Smell significance
              },
              {
                'text': 'Appearance: Mold growth', // Visible spoilage
                'color': Colors.red,
                'icon': Icons.cancel,
                'description':
                    'Any visible mold means the chicken should be discarded' // Safety guideline
              },
            ],
          },
          {
            'number': 5, // Fifth lesson
            'title':
                'Shelf Life & Storage Duration', // Focus on storage durations
            'content':
                'The shelf life of chicken breast depends on storage conditions and initial quality:', // Introduction
            'options': [
              // List of storage timeframes for chicken
              {
                'text':
                    'Fresh Refrigerated: 1-2 days', // Refrigerated fresh chicken
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description':
                    'When properly stored at or below 4°C (40°F)' // Storage condition
              },
              {
                'text': 'Frozen: Up to 9 months', // Frozen chicken duration
                'color': Colors.blue, // Blue for frozen
                'icon': Icons.ac_unit, // Snowflake icon for frozen
                'description':
                    'When properly wrapped and stored at -18°C (0°F)' // Freezing condition
              },
              {
                'text': 'Cooked: 3-4 days', // Cooked chicken duration
                'color': Colors.teal,
                'icon': Icons.restaurant, // Restaurant/food icon
                'description':
                    'When refrigerated promptly after cooking' // Storage condition
              },
              {
                'text':
                    'Room Temperature: 2 hours maximum', // Danger zone warning
                'color': Colors.red,
                'icon': Icons.warning,
                'description':
                    'Never leave raw chicken out longer than 2 hours (1 hour if above 32°C/90°F)' // Safety guideline
              },
            ],
          },
          {
            'number':
                5, // Another fifth lesson (duplicate number, likely an oversight)
            'title': 'Shelf Life & Storage Duration',
            'content':
                'Our study monitored chicken breast deterioration over a 3-day period at refrigeration temperature:', // Study methodology explanation
            'options': [
              // Study results over time
              {
                'text': 'Day 1: Fresh Chicken', // Day 1 observations
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description':
                    'Typically classified as Consumable with optimal quality' // Day 1 classification
              },
              {
                'text': 'Day 2: Beginning Deterioration', // Day 2 observations
                'color': Colors.orange,
                'icon': Icons.warning,
                'description':
                    'Often transitions to Half-Consumable as quality begins to decline' // Day 2 classification
              },
              {
                'text': 'Day 3: Significant Changes', // Day 3 observations
                'color': Colors.red,
                'icon': Icons.warning,
                'description':
                    'May show signs of being Not Consumable, especially if stored improperly' // Day 3 warning
              },
              {
                'text': 'Note: Results Vary', // Important caveat
                'color': Colors.blue,
                'icon': Icons.info,
                'description':
                    'Storage conditions, initial freshness, and handling all affect spoilage rate' // Variables affecting results
              },
            ],
            'videoUrl':
                'https://youtu.be/_ohJqkeNrb4?si=ippWUVa6RWj_Ot6z', // Link to educational video
            'thumbnailUrl':
                'https://i.ytimg.com/vi/_ohJqkeNrb4/maxresdefault.jpg', // Video thumbnail
            'videoTitle': 'Chicken Timelapse', // Title of the video
          },
          {
            'number': 6, // Sixth lesson
            'title': 'Chicken Breed and Quality', // Focus on chicken breeds
            'content':
                'This app was specifically calibrated for Broiler Hybrid (Magnolia) chicken, but quality assessment is similar across breeds:', // Introduction
            'options': [
              // Information about chicken breeds
              {
                'text': 'Broiler Hybrid (Magnolia)', // Primary breed used
                'color': Colors.deepPurple,
                'icon': Icons.verified,
                'description':
                    'The chicken breed used for calibrating this application' // Calibration info
              },
              {
                'text': 'Breed Variations', // Variations between breeds
                'color': Colors.indigo,
                'icon': Icons.compare,
                'description':
                    'Fat color may vary slightly between breeds; some naturally have more yellow fat' // Breed differences
              },
              {
                'text': 'Growth Conditions', // Environmental factors
                'color': Colors.blue,
                'icon': Icons.eco,
                'description':
                    'Diet and raising conditions can affect chicken meat color and texture' // External factors
              },
            ],
          },
          {
            'number': 7, // Seventh lesson
            'title':
                'Commercial Grading Standards', // Focus on industry standards
            'content':
                'Industry standards for chicken quality classification use letter grades:', // Introduction
            'options': [
              // Commercial quality classifications
              {
                'text': 'Class A (Yellow)', // Highest commercial grade
                'color': Colors.amber,
                'icon': Icons.star,
                'description':
                    'Premium quality with excellent color, conformation, and no defects' // Description of A grade
              },
              {
                'text': 'Class B (Orange)', // Medium commercial grade
                'color': Colors.orange,
                'icon': Icons.star_half,
                'description':
                    'Good quality with minor defects in appearance or minor discolorations' // Description of B grade
              },
              {
                'text': 'Class C (Green)', // Lowest commercial grade
                'color': Colors.green,
                'icon': Icons.star_outline,
                'description':
                    'Acceptable with some defects but still suitable for certain uses' // Description of C grade
              },
            ],
          },
        ],
        'visualParameters': [
          // Additional visual information sections
          {
            'title': 'Color Assessment', // Focus on color assessment
            'description':
                'The color of chicken breast is one of the most important indicators of freshness. Fresh chicken should have a light pink to deep pink color with white fat. Gray, green, or purple discoloration indicates spoilage. Yellow fat is normal in some chicken breeds.', // Detailed guidelines
            'image': 'images/ui/guide', // Reference to guide image
          },
          {
            'title': 'Texture Evaluation', // Focus on texture assessment
            'description':
                'Fresh chicken has a firm texture that springs back when touched. It should not feel slimy, sticky, or excessively soft. When pressed with a finger, the indentation should disappear quickly. Slimy texture indicates bacterial growth and spoilage.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Odor Detection', // Focus on smell assessment
            'description':
                'Fresh chicken has minimal odor. Any strong, sour, ammonia-like, or sulfur smell indicates spoilage. Always smell chicken before cooking, even if it looks normal, as some bacteria don\'t cause visible changes but produce detectable odors.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Storage Guidelines', // Focus on storage best practices
            'description':
                'Raw chicken should be stored at or below 4°C (40°F). Fresh chicken can be refrigerated for 1-2 days. If you won\'t use it within that time, freeze it. Frozen chicken maintains quality for up to 9 months. Always thaw chicken in the refrigerator, not at room temperature.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Safe Cooking', // Focus on cooking safety
            'description':
                'Always cook chicken to an internal temperature of at least 75°C (165°F) measured with a food thermometer. This temperature kills harmful bacteria like Salmonella and Campylobacter. When cooking Half-Consumable chicken, ensure thorough cooking and check that juices run clear.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Breed Considerations', // Focus on breed differences
            'description':
                'This application is calibrated for Broiler Hybrid (Magnolia) chicken breast. While the general principles apply to all chicken types, there may be slight variations in color and texture between breeds. Broiler chickens typically have lighter meat compared to free-range or heritage breeds.',
            'image': 'images/ui/guide',
          },
          {
            'title':
                'Time & Temperature Factors', // Focus on timeframe and temperature
            'description':
                'Our experimental data is based on a 3-day observation period of refrigerated chicken breast. The app\'s machine learning model was trained on images collected daily over this period, capturing the progressive changes in appearance as the chicken deteriorated from fresh to spoiled state. Temperature was maintained at 4°C (39°F) throughout the experiment.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Experimental Design', // Focus on study methodology
            'description':
                'The 3-day experiment used Broiler Hybrid (Magnolia) chicken breast stored in standard refrigeration. Images were captured under controlled lighting conditions at 24-hour intervals. The model analyzes visual characteristics that correlate with microbiological testing results to determine which classification category the chicken belongs in.',
            'image': 'images/ui/guide',
          },
        ],
      },
      // You can add more guide pages here
    ];
  }
}

/// GuideBookButton creates a button in the app bar to access the guide content
/// When pressed, it shows the guide book modal with educational information
class GuideBookButton extends StatelessWidget {
  const GuideBookButton({super.key}); // Default constructor

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.menu_book_rounded, // Book icon representing guide/manual
        color: Color(
            0xFFF3E5AB), // Match the color with other app bar icons - warm cream color
      ),
      tooltip: 'Prediction Guide', // Tooltip shown on long press or hover
      onPressed: () {
        // Show the guide book modal dialog when the button is pressed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const GuideBookModal(); // Display the guide book modal dialog
          },
        );
      },
    );
  }
}
