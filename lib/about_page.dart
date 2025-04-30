import 'package:flutter/material.dart'; // Core Flutter framework
import 'package:check_a_doodle_doo/background_wrapper.dart'; // Custom background with patterned texture
import 'widgets/guide_book_button.dart'; // Button to access the app's guide book

/// AboutPage displays information about the app and its developers
/// This includes an app description and developer information with profile pictures
class AboutPage extends StatelessWidget {
  final VoidCallback onBackToHome; // Callback function to return to home screen

  // Constructor requiring the navigation callback
  const AboutPage({super.key, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    // List of team members with their images and names
    List<Map<String, String>> members = [
      {
        'imagePath': 'images/dollano.jpg', // Path to developer profile image
        'name': 'Dollano, Melissa Pola Anthony F.', // Developer's full name
      },
      {
        'imagePath': 'images/devs/Enriquez.png',
        'name': 'Enriquez, Leslie Ann E.',
      },
      {
        'imagePath': 'images/devs/Oropesa.png',
        'name': 'Oropesa, Ernest Marshal M.',
      }
    ];

    // Apply consistent text styling to all text in this screen
    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily:
            "Garamond", // App's primary font family for consistent branding
        fontSize: 16, // Default text size
        color:
            Color(0xFF3E2C1C), // Dark brown text color for better readability
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3E2C1C), // Dark brown app bar
          elevation: 4, // Slight shadow for depth
          iconTheme: const IconThemeData(
              color: Color(0xFFF3E5AB)), // Light cream icons
          titleTextStyle: const TextStyle(
            color: Color(0xFFF3E5AB), // Light cream text color for contrast
            fontFamily: 'Garamond', // Maintain consistent font family
            fontSize: 22, // Larger text size for title
            fontWeight: FontWeight.w600, // Semi-bold for emphasis
          ),
          title: const Text("About"), // Page title
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // Back navigation arrow
            onPressed: onBackToHome, // Return to home page when pressed
          ),
          actions: const [
            GuideBookButton(), // Include guide book access in app bar
          ],
        ),
        body: BackgroundWrapper(
          child: SingleChildScrollView(
            // Allow scrolling if content doesn't fit screen
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0), // Side margins
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Left-align content
                  children: [
                    const SizedBox(height: 20), // Top margin

                    // About Section - contains app description
                    Container(
                      width: double.infinity, // Fill available width
                      padding: const EdgeInsets.all(24), // Inner padding
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFF3E5AB), // Light cream background
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withAlpha(77), // Soft shadow (30% opacity)
                            blurRadius: 10, // Shadow blur amount
                            offset:
                                const Offset(0, 4), // Shadow position (down)
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "About the App", // Section heading
                            style: TextStyle(
                              color: Color(0xFF3E2C1C), // Dark brown text
                              fontWeight: FontWeight.bold, // Bold for emphasis
                              fontSize: 22, // Larger size for heading
                            ),
                          ),
                          SizedBox(
                              height:
                                  16), // Spacing between heading and content
                          Text(
                            "Check-a-doodle-doo is a mobile application designed to help users assess the consumability of chicken breast...", // App description (truncated text)
                            textAlign:
                                TextAlign.justify, // Full text justification
                            style: TextStyle(
                              height: 1.5, // Line height for better readability
                              color: Color(0xFF3E2C1C), // Dark brown text
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28), // Spacing between sections

                    // Developers Section - displays team member information
                    Container(
                      width: double.infinity, // Fill available width
                      padding: const EdgeInsets.all(20), // Inner padding
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFFF3E5AB), // Light cream background (same as above)
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(77), // Soft shadow
                            blurRadius: 10, // Shadow blur amount
                            offset:
                                const Offset(0, 4), // Shadow position (down)
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Developers", // Section heading
                            style: TextStyle(
                              color: Color(0xFF3E2C1C), // Dark brown text
                              fontWeight: FontWeight.bold, // Bold for emphasis
                              fontSize: 22, // Larger size for heading
                            ),
                          ),
                          const SizedBox(height: 20), // Spacing after heading
                          // Generate developer cards for each team member
                          ...members.map((member) => MemberCard(
                                imagePath:
                                    member['imagePath']!, // Profile image path
                                name: member['name']!, // Developer name
                              )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40), // Bottom margin
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// MemberCard widget displays a developer's profile picture and name
/// Used to create consistent developer entries in the About page
class MemberCard extends StatelessWidget {
  final String imagePath; // Path to the developer's profile image
  final String name; // Developer's full name

  // Constructor requiring image path and name
  const MemberCard({
    super.key,
    required this.imagePath,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Circular profile picture
          ClipOval(
            // Clip image to circular shape
            child: Image.asset(
              imagePath, // Load image from assets
              fit: BoxFit.cover, // Crop image to fill container
              height: 100, // Fixed height for consistency
              width: 100, // Fixed width for perfect circle
            ),
          ),
          const SizedBox(height: 5), // Spacing between image and name
          // Developer name with responsive width
          SizedBox(
            width: MediaQuery.of(context).size.width > 400
                ? 300 // Fixed width on larger screens
                : MediaQuery.of(context).size.width *
                    0.8, // 80% of screen width on smaller screens
            child: Text(
              name, // Developer name
              textAlign: TextAlign.center, // Center-align text
              style: const TextStyle(
                color: Color(0xFF3E2C1C), // Dark brown text
                fontWeight: FontWeight.w500, // Medium weight for readability
                fontSize: 14, // Smaller text size for names
              ),
            ),
          ),
          const SizedBox(height: 20), // Bottom spacing between developers
        ],
      ),
    );
  }
}
