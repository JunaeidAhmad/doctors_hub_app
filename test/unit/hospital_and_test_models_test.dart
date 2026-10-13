import 'package:flutter_test/flutter_test.dart';
import 'package:doctors_hub_app/features/hospitals/domain/models/hospital.dart';
import 'package:doctors_hub_app/features/tests/domain/models/facility_test.dart';

void main() {
  group('Hospital Model', () {
    test('parses ownership_type and location details correctly', () {
      final json = {
        'id': 'hosp-1',
        'name': 'Square Hospital',
        'bn_name': 'স্কয়ার হাসপাতাল',
        'slug': 'square-hospital',
        'category': 'General Hospital',
        'division': 'Dhaka',
        'district': 'Dhaka',
        'area': 'Panthapath',
        'ownership_type': 'private',
        'rating': 4.8,
        'reviews_count': 120,
      };

      final hospital = Hospital.fromJson(json);

      expect(hospital.id, equals('hosp-1'));
      expect(hospital.name, equals('Square Hospital'));
      expect(hospital.ownershipType, equals('private'));
      expect(hospital.division, equals('Dhaka'));
      expect(hospital.district, equals('Dhaka'));
      expect(hospital.area, equals('Panthapath'));
    });

    test('serializes ownership_type to JSON correctly', () {
      const hospital = Hospital(
        id: 'hosp-1',
        name: 'Square Hospital',
        slug: 'square-hospital',
        ownershipType: 'government',
      );

      final map = hospital.toJson();
      expect(map['ownership_type'], equals('government'));
    });
  });

  group('FacilityTest Model', () {
    test('parses location hierarchy and ownership correctly', () {
      final json = {
        'id': 'ft-1',
        'test_id': 't-1',
        'test_name': 'CBC',
        'facility_id': 'f-1',
        'facility_name': 'Popular Diagnostic Centre',
        'price': 450.0,
        'home_sample_collection': true,
        'home_sample_charge': 100.0,
        'location_details': {
          'division': 'Dhaka',
          'district': 'Dhaka',
          'area': 'Dhanmondi',
          'ownership_type': 'private',
          'thana_details': {
            'id': 15,
            'district_id': 2,
            'division_id': 1,
          },
        },
      };

      final ft = FacilityTest.fromJson(json);

      expect(ft.id, equals('ft-1'));
      expect(ft.facilityName, equals('Popular Diagnostic Centre'));
      expect(ft.homeSampleCollection, isTrue);
      expect(ft.facilityDivision, equals('Dhaka'));
      expect(ft.facilityDistrict, equals('Dhaka'));
      expect(ft.facilityArea, equals('Dhanmondi'));
      expect(ft.facilityOwnershipType, equals('private'));
      expect(ft.divisionId, equals(1));
      expect(ft.districtId, equals(2));
      expect(ft.thanaId, equals(15));
    });
  });
}
