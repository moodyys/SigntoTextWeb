import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedOptionButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final Color backgroundColor;
  final VoidCallback onTap;
  final Widget Function(BuildContext context)? imageBuilder; // الجديد

  const AnimatedOptionButton({
    Key? key,
    required this.label,
    required this.imagePath,
    required this.backgroundColor,
    required this.onTap,
    this.imageBuilder, // الجديد
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 60,
              height: 60,
              child: imageBuilder != null
                  ? imageBuilder!(context)
                  : Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
