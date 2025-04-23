import 'package:flutter/material.dart';
import 'guide_book_modal.dart';

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
