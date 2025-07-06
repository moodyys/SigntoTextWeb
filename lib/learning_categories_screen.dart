import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'learning_video_screen.dart';
import 'assets/theme.dart';
import 'assets/backbutton.dart';

class LearningCategoriesScreen extends StatelessWidget {
  const LearningCategoriesScreen({super.key});

  // Change this URL based on your hosting:
  // For local testing: 'http://localhost:8000'
  // For GitHub: 'https://raw.githubusercontent.com/YOUR_USERNAME/sign-language-videos/main'
  // For Netlify: 'https://your-site.netlify.app'
  static const String baseUrl = 'http://localhost:8000'; // Change this!

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'الأشهر', 'video': '$baseUrl/months.mp4'},
      {'title': 'التعلم', 'video': '$baseUrl/learning.mp4'},
      {'title': 'الوقت', 'video': '$baseUrl/time.mp4'},
      {'title': 'المرض', 'video': '$baseUrl/ill.mp4'},
      {'title': 'أيام الأسبوع', 'video': '$baseUrl/weekdays.mp4'},
      {'title': 'الاستغاثة', 'video': '$baseUrl/SOS.mp4'},
      {'title': 'الصحة', 'video': '$baseUrl/health.mp4'},
      {'title': 'العائلة', 'video': '$baseUrl/family.mp4'},
    ];
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'التعليم',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...categories.map((cat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LearningVideoScreen(
                        title: cat['title']!,
                        videoPath: cat['video']!,
                        isNetwork: true,
                      ),
                    ),
                  );
                },
                child: Text(
                  cat['title']!,
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
} 