import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signtotext/donation.dart';
import 'assets/theme.dart';
import 'assets/helpbutton.dart';
import 'assets/backbutton.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePayment() {
    final card = _cardNumberController.text.trim();
    final expiry = _expiryDateController.text.trim();
    final cvv = _cvvController.text.trim();
    final amount = _amountController.text.trim();

    if (card.length != 25 || !card.contains(' - ')) {
      _showError('من فضلك أدخل رقم بطاقة صالح.');
      return;
    }
    if (!RegExp(r'^\d{2} / \d{2}$').hasMatch(expiry)) {
      _showError('صيغة تاريخ الانتهاء غير صحيحة (مثال: 05 / 26).');
      return;
    }
    if (cvv.length != 3) {
      _showError('CVV يجب أن يتكون من 3 أرقام.');
      return;
    }
    if (amount.isEmpty || double.tryParse(amount) == null || double.parse(amount) <= 0) {
      _showError('أدخل مبلغًا صالحًا.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تم"),
        content: const Text("تمت عملية الدفع بنجاح!"),
        actions: [
          TextButton(
            child: const Text("حسناً"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('إغلاق'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    List<TextInputFormatter>? formatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.tajawal(color: AppColors.secondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(
          onPressed: () {
            Navigator.pop(context); // الرجوع إلى الصفحة السابقة عند الضغط على زر الرجوع
          },
        ),
        title: Text(
          'الدفع',
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
              'أدخل بيانات بطاقتك والمبلغ المراد دفعه.',
              'ثم اضغط على زر الدفع لإتمام العملية.',
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                controller: _cardNumberController,
                label: 'رقم البطاقة',
                hint: 'مثال: 1234 - 5678 - 9012 - 3456',
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(25),
                  _CardNumberInputFormatter(),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _expiryDateController,
                label: 'تاريخ الانتهاء',
                hint: 'مثال: 05 / 26',
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(7),
                  _ExpiryDateFormatter(),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _cvvController,
                label: 'CVV',
                hint: 'مثال: 123',
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _amountController,
                label: 'المبلغ',
                hint: 'مثال: 50.00',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'ادفع الآن',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Formatter لرقم البطاقة
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = '';

    for (int i = 0; i < digitsOnly.length && i < 16; i++) {
      if (i != 0 && i % 4 == 0) {
        formatted += ' - ';
      }
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Formatter لتاريخ الانتهاء
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 4) {
      digits = digits.substring(0, 4);
    }

    String formatted = '';
    if (digits.length >= 2) {
      formatted = '${digits.substring(0, 2)} / ';
      if (digits.length > 2) {
        formatted += digits.substring(2);
      }
    } else {
      formatted = digits;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}