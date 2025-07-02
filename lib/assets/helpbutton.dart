import 'package:flutter/material.dart';
import 'theme.dart'; // ملف الألوان AppColors

class HelpButton extends StatelessWidget {
  final List<String> messages;

  const HelpButton({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline, color: AppColors.primary),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => _HelpDialog(messages: messages),
        );
      },
    );
  }
}

class _HelpDialog extends StatefulWidget {
  final List<String> messages;

  const _HelpDialog({required this.messages});

  @override
  State<_HelpDialog> createState() => _HelpDialogState();
}

class _HelpDialogState extends State<_HelpDialog> {
  int _currentIndex = 0;

  void _next() {
    if (_currentIndex < widget.messages.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.secondary.withOpacity(0.5), // خط خفيف
          width: 1.5,
        ),
      ),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 300,
        height: 220,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    widget.messages[_currentIndex],
                    key: ValueKey(_currentIndex),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentIndex > 0)
                    ElevatedButton(
                      onPressed: _previous,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // لون البنفسجي للزر
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(40, 40),
                        elevation: 0,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '${_currentIndex + 1}/${widget.messages.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (_currentIndex < widget.messages.length - 1)
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // لون البنفسجي للزر
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(40, 40),
                        elevation: 0,
                      ),
                      child: const Icon(Icons.arrow_forward_ios, size: 18),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}