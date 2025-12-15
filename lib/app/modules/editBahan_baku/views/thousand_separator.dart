import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.tryParse(newValue.text.replaceAll('.', '')) ?? 0;
    final formatter = NumberFormat('#,###','id_ID');
    // Gunakan lokal 'id_ID' untuk pemisah ribuan

    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
  static String format(dynamic value) {
    if (value == null) return '';
    final number = int.tryParse(value.toString()) ?? 0;
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number).replaceAll(',', '.');
  }
}