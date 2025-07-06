import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'assets/theme.dart';
import 'assets/animated_option_button.dart';
import 'assets/helpbutton.dart';
import 'assets/bottombar.dart';
//import 'camera_page.dart';
import 'donation.dart'; // Import صفحة التبرعات
//import 'package:camera/camera.dart' as camera_pkg;
import 'package:flutter/services.dart';
//import 'package:flutter/foundation.dart' show kIsWeb;
import 'flutter_unity_page.dart';
import 'learning_categories_screen.dart';

//import 'Payment_Screen.dart';
import 'dart:html' as html;



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // لتتبع الصفحة الحالية
  static const platform = MethodChannel('com.example.signtotext/sign_language_service');

  Future<void> _startSignLanguageService() async {
    try {
      await platform.invokeMethod('startSignLanguageService');
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  // دالة لفتح صفحة جديدة
  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // عناصر الصفحة الرئيسية
  List<Widget> _buildHomePage() {
    return [
      AnimatedOptionButton(
        label: 'الترجمة اللحظية',
        imagePath: 'lib/assets/icons/realtime.png',
        backgroundColor: AppColors.primary,
        onTap: () {
          html.window.open('http://localhost:8080', '_blank');
        },
        imageBuilder: (context) => ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            'lib/assets/icons/realtime.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      const SizedBox(height: 20),
      AnimatedOptionButton(
        label: 'نص إلى إشارة',
        imagePath: 'lib/assets/icons/texttosign.png',
        backgroundColor: AppColors.accent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FlutterUnityPage()),
          );
        },
        imageBuilder: (context) => ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            'lib/assets/icons/texttosign.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    ];
  }

  // عناصر صفحة التعليم والتبرعات
  List<Widget> _buildDonationAndLearningPage() {
    return [
      AnimatedOptionButton(
        label: 'التعليم',
        imagePath: 'lib/assets/icons/learning.png',
        backgroundColor: AppColors.primary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LearningCategoriesScreen()),
          );
        },
        imageBuilder: (context) => ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            'lib/assets/icons/learning.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      const SizedBox(height: 20),
      AnimatedOptionButton(
        label: 'التبرع',
        imagePath: 'lib/assets/icons/donation.png',
        backgroundColor: AppColors.accent,
        onTap: () {
          _navigateToPage(const DonationsPage()); // فتح صفحة التبرعات
        },
        imageBuilder: (context) => ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            'lib/assets/icons/donation.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'الرئيسية' : 'التعليم والتبرعات',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          HelpButton(
            messages: [
              _currentIndex == 0
                  ? 'مرحباً بك في الصفحة الرئيسية! يمكنك اختيار نوع الترجمة.'
                  : 'اختر الجمعية التي ترغب في دعمها.',
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _currentIndex == 0
              ? _buildHomePage()
              : _buildDonationAndLearningPage(),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}