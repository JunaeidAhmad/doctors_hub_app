import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:doctors_hub_app/features/booking/data/booking_repository.dart';
import 'package:doctors_hub_app/features/booking/domain/models/booking_result.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/chamber.dart';
import 'package:doctors_hub_app/features/doctors/domain/models/doctor.dart';
import 'package:doctors_hub_app/features/hospitals/domain/models/hospital.dart';
import 'package:doctors_hub_app/features/tests/domain/models/test_search.dart';

dynamic fixture(String name) =>
    jsonDecode(File('test/fixtures/v1/$name').readAsStringSync());

void main() {
  group('Doctor and Chamber', () {
    test('doctor list fixture parses chambers with a facility name', () {
      final page = fixture('doctors_list.json') as Map<String, dynamic>;
      final results = page['results'] as List;
      final doctor = Doctor.fromJson(results.first as Map<String, dynamic>);

      expect(doctor.id, isNotEmpty);
      expect(doctor.chambers, isNotEmpty);
      expect(doctor.chambers.first.facility.displayName, isNotEmpty);
      expect(doctor.chambers.first.bookingMode, isNot(BookingMode.unknown));
    });

    test('doctor detail fixture parses 2+ chambers and booking_mode', () {
      final detail = fixture('doctor_detail.json') as Map<String, dynamic>;
      final doctor = Doctor.fromJson(detail);

      expect(doctor.chambers.length, greaterThanOrEqualTo(2));
      expect(doctor.chambers.first.bookingMode, isA<BookingMode>());
      expect(doctor.chambers.first.advanceBookingDays, isNotNull);
      expect(doctor.specialtyDisplay, isNotNull);
    });

    test('minFee ignores null fees and primaryChamber is the first chamber',
        () {
      final doctor = Doctor.fromJson({
        'id': '1',
        'name': 'Doc',
        'slug': 'doc',
        'chambers': [
          {
            'id': 'c1',
            'fee': null,
            'facility': {'id': 'f1', 'display_name': 'First'},
          },
          {
            'id': 'c2',
            'fee': '500.00',
            'facility': {'id': 'f2', 'display_name': 'Second'},
          },
        ],
      });

      expect(doctor.minFee, 500.0);
      expect(doctor.primaryChamber!.id, 'c1');
    });

    test('an unknown booking_mode parses to unknown', () {
      final chamber = Chamber.fromJson({
        'id': 'c1',
        'booking_mode': 'video_call',
        'facility': {'id': 'f1', 'display_name': 'X'},
      });
      expect(chamber.bookingMode, BookingMode.unknown);
    });
  });

  group('Hospital', () {
    test('list fixture parses the flat facility summary', () {
      final page = fixture('hospitals.json') as Map<String, dynamic>;
      final results = page['results'] as List;
      final hospital = Hospital.fromJson(results.first as Map<String, dynamic>);

      expect(hospital.id, isNotEmpty);
      expect(hospital.displayName, isNotEmpty);
      expect(hospital.doctorCount, isNotNull);
      expect(hospital.locationType, isNotNull);
    });

    test('parses the v1 flat shape with category object', () {
      final hospital = Hospital.fromJson({
        'id': 'loc-1',
        'slug': 'square',
        'display_name': 'Square Hospital (Panthapath)',
        'name': 'Square Hospital',
        'branch': 'Panthapath',
        'address': '18/F Panthapath',
        'area': 'Panthapath',
        'area_bn': 'পান্থপথ',
        'district': 'Dhaka',
        'district_bn': 'ঢাকা',
        'division': 'Dhaka',
        'doctor_count': 25,
        'test_count': 3,
        'category': {'id': 'cat-1', 'slug': 'general', 'name': 'General'},
        'services': [
          {'id': 'svc-1', 'name': 'Check-up package', 'icon': 'stethoscope'},
        ],
      });

      expect(hospital.category, 'General');
      expect(hospital.doctorCount, 25);
      expect(hospital.testCount, 3);
      expect(hospital.services.single.name, 'Check-up package');
      expect(hospital.localizedArea('bn'), 'পান্থপথ');
      expect(hospital.localizedArea('en'), 'Panthapath');
    });

    test('serializes ownership_type to JSON correctly', () {
      const hospital = Hospital(
        id: 'hosp-1',
        displayName: 'Square Hospital',
        name: 'Square Hospital',
        slug: 'square-hospital',
        ownershipType: 'government',
      );

      final map = hospital.toJson();
      expect(map['ownership_type'], equals('government'));
    });
  });

  group('Test search', () {
    test('search fixture parses groups with offerings', () {
      final page = fixture('facility_tests_search.json') as Map<String, dynamic>;
      final results = page['results'] as List;
      final group = TestSearchGroup.fromJson(results.first as Map<String, dynamic>);

      expect(group.id, isNotEmpty);
      expect(group.offerings, isNotEmpty);
      expect(group.offerings.first.facility.displayName, isNotEmpty);
    });

    test('a null-price offering has no shown amount', () {
      final offering = LabOffering.fromJson({
        'id': 'o1',
        'facility': {'id': 'f1', 'display_name': 'Lab'},
        'price': null,
        'calculated_price': null,
      });

      expect(offering.shownPrice, isNull);
      expect(offering.priceAtCounter, isTrue);
    });

    test('a discount_percent string parses to a decimal', () {
      final offering = LabOffering.fromJson({
        'id': 'o1',
        'facility': {'id': 'f1', 'display_name': 'Lab'},
        'price': '500.00',
        'calculated_price': '450.00',
        'discount_percent': '10.00',
      });

      expect(offering.discountPercent, 10.0);
      expect(offering.shownPrice, 450.0);
      expect(offering.priceAtCounter, isFalse);
    });

    test('facets parse fulfillment and ownership counts', () {
      final facets = TestSearchFacets.fromJson({
        'fulfillment': {'home': 13, 'center': 13},
        'ownership': {
          'private': 11,
          'government': 2,
          'hospital_affiliated': 0,
          'ngo': 0,
        },
      });

      expect(facets.fulfillmentHome, 13);
      expect(facets.ownershipPrivate, 11);
    });
  });

  group('Booking results', () {
    test('instant doctor booking fixture parses serial and session', () {
      final result = DoctorBookingResult.fromJson(
        fixture('doctor_booking_instant.json') as Map<String, dynamic>,
      );

      expect(result.status, BookingStatus.confirmed);
      expect(result.serialNumber, 4);
      expect(result.serialDisplay, 'SL-004');
      expect(result.estimatedTime, '18:10');
      expect(result.sessionStart, '18:00');
      expect(result.sessionEnd, '21:00');
      expect(result.facility!.displayName, isNotEmpty);
      expect(result.shortRef, '3F2A9C1E');
    });

    test('request doctor booking fixture has no serial', () {
      final result = DoctorBookingResult.fromJson(
        fixture('doctor_booking_request.json') as Map<String, dynamic>,
      );

      expect(result.status, BookingStatus.pending);
      expect(result.serialNumber, isNull);
      expect(result.confirmDeadline, isNotNull);
    });

    test('test booking fixture parses collection_type and price', () {
      final result = TestBookingResult.fromJson(
        fixture('test_booking.json') as Map<String, dynamic>,
      );

      expect(result.status, BookingStatus.pending);
      expect(result.collectionType, CollectionType.home);
      expect(result.price, 550.0);
      expect(result.testName, isNotEmpty);
    });

    test('call lead fixture parses numbers', () {
      final result = CallLeadResult.fromJson(
        fixture('call_lead.json') as Map<String, dynamic>,
      );

      expect(result.numbers, hasLength(2));
      expect(result.numbers.first.phone, isNotEmpty);
      expect(result.facility!.displayName, isNotEmpty);
    });

    test('an unknown status parses to unknown', () {
      expect(bookingStatusFromString('postponed'), BookingStatus.unknown);
      expect(bookingStatusFromString(null), BookingStatus.unknown);
      expect(bookingStatusFromString('expired'), BookingStatus.expired);
    });
  });

  group('Patient lookup', () {
    test('not-found fixture has no patient', () {
      final result = PatientLookupResult.fromJson(
        fixture('patient_lookup_not_found.json') as Map<String, dynamic>,
      );

      expect(result.found, isFalse);
      expect(result.name, isNull);
    });

    test('found fixture reads the nested patient', () {
      final result = PatientLookupResult.fromJson(
        fixture('patient_lookup_found.json') as Map<String, dynamic>,
      );

      expect(result.found, isTrue);
      expect(result.name, 'Rahim Uddin');
      expect(result.age, 34);
      expect(result.gender, 'male');
    });
  });
}
