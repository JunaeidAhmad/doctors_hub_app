import 'package:flutter_test/flutter_test.dart';
import 'package:doctors_hub_app/features/location/domain/models/district.dart';
import 'package:doctors_hub_app/features/location/domain/models/thana.dart';

void main() {
  group('District Model', () {
    test('parses JSON correctly', () {
      final json = {
        'id': 1,
        'division': 2,
        'division_name': 'Dhaka',
        'division_bn_name': 'ঢাকা',
        'name': 'Gazipur',
        'bn_name': 'গাজীপুর',
        'slug': 'gazipur',
        'thanas_count': 5,
      };

      final district = District.fromJson(json);

      expect(district.id, equals(1));
      expect(district.divisionId, equals(2));
      expect(district.divisionName, equals('Dhaka'));
      expect(district.name, equals('Gazipur'));
      expect(district.bnName, equals('গাজীপুর'));
      expect(district.slug, equals('gazipur'));
      expect(district.thanasCount, equals(5));
      expect(district.localizedName('en'), equals('Gazipur'));
      expect(district.localizedName('bn'), equals('গাজীপুর'));
    });

    test('serializes to JSON correctly', () {
      const district = District(
        id: 1,
        divisionId: 2,
        divisionName: 'Dhaka',
        divisionBnName: 'ঢাকা',
        name: 'Gazipur',
        bnName: 'গাজীপুর',
        slug: 'gazipur',
        thanasCount: 5,
      );

      final map = district.toJson();
      expect(map['id'], equals(1));
      expect(map['division'], equals(2));
      expect(map['name'], equals('Gazipur'));
      expect(map['bn_name'], equals('গাজীপুর'));
    });
  });

  group('Thana Model', () {
    test('parses JSON correctly', () {
      final json = {
        'id': 10,
        'district': 1,
        'district_name': 'Dhaka',
        'district_bn_name': 'ঢাকা',
        'division_id': 2,
        'division_name': 'Dhaka',
        'division_bn_name': 'ঢাকা',
        'name': 'Dhanmondi',
        'bn_name': 'ধানমন্ডি',
        'slug': 'dhanmondi',
      };

      final thana = Thana.fromJson(json);

      expect(thana.id, equals(10));
      expect(thana.districtId, equals(1));
      expect(thana.districtName, equals('Dhaka'));
      expect(thana.divisionId, equals(2));
      expect(thana.name, equals('Dhanmondi'));
      expect(thana.bnName, equals('ধানমন্ডি'));
      expect(thana.slug, equals('dhanmondi'));
      expect(thana.localizedName('en'), equals('Dhanmondi'));
      expect(thana.localizedName('bn'), equals('ধানমন্ডি'));
    });

    test('serializes to JSON correctly', () {
      const thana = Thana(
        id: 10,
        districtId: 1,
        districtName: 'Dhaka',
        name: 'Dhanmondi',
        bnName: 'ধানমন্ডি',
        slug: 'dhanmondi',
      );

      final map = thana.toJson();
      expect(map['id'], equals(10));
      expect(map['district'], equals(1));
      expect(map['name'], equals('Dhanmondi'));
    });
  });
}
