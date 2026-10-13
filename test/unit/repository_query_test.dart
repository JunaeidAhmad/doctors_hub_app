import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/features/doctors/data/doctor_repository.dart';
import 'package:doctors_hub_app/features/hospitals/data/hospital_repository.dart';
import 'package:doctors_hub_app/features/tests/data/test_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/recording_adapter.dart';

void main() {
  group('DoctorRepository query builder', () {
    test('sends only v1 keys and never a name filter', () async {
      final adapter = RecordingAdapter('{"count":0,"results":[]}');
      final client = ApiClient(origin: 'https://example.com');
      client.dio.httpClientAdapter = adapter;
      final repo = DoctorRepository(client);

      await repo.searchDoctors(
        search: 'heart',
        specialty: 'cardiology',
        divisionId: 1,
        districtId: 2,
        thanaId: 3,
        facilityId: 'facility-uuid',
        day: 'Sat',
        gender: 'Female',
        page: 2,
        pageSize: 20,
      );

      final params = adapter.lastOptions!.queryParameters;
      expect(
        params.keys.toSet(),
        {
          'page',
          'page_size',
          'search',
          'specialty',
          'division_id',
          'district_id',
          'thana_id',
          'facility_id',
          'day',
          'gender',
        },
      );
      expect(params['division_id'], 1);
      expect(params['facility_id'], 'facility-uuid');
      expect(params.containsKey('division'), isFalse);
      expect(params.containsKey('district'), isFalse);
      expect(params.containsKey('area'), isFalse);
      expect(params.containsKey('hospital'), isFalse);
      expect(params.containsKey('facility'), isFalse);
    });
  });

  group('HospitalRepository query builder', () {
    test('sends only v1 keys and never a name filter', () async {
      final adapter = RecordingAdapter('{"count":0,"results":[]}');
      final client = ApiClient(origin: 'https://example.com');
      client.dio.httpClientAdapter = adapter;
      final repo = HospitalRepository(client);

      await repo.getHospitals(
        category: 'general',
        divisionId: 1,
        districtId: 2,
        thanaId: 3,
        ownershipType: 'private',
        search: 'square',
        page: 1,
        pageSize: 20,
      );

      final params = adapter.lastOptions!.queryParameters;
      expect(
        params.keys.toSet(),
        {
          'page',
          'page_size',
          'category',
          'division_id',
          'district_id',
          'thana_id',
          'ownership_type',
          'search',
        },
      );
      expect(params.containsKey('division'), isFalse);
      expect(params.containsKey('district'), isFalse);
      expect(params.containsKey('area'), isFalse);
    });
  });

  group('TestRepository query builder', () {
    test('sends id filters and testcat, never a name filter', () async {
      final adapter = RecordingAdapter(
        '{"count":0,"results":[],"facets":{"fulfillment":{},"ownership":{}}}',
      );
      final client = ApiClient(origin: 'https://example.com');
      client.dio.httpClientAdapter = adapter;
      final repo = TestRepository(client);

      await repo.searchTests(
        q: 'cbc',
        testcat: 'hematology',
        divisionId: 1,
        districtId: 2,
        thanaId: 3,
        fulfillment: 'home',
        ownership: 'private',
        page: 2,
        pageSize: 80,
      );

      final params = adapter.lastOptions!.queryParameters;
      expect(
        params.keys.toSet(),
        {
          'page',
          'page_size',
          'ordering',
          'q',
          'testcat',
          'division_id',
          'district_id',
          'thana_id',
          'fulfillment',
          'ownership',
        },
      );
      expect(params['page_size'], 50);
      expect(params['testcat'], 'hematology');
      expect(params.containsKey('category'), isFalse);
      expect(params.containsKey('division'), isFalse);
    });
  });
}
