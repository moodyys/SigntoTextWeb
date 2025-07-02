import 'package:flutter/material.dart';
import 'theme.dart'; // لو بتحب تستخدم ألوانك المخصصة AppColors

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new,
        color: iconColor ?? AppColors.primary, // لو مفيش لون مختار، يحط اللون الأساسي
        size: 24,
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      splashRadius: 24,
    );
  }
}