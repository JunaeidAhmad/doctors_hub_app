import 'package:flutter_test/flutter_test.dart';
import 'package:doctors_hub_app/core/utils/validators.dart';

void main() {
  group('Validators - BD Phone', () {
    test('validates standard 11-digit BD mobile numbers', () {
      expect(Validators.isValidBdPhone('01712345678'), isTrue);
      expect(Validators.isValidBdPhone('01998765432'), isTrue);
      expect(Validators.isValidBdPhone('01811223344'), isTrue);
      expect(Validators.isValidBdPhone('01312345678'), isTrue);
      expect(Validators.isValidBdPhone('01412345678'), isTrue);
      expect(Validators.isValidBdPhone('01512345678'), isTrue);
      expect(Validators.isValidBdPhone('01612345678'), isTrue);
    });

    test('validates numbers with spaces, hyphens, and +88 prefix', () {
      expect(Validators.isValidBdPhone('+8801712345678'), isTrue);
      expect(Validators.isValidBdPhone('8801712345678'), isTrue);
      expect(Validators.isValidBdPhone('01712-345678'), isTrue);
      expect(Validators.isValidBdPhone('01712 345 678'), isTrue);
    });

    test('rejects invalid numbers', () {
      expect(Validators.isValidBdPhone('01212345678'), isFalse); // operator 2 invalid
      expect(Validators.isValidBdPhone('01012345678'), isFalse); // operator 0 invalid
      expect(Validators.isValidBdPhone('0171234567'), isFalse);  // too short (10 digits)
      expect(Validators.isValidBdPhone('017123456789'), isFalse); // too long (12 digits)
      expect(Validators.isValidBdPhone('abcdefghijk'), isFalse);
      expect(Validators.isValidBdPhone(''), isFalse);
      expect(Validators.isValidBdPhone(null), isFalse);
    });

    test('normalizes phone number properly', () {
      expect(Validators.normalizePhone('+8801712345678'), equals('01712345678'));
      expect(Validators.normalizePhone('8801712345678'), equals('01712345678'));
      expect(Validators.normalizePhone('01712-345 678'), equals('01712345678'));
    });
  });
}
