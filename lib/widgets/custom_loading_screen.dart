import 'package:flutter/material.dart';

class CustomLoadingScreen extends StatelessWidget {
  final String? message;

  const CustomLoadingScreen({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF3E2C1C), // App's primary brown color
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Chicken logo in perfect circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromRGBO(255, 255, 255, 0.15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'images/ui/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // App name text - removed any decoration that might cause underline
          const Text(
            "Check-a-Doodle-Doo",
            style: TextStyle(
              color: Color(0xFFF3E5AB),
              fontFamily: 'Garamond',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none, // Explicitly set no decoration
            ),
          ),

          const SizedBox(height: 10),

          // Optional message text - removed any decoration that might cause underline
          if (message != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF3E5AB),
                  fontFamily: 'Garamond',
                  fontSize: 16,
                  decoration:
                      TextDecoration.none, // Explicitly set no decoration
                ),
              ),
            ),

          const SizedBox(height: 40),

          // Loading indicator
          const CircularProgressIndicator(
            color: Color(0xFFF3E5AB),
            strokeWidth: 3,
          ),
        ],
      ),
    );
  }
}
