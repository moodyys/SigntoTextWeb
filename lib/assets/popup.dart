import 'theme.dart';
import 'buttons.dart';
import 'package:flutter/material.dart';


void showHelpTip(BuildContext context, String tip) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tip, textDirection: TextDirection.rtl),
          const SizedBox(height: 10),
          primaryButton('فهمت', () => Navigator.pop(context)),
        ],
      ),
    ),
  );
}