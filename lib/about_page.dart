import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  final VoidCallback onBackToHome;

  const AboutPage({super.key, required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> members = [
      {
        'imagePath': 'images/devs/dollano.jpg',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            onBackToHome(); // Navigate back to Home Page
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align content to the start
              children: [
                const SizedBox(height: 10), // Replaced Container with SizedBox
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 233, 233, 233),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align text to the start
                    children: [
                      const Text(
                        "About the App",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                          height: 15), // Replaced Container with SizedBox
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 400
                            ? 400 // Maximum width for larger screens
                            : MediaQuery.of(context).size.width *
                                0.9, // 90% of the screen width for smaller screens
                        child: const Text(
                          "Check-a-doodle-doo is a mobile application designed to help users assess the consumability of chicken breast by utilizing advanced machine learning algorithms. The app employs a streamlined user interface that allows users to capture images or upload existing photos of chicken breast meat. Through an integrated style of image processing and classification, Check-a-doodle-doo evaluates the consumability of the meat based on visual attributes such as texture, color, and other factors.",
                          textAlign: TextAlign.justify, // Justify the text
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Replaced Container with SizedBox
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 233, 233, 233),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Center content horizontally
                    children: [
                      const Text(
                        "Developers",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                          height: 20), // Replaced Container with SizedBox
                      ...List.generate(
                        members.length,
                        (index) {
                          final member = members[index];
                          return MemberCard(
                            imagePath: member['imagePath']!,
                            name: member['name']!,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Replaced Container with SizedBox
              ],
            ),
          ),
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
          const SizedBox(height: 5), // Replaced Container with SizedBox
          SizedBox(
            width: MediaQuery.of(context).size.width > 400
                ? 300 // Fixed width for larger screens
                : MediaQuery.of(context).size.width *
                    0.8, // 80% of the screen width for smaller screens
            child: Text(
              name,
              textAlign: TextAlign.center, // Center the text
              style: const TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20), // Replaced Container with SizedBox
        ],
      ),
    );
  }
}
