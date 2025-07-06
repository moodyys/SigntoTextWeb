import 'package:flutter/material.dart';
import 'assets/theme.dart'; // تأكد أن ملف الألوان مضبوط
import 'assets/buttons.dart';
import 'home_page.dart';

// Custom painter for the wavy blue background
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.15);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.3, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Add a second lighter wave and circular highlights for the wave effect
class SecondWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.45);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height * 0.35);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width, size.height * 0.25);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Replace BottomWaveClipper with a more realistic, multi-curve wave
class RealisticWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.35);
    path.cubicTo(size.width * 0.10, size.height * 0.25, size.width * 0.18, size.height * 0.55, size.width * 0.25, size.height * 0.45);
    path.cubicTo(size.width * 0.40, size.height * 0.25, size.width * 0.60, size.height * 0.65, size.width * 0.75, size.height * 0.45);
    path.cubicTo(size.width * 0.85, size.height * 0.30, size.width * 0.95, size.height * 0.60, size.width, size.height * 0.40);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom painter for a soft white highlight along the wave crest
class WaveHighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withOpacity(0.7), Colors.white.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.15));
    final path = Path();
    path.moveTo(0, size.height * 0.35);
    path.cubicTo(size.width * 0.10, size.height * 0.25, size.width * 0.18, size.height * 0.55, size.width * 0.25, size.height * 0.45);
    path.cubicTo(size.width * 0.40, size.height * 0.25, size.width * 0.60, size.height * 0.65, size.width * 0.75, size.height * 0.45);
    path.cubicTo(size.width * 0.85, size.height * 0.30, size.width * 0.95, size.height * 0.60, size.width, size.height * 0.40);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for a realistic, blurred, radial shadow
class RealisticShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.black.withOpacity(0.22), Colors.transparent],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 + 2),
        width: size.width,
        height: size.height * 0.7,
      ),
      shadowPaint,
    );
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom callout widget
class SpeechBubble extends StatelessWidget {
  final String text;
  final Color color;
  final double width;
  final double height;
  const SpeechBubble({required this.text, required this.color, this.width = 60, this.height = 28, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(12, 6),
          painter: _BubblePointerPainter(color),
        ),
      ],
    );
  }
}

class _BubblePointerPainter extends CustomPainter {
  final Color color;
  _BubblePointerPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth / 4.2;
    final imageHeight = 200.0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Wavy blue background at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 60),
              child: Stack(
                children: [
                  // Main realistic wave with vertical gradient
                  ClipPath(
                    clipper: RealisticWaveClipper(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.71,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF7ED6F7), Color(0xFF50A5CD), Color(0xFF5134D4)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Second lighter wave
                  ClipPath(
                    clipper: SecondWaveClipper(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.71,
                      width: double.infinity,
                      color: const Color(0xFF7ED6F7).withOpacity(0.5),
                    ),
                  ),
                  // Third lighter wave for more realism
                  ClipPath(
                    clipper: ThirdWaveClipper(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.71,
                      width: double.infinity,
                      color: const Color(0xFFB2EBF2).withOpacity(0.4),
                    ),
                  ),
                  // Soft white highlight along the crest
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: WaveHighlightPainter(),
                      ),
                    ),
                  ),
                  // More circular highlights for realism
                  Positioned(
                    left: 40,
                    bottom: 120,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 60,
                    bottom: 100,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 120,
                    bottom: 80,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 120,
                    bottom: 60,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.09),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Characters with callouts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        const SpeechBubble(text: '你好', color: Color(0xFF4B6CB7)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: imageWidth,
                          height: imageHeight,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Flipped character image horizontally
                              Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(3.14159),
                                child: Image.asset('lib/assets/images/char1.png', fit: BoxFit.contain, width: imageWidth, height: imageHeight),
                              ),
                              // Realistic shadow below
                              Positioned(
                                bottom: -18,
                                left: imageWidth * 0.13,
                                right: imageWidth * 0.13,
                                child: SizedBox(
                                  width: imageWidth * 0.74,
                                  height: 32,
                                  child: CustomPaint(
                                    painter: RealisticShadowPainter(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const SpeechBubble(text: 'ALOHA!', color: Color(0xFF388E3C)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: imageWidth,
                          height: imageHeight,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Image.asset('lib/assets/images/char2.png', fit: BoxFit.contain, width: imageWidth, height: imageHeight),
                              Positioned(
                                bottom: -18,
                                left: imageWidth * 0.13,
                                right: imageWidth * 0.13,
                                child: SizedBox(
                                  width: imageWidth * 0.74,
                                  height: 32,
                                  child: CustomPaint(
                                    painter: RealisticShadowPainter(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const SpeechBubble(text: 'HELLO', color: Color(0xFFE57373)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: imageWidth,
                          height: imageHeight,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Flipped character image horizontally
                              Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(3.14159),
                                child: Image.asset('lib/assets/images/char3.png', fit: BoxFit.contain, width: imageWidth, height: imageHeight),
                              ),
                              Positioned(
                                bottom: -18,
                                left: imageWidth * 0.13,
                                right: imageWidth * 0.13,
                                child: SizedBox(
                                  width: imageWidth * 0.74,
                                  height: 32,
                                  child: CustomPaint(
                                    painter: RealisticShadowPainter(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const SpeechBubble(text: 'مرحبا', color: Color(0xFFFFB300)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: imageWidth,
                          height: imageHeight,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Image.asset('lib/assets/images/char4.png', fit: BoxFit.contain, width: imageWidth, height: imageHeight),
                              Positioned(
                                bottom: -18,
                                left: imageWidth * 0.13,
                                right: imageWidth * 0.13,
                                child: SizedBox(
                                  width: imageWidth * 0.74,
                                  height: 32,
                                  child: CustomPaint(
                                    painter: RealisticShadowPainter(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                // Logo at the intersection of wave and white background
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Much bigger, original color logo, moved up by 1.5 cm (60px)
                    Transform.translate(
                      offset: const Offset(0, -80),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 220,
                            alignment: Alignment.topCenter,
                            child: Image.asset(
                              'lib/assets/images/logo.png',
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: SizedBox(
                              width: 220,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => const HomePage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text('اضغط للبدا'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add _TopLogoClipper to clip the top part of the logo for the white background
class _TopLogoClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.15);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.3, size.width, 0);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Add a third lighter wave for more realism
class ThirdWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.55);
    path.cubicTo(size.width * 0.15, size.height * 0.35, size.width * 0.25, size.height * 0.95, size.width * 0.4, size.height * 0.75);
    path.cubicTo(size.width * 0.6, size.height * 0.45, size.width * 0.8, size.height * 1.15, size.width, size.height * 0.65);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
