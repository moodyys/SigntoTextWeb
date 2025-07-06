import 'package:flutter/material.dart';
import 'Payment_Screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'assets/theme.dart';
import 'assets/animated_option_button.dart';
import 'assets/helpbutton.dart';
import 'assets/backbutton.dart';
//import 'Payment_Screen.dart'; // ← تأكد إنك مستورد الصفحة دي

class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'التبرعات',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          HelpButton(
            messages: [
              'هذه الصفحة لعرض الجمعيات التي يمكنك التبرع لها.',
              'اختر الجمعية التي ترغب في دعمها.',
            ],
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedOptionButton(
              label: 'جمعية مصر الخير',
              imagePath: 'lib/assets/icons/misrelkher.png',
              backgroundColor: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(builder: (context) => PaymentScreen())

                );
              },
            ),
            const SizedBox(height: 20),
            AnimatedOptionButton(
              label: 'جمعية رسالة لرعاية ذوي الاحتياجات الخاصة',
              imagePath: 'lib/assets/icons/Resala.png',
              backgroundColor: AppColors.accent,
              onTap: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(builder: (context) => PaymentScreen())

                );
              },
            ),
            const SizedBox(height: 20),
            AnimatedOptionButton(
              label: 'جمعية المصباح المضئ للاعمال الخيرية',
              imagePath: 'lib/assets/icons/mesbah.png',
              backgroundColor: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(builder: (context) => PaymentScreen())

                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
