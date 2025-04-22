import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        SizedBox.expand(
          child: Image.asset(
            'assets/images/ui/main_bg.png', // BG image
            fit: BoxFit.cover,
          ),
        ),
        // Optional overlay to darken or color-tint the background
        Container(
          color: Colors.black.withAlpha(77), // closest value to 0.3
        ),
        // The foreground content
        child,
      ],
    );
  }
}
