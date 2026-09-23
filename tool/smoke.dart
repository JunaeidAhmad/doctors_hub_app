// ignore_for_file: avoid_print
import 'package:dio/dio.dart';

void main() async {
  const baseUrl = 'https://doctors-hub.onrender.com/api';
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 35),
    ),
  );

  print('=== Running Live API Smoke Tests against $baseUrl ===\n');

  final endpoints = [
    '/divisions/',
    '/specialties/?canonical_only=true',
    '/doctors/?page=1&page_size=5',
    '/test-categories/?page_size=10',
    '/tests/?page=1&page_size=5',
    '/hospital-categories/',
    '/hospitals/?page=1&page_size=5',
  ];

  for (final ep in endpoints) {
    try {
      final res = await dio.get(ep);
      final dynamic data = res.data;
      int count = 0;
      if (data is List) {
        count = data.length;
      } else if (data is Map<String, dynamic>) {
        count = (data['count'] as num?)?.toInt() ?? (data['results'] as List?)?.length ?? 0;
      }
      print('✓ GET $ep -> HTTP ${res.statusCode}, count: $count');
    } catch (e) {
      print('✗ GET $ep failed: $e');
    }
  }

  print('\n=== Smoke tests completed! ===');
}
