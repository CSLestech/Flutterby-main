import 'package:flutter/material.dart';
import 'guide_book_modal.dart';

class GuideBookContent {
  static List<Map<String, dynamic>> getContentPages() {
    return [
      {
        'title': 'Understanding Chicken Quality Classifications',
        'subtitle':
            'Learn how to identify the three categories of chicken breast quality',
        'lessons': [
          {
            'number': 1,
            'title': 'Classification System Overview',
            'content':
                'Our app classifies chicken breast into three categories based on freshness and safety for consumption:',
            'options': [
              {
                'text': 'Consumable',
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description':
                    'chicken that is safe to eat with normal cooking methods'
              },
              {
                'text': 'Half-Consumable',
                'color': Colors.orange,
                'icon': Icons.warning,
                'description':
                    'Chicken showing early signs of deterioration but can still be safely eaten if thoroughly cooked'
              },
              {
                'text': 'Not Consumable',
                'color': Colors.red,
                'icon': Icons.cancel,
                'description':
                    'Spoiled chicken that should not be consumed under any circumstances'
              },
            ],
          },
          {
            'number': 2,
            'title': 'Consumable Chicken Characteristics',
            'content':
                'Chicken classified as "Consumable" typically shows these qualities:',
            'options': [
              {
                'text': 'Color: Pink to light pink',
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description':
                    'Even coloration throughout with no discoloration'
              },
              {
                'text': 'Texture: Firm and springy',
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description': 'Meat springs back when touched, not slimy'
              },
              {
                'text': 'Smell: Mild or neutral odor',
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description': 'No strong or sour smell'
              },
              {
                'text': 'Surface: Slight moisture is normal',
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description': 'Should not be excessively wet or dry'
              },
            ],
          },
          {
            'number': 3,
            'title': 'Half-Consumable Chicken Characteristics',
            'content':
                'Chicken classified as "Half-Consumable" shows early signs of quality decline:',
            'options': [
              {
                'text': 'Color: Slightly darker pink or light gray spots',
                'color': Colors.orange,
                'icon': Icons.warning,
                'description': 'May show small areas of discoloration'
              },
              {
                'text': 'Texture: Slightly less firm',
                'color': Colors.orange,
                'icon': Icons.warning,
                'description': 'May feel slightly tacky but not slimy'
              },
              {
                'text': 'Smell: Slightly stronger odor',
                'color': Colors.orange,
                'icon': Icons.warning,
                'description': 'Noticeable but not strongly offensive'
              },
              {
                'text': 'Safety: Must be cooked thoroughly',
                'color': Colors.orange,
                'icon': Icons.warning,
                'description':
                    'Internal temperature must reach at least 75°C/165°F'
              },
            ],
          },
          {
            'number': 4,
            'title': 'Not Consumable Chicken Characteristics',
            'content':
                'Chicken classified as "Not Consumable" shows clear signs of spoilage:',
            'options': [
              {
                'text': 'Color: Gray, green, or purple discoloration',
                'color': Colors.red,
                'icon': Icons.cancel,
                'description':
                    'Obvious discoloration indicates bacterial growth'
              },
              {
                'text': 'Texture: Slimy or sticky surface',
                'color': Colors.red,
                'icon': Icons.cancel,
                'description': 'Sliminess indicates bacterial contamination'
              },
              {
                'text': 'Smell: Sour, ammonia-like, or sulfur odor',
                'color': Colors.red,
                'icon': Icons.cancel,
                'description': 'Strong offensive smell indicates spoilage'
              },
              {
                'text': 'Appearance: Mold growth',
                'color': Colors.red,
                'icon': Icons.cancel,
                'description':
                    'Any visible mold means the chicken should be discarded'
              },
            ],
          },
          {
            'number': 5,
            'title': 'Shelf Life & Storage Duration',
            'content':
                'The shelf life of chicken breast depends on storage conditions and initial quality:',
            'options': [
              {
                'text': 'Fresh Refrigerated: 1-2 days',
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description': 'When properly stored at or below 4°C (40°F)'
              },
              {
                'text': 'Frozen: Up to 9 months',
                'color': Colors.blue,
                'icon': Icons.ac_unit,
                'description': 'When properly wrapped and stored at -18°C (0°F)'
              },
              {
                'text': 'Cooked: 3-4 days',
                'color': Colors.teal,
                'icon': Icons.restaurant,
                'description': 'When refrigerated promptly after cooking'
              },
              {
                'text': 'Room Temperature: 2 hours maximum',
                'color': Colors.red,
                'icon': Icons.warning,
                'description':
                    'Never leave raw chicken out longer than 2 hours (1 hour if above 32°C/90°F)'
              },
            ],
          },
          {
            'number': 5,
            'title': 'Shelf Life & Storage Duration',
            'content':
                'Our study monitored chicken breast deterioration over a 3-day period at refrigeration temperature:',
            'options': [
              {
                'text': 'Day 1: Fresh Chicken',
                'color': Colors.green,
                'icon': Icons.check_circle,
                'description':
                    'Typically classified as Consumable with optimal quality'
              },
              {
                'text': 'Day 2: Beginning Deterioration',
                'color': Colors.orange,
                'icon': Icons.warning,
                'description':
                    'Often transitions to Half-Consumable as quality begins to decline'
              },
              {
                'text': 'Day 3: Significant Changes',
                'color': Colors.red,
                'icon': Icons.warning,
                'description':
                    'May show signs of being Not Consumable, especially if stored improperly'
              },
              {
                'text': 'Note: Results Vary',
                'color': Colors.blue,
                'icon': Icons.info,
                'description':
                    'Storage conditions, initial freshness, and handling all affect spoilage rate'
              },
            ],
          },
          {
            'number': 6,
            'title': 'Chicken Breed and Quality',
            'content':
                'This app was specifically calibrated for Broiler Hybrid (Magnolia) chicken, but quality assessment is similar across breeds:',
            'options': [
              {
                'text': 'Broiler Hybrid (Magnolia)',
                'color': Colors.deepPurple,
                'icon': Icons.verified,
                'description':
                    'The chicken breed used for calibrating this application'
              },
              {
                'text': 'Breed Variations',
                'color': Colors.indigo,
                'icon': Icons.compare,
                'description':
                    'Fat color may vary slightly between breeds; some naturally have more yellow fat'
              },
              {
                'text': 'Growth Conditions',
                'color': Colors.blue,
                'icon': Icons.eco,
                'description':
                    'Diet and raising conditions can affect chicken meat color and texture'
              },
            ],
          },
          {
            'number': 7,
            'title': 'Commercial Grading Standards',
            'content':
                'Industry standards for chicken quality classification use letter grades:',
            'options': [
              {
                'text': 'Class A (Yellow)',
                'color': Colors.amber,
                'icon': Icons.star,
                'description':
                    'Premium quality with excellent color, conformation, and no defects'
              },
              {
                'text': 'Class B (Orange)',
                'color': Colors.orange,
                'icon': Icons.star_half,
                'description':
                    'Good quality with minor defects in appearance or minor discolorations'
              },
              {
                'text': 'Class C (Green)',
                'color': Colors.green,
                'icon': Icons.star_outline,
                'description':
                    'Acceptable with some defects but still suitable for certain uses'
              },
            ],
          },
        ],
        'visualParameters': [
          {
            'title': 'Color Assessment',
            'description':
                'The color of chicken breast is one of the most important indicators of freshness. Fresh chicken should have a light pink to deep pink color with white fat. Gray, green, or purple discoloration indicates spoilage. Yellow fat is normal in some chicken breeds.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Texture Evaluation',
            'description':
                'Fresh chicken has a firm texture that springs back when touched. It should not feel slimy, sticky, or excessively soft. When pressed with a finger, the indentation should disappear quickly. Slimy texture indicates bacterial growth and spoilage.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Odor Detection',
            'description':
                'Fresh chicken has minimal odor. Any strong, sour, ammonia-like, or sulfur smell indicates spoilage. Always smell chicken before cooking, even if it looks normal, as some bacteria don\'t cause visible changes but produce detectable odors.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Storage Guidelines',
            'description':
                'Raw chicken should be stored at or below 4°C (40°F). Fresh chicken can be refrigerated for 1-2 days. If you won\'t use it within that time, freeze it. Frozen chicken maintains quality for up to 9 months. Always thaw chicken in the refrigerator, not at room temperature.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Safe Cooking',
            'description':
                'Always cook chicken to an internal temperature of at least 75°C (165°F) measured with a food thermometer. This temperature kills harmful bacteria like Salmonella and Campylobacter. When cooking Half-Consumable chicken, ensure thorough cooking and check that juices run clear.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Breed Considerations',
            'description':
                'This application is calibrated for Broiler Hybrid (Magnolia) chicken breast. While the general principles apply to all chicken types, there may be slight variations in color and texture between breeds. Broiler chickens typically have lighter meat compared to free-range or heritage breeds.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Time & Temperature Factors',
            'description':
                'Our experimental data is based on a 3-day observation period of refrigerated chicken breast. The app\'s machine learning model was trained on images collected daily over this period, capturing the progressive changes in appearance as the chicken deteriorated from fresh to spoiled state. Temperature was maintained at 4°C (39°F) throughout the experiment.',
            'image': 'images/ui/guide',
          },
          {
            'title': 'Experimental Design',
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

class GuideBookButton extends StatelessWidget {
  const GuideBookButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.menu_book_rounded,
        color: Color(0xFFF3E5AB), // Match the color with other app bar icons
      ),
      tooltip: 'Prediction Guide',
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const GuideBookModal();
          },
        );
      },
    );
  }
}
