import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  final VoidCallback onBackToHome;

  const AboutPage({super.key, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> members = [
      {
        'imagePath': 'images/dollano.jpg',
        'name': 'Dollano, Melissa Pola Anthony F.',
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

    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: "Garamond",
        fontSize: 16,
        color: Color(0xFF3E2C1C),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3E2C1C),
          elevation: 4,
          iconTheme: const IconThemeData(color: Color(0xFFF3E5AB)),
          titleTextStyle: const TextStyle(
            color: Color(0xFFF3E5AB),
            fontFamily: 'Garamond',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          title: const Text("About"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackToHome,
          ),
        ),
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'images/ui/main_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            // Semi-transparent overlay
            Container(color: Colors.black.withAlpha(77)),
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // About Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5AB), // Light background
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(77),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "About the App",
                              style: TextStyle(
                                color: Color(0xFF3E2C1C), // Dark font color
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Check-a-doodle-doo is a mobile application designed to help users assess the consumability of chicken breast...",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                height: 1.5,
                                color: Color(0xFF3E2C1C), // Dark font color
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Developers Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5AB), // Light background
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(77),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Developers",
                              style: TextStyle(
                                color: Color(0xFF3E2C1C), // Dark font color
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ...members.map((member) => MemberCard(
                                  imagePath: member['imagePath']!,
                                  name: member['name']!,
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  final String imagePath;
  final String name;

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
          ClipOval(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              height: 100,
              width: 100,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: MediaQuery.of(context).size.width > 400
                ? 300
                : MediaQuery.of(context).size.width * 0.8,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3E2C1C), // Dark font
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
