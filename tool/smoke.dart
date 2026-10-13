// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

const origin = 'https://doctors-hub.onrender.com';

void main(List<String> args) async {
  if (args.contains('--record')) {
    await recordFixtures();
    return;
  }

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 35),
      headers: {
        'Accept': 'application/json',
        'X-App-Platform': 'android',
        'X-App-Build': 1,
      },
    ),
  );

  print('=== Running Live API Smoke Tests (v1) against $origin ===\n');

  await hit(dio, '$origin/api/app-config/');

  final endpoints = <String>[
    '/search-metadata/',
    '/search-facets/',
    '/divisions/',
    '/districts/',
    '/thanas/',
    '/specialties/',
    '/specialties/suggest/?q=cardio',
    '/doctors/?page_size=5',
    '/hospital-categories/',
    '/diagnostic-center-categories/',
    '/hospitals/?page_size=5',
    '/diagnostic-centers/?page_size=5',
    '/test-categories/',
    '/facility-tests/search/?page_size=5',
    '/hospital-services/',
  ];

  int? firstDoctorOk;
  for (final ep in endpoints) {
    final ok = await hit(dio, '$origin/api/v1$ep');
    if (ep.startsWith('/doctors/') && ok != null) {
      firstDoctorOk ??= ok;
    }
  }

  // First doctor detail, then the first chamber's availability.
  final doctorSlug = await firstDoctorSlug(dio);
  if (doctorSlug != null) {
    final detail = await dio.get<Map<String, dynamic>>(
      '$origin/api/v1/doctors/$doctorSlug/',
    );
    print('✓ GET /api/v1/doctors/$doctorSlug/ -> HTTP ${detail.statusCode}');
    final data = detail.data;
    final chambers = data?['chambers'];
    String? chamberId;
    if (chambers is List && chambers.isNotEmpty && chambers.first is Map) {
      final id = (chambers.first as Map)['id'];
      if (id is String) chamberId = id;
    }
    if (chamberId != null) {
      await hit(
        dio,
        '$origin/api/v1/affiliations/$chamberId/availability/?days=7',
      );
    } else {
      print('✗ No chamber id on the first doctor, skipping availability');
    }
  } else {
    print('✗ No doctor found, skipping detail and availability');
  }

  print('\n=== Smoke tests completed! ===');
}

Future<int?> hit(Dio dio, String url) async {
  try {
    final res = await dio.get<dynamic>(url);
    final dynamic data = res.data;
    int count = 0;
    if (data is List) {
      count = data.length;
    } else if (data is Map<String, dynamic>) {
      count = (data['count'] as num?)?.toInt() ??
          (data['results'] as List?)?.length ??
          0;
    }
    print('✓ GET ${_short(url)} -> HTTP ${res.statusCode}, count: $count');
    return count;
  } catch (e) {
    print('✗ GET ${_short(url)} failed: $e');
    return null;
  }
}

Future<String?> firstDoctorSlug(Dio dio) async {
  try {
    final res = await dio.get<dynamic>('$origin/api/v1/doctors/?page_size=1');
    final data = res.data;
    if (data is Map<String, dynamic> && data['results'] is List) {
      final results = data['results'] as List;
      if (results.isNotEmpty && results.first is Map) {
        final slug = (results.first as Map)['slug'];
        if (slug is String && slug.isNotEmpty) return slug;
        final id = (results.first as Map)['id'];
        if (id is String && id.isNotEmpty) return id;
      }
    }
  } catch (e) {
    print('✗ GET /api/v1/doctors/?page_size=1 failed: $e');
  }
  return null;
}

String _short(String url) => url.replaceFirst(origin, '');

/// `dart run tool/smoke.dart --record`
///
/// Saves trimmed real GET responses to `test/fixtures/v1/`. Never records a
/// booking: the booking fixtures are hand-written from `openapi.v1.json`.
Future<void> recordFixtures() async {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 35),
      headers: {
        'Accept': 'application/json',
        'X-App-Platform': 'android',
        'X-App-Build': 1,
      },
    ),
  );
  final dir = Directory('test/fixtures/v1');
  await dir.create(recursive: true);

  Future<dynamic> getJson(String url) async {
    final res = await dio.get<dynamic>(url);
    return res.data;
  }

  Future<void> save(String name, dynamic data) async {
    final file = File('${dir.path}/$name');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
    print('recorded ${file.path}');
  }

  final doctorsPage = await getJson('$origin/api/v1/doctors/?page_size=50');
  if (doctorsPage is! Map<String, dynamic>) {
    print('No doctors page recorded');
    return;
  }
  final results = (doctorsPage['results'] as List?) ?? [];
  await save('doctors_list.json', {
    'count': doctorsPage['count'],
    'next': doctorsPage['next'],
    'previous': doctorsPage['previous'],
    'results': results.take(3).toList(),
  });

  Map<String, dynamic>? chosen;
  for (final item in results) {
    if (item is Map &&
        item['chambers'] is List &&
        (item['chambers'] as List).length >= 2) {
      chosen = Map<String, dynamic>.from(item);
      break;
    }
  }
  chosen ??= results.isNotEmpty && results.first is Map
      ? Map<String, dynamic>.from(results.first as Map)
      : null;
  if (chosen == null) {
    print('No doctor detail recorded');
    return;
  }

  final slug = chosen['slug'] as String? ?? chosen['id'] as String?;
  final detail = await getJson('$origin/api/v1/doctors/$slug/');
  await save('doctor_detail.json', detail);

  final chambers =
      detail is Map && detail['chambers'] is List ? detail['chambers'] as List : [];
  if (chambers.isNotEmpty && chambers.first is Map) {
    final chamberId = (chambers.first as Map)['id'];
    if (chamberId is String) {
      final availability = await getJson(
        '$origin/api/v1/affiliations/$chamberId/availability/?days=7',
      );
      await save('availability.json', availability);
    }
  }

  final hospitals = await getJson('$origin/api/v1/hospitals/?page_size=3');
  await save('hospitals.json', hospitals);

  final testSearch =
      await getJson('$origin/api/v1/facility-tests/search/?page_size=3');
  await save('facility_tests_search.json', testSearch);

  final lookup = await getJson(
    '$origin/api/v1/bookings/patients/lookup/?phone=01700000001',
  );
  await save('patient_lookup_not_found.json', lookup);

  print('\nFixtures recorded in ${dir.path}');
}
