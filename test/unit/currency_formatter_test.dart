import 'package:flutter_test/flutter_test.dart';
import 'package:doctors_hub_app/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats in English correctly', () {
      expect(CurrencyFormatter.format(1200, locale: 'en'), equals('৳1,200'));
      expect(CurrencyFormatter.format(500, locale: 'en'), equals('৳500'));
      expect(CurrencyFormatter.format(100000, locale: 'en'), equals('৳1,00,000'));
      expect(CurrencyFormatter.format(0, locale: 'en'), equals('৳0'));
    });

    test('formats in Bengali correctly with Bengali digits', () {
      expect(CurrencyFormatter.format(1200, locale: 'bn'), equals('৳১,২০০'));
      expect(CurrencyFormatter.format(500, locale: 'bn'), equals('৳৫০০'));
      expect(CurrencyFormatter.format(100000, locale: 'bn'), equals('৳১,০০,০০০'));
    });

    test('supports format without currency symbol', () {
      expect(CurrencyFormatter.format(1200, locale: 'en', symbol: false), equals('1,200'));
      expect(CurrencyFormatter.format(1200, locale: 'bn', symbol: false), equals('১,২০০'));
    });
  });
}
