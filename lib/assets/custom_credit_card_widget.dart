import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class CustomCreditCardWidget extends StatelessWidget {
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final bool showBackView;
  final Color cardBgColor;
  final double height;
  final double width;
  final Duration animationDuration;
  final Widget? visaLogo;

  const CustomCreditCardWidget({
    Key? key,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    required this.showBackView,
    required this.cardBgColor,
    required this.height,
    required this.width,
    required this.animationDuration,
    this.visaLogo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: animationDuration,
      transitionBuilder: (child, animation) {
        final rotate = Tween(begin: pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final isUnder = (ValueKey(showBackView) != child?.key);
            var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
            tilt *= isUnder ? -1.0 : 1.0;
            final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
            return Transform(
              transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      },
      child: showBackView ? _buildBack(context) : _buildFront(context),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
    );
  }

  Widget _buildFront(BuildContext context) {
    return Container(
      key: const ValueKey(false),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Chip image or placeholder
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFe0c97f),
                            Color(0xFFbcae7e),
                            Color(0xFFf5e7b2),
                            Color(0xFFbcae7e),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.black26, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Horizontal lines
                          Positioned(
                            left: 6,
                            right: 6,
                            top: 8,
                            child: Container(height: 2, color: Colors.black12),
                          ),
                          Positioned(
                            left: 6,
                            right: 6,
                            top: 16,
                            child: Container(height: 2, color: Colors.black12),
                          ),
                          Positioned(
                            left: 6,
                            right: 6,
                            top: 24,
                            child: Container(height: 2, color: Colors.black12),
                          ),
                          // Vertical rectangles
                          Positioned(
                            left: 8,
                            top: 6,
                            bottom: 6,
                            child: Container(width: 6, decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            )),
                          ),
                          Positioned(
                            right: 8,
                            top: 6,
                            bottom: 6,
                            child: Container(width: 6, decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  cardNumber.isEmpty ? '**** **** **** ****' : cardNumber,
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'VALID THRU',
                              style: GoogleFonts.robotoMono(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              expiryDate.isEmpty ? 'MM/YY' : expiryDate,
                              style: GoogleFonts.robotoMono(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cardHolderName.isEmpty ? 'CARDHOLDER' : cardHolderName,
                          style: GoogleFonts.robotoMono(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // VISA logo always at bottom right
          if (visaLogo != null)
            Positioned(
              bottom: 16,
              right: 24,
              child: visaLogo!,
            ),
        ],
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return Container(
      key: const ValueKey(true),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Black stripe
          Positioned(
            top: 32,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              color: Colors.black87,
            ),
          ),
          // White box for CVV
          Positioned(
            top: 90,
            left: 24,
            right: 24,
            child: Container(
              height: 40,
              color: Colors.white,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                cvvCode.isEmpty ? 'CVV' : cvvCode,
                style: GoogleFonts.robotoMono(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          // VISA logo always at bottom right
          if (visaLogo != null)
            Positioned(
              bottom: 16,
              right: 24,
              child: visaLogo!,
            ),
        ],
      ),
    );
  }
} 