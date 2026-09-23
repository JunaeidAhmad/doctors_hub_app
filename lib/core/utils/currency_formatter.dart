import 'package:intl/intl.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static const Map<String, String> _enToBnDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  static String toBengaliDigits(String input) {
    return input.split('').map((char) => _enToBnDigits[char] ?? char).join();
  }

  /// Formats amount with ৳ symbol and localized thousands separator / Bengali digits
  static String format(num? amount, {String locale = 'en', bool symbol = true}) {
    if (amount == null) return symbol ? '৳0' : '0';

    final formatter = NumberFormat('#,##,###', 'en');
    final formatted = formatter.format(amount);

    if (locale == 'bn') {
      final bnFormatted = toBengaliDigits(formatted);
      return symbol ? '৳$bnFormatted' : bnFormatted;
    }

    return symbol ? '৳$formatted' : formatted;
  }
}
