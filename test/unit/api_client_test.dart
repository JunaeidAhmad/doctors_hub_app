import 'package:dio/dio.dart';
import 'package:doctors_hub_app/core/app_config/app_config.dart';
import 'package:doctors_hub_app/core/network/api_client.dart';
import 'package:doctors_hub_app/core/network/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/recording_adapter.dart';

DioException badResponse(int statusCode, dynamic data) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
  );
}

void main() {
  group('ApiClient URL join', () {
    test('/doctors/ resolves under /api/v1', () async {
      final adapter = RecordingAdapter('{"count":0,"results":[]}');
      final client = ApiClient(origin: 'https://example.com');
      client.dio.httpClientAdapter = adapter;

      await client.get('/doctors/');

      expect(
        adapter.lastOptions!.uri.toString(),
        'https://example.com/api/v1/doctors/',
      );
    });

    test('app-config is fetched from the unversioned absolute URL', () {
      final client = ApiClient(origin: 'https://example.com/');
      expect(
        client.appConfigUrl,
        'https://example.com/api/app-config/',
      );
    });
  });

  group('ApiClient headers', () {
    test('sends X-App-Platform, X-App-Build and Accept-Language', () async {
      final adapter = RecordingAdapter('{"count":0,"results":[]}');
      final client = ApiClient(
        origin: 'https://example.com',
        appBuild: 42,
        platform: 'android',
      );
      client.dio.httpClientAdapter = adapter;
      client.setLocale('bn');

      await client.get('/doctors/');

      final headers = adapter.lastOptions!.headers;
      expect(headers['X-App-Platform'], 'android');
      expect(headers['X-App-Build'], 42);
      expect(headers['Accept-Language'], 'bn');
    });
  });

  group('mapDioError', () {
    late ApiClient client;

    setUp(() {
      client = ApiClient(origin: 'https://example.com');
    });

    test('reads a one-item code list and detail list', () {
      final failure = client.mapDioError(badResponse(400, {
        'code': ['request_too_late'],
        'detail': ['Too late'],
      }));

      expect(failure, isA<ValidationFailure>());
      final validation = failure as ValidationFailure;
      expect(validation.code, 'request_too_late');
      expect(validation.message, 'Too late');
      expect(validation.fieldErrors, isEmpty);
    });

    test('field errors exclude code, detail, error, message, success', () {
      final failure = client.mapDioError(badResponse(400, {
        'session_key': ['This session is fully booked.'],
        'success': false,
      }));

      final validation = failure as ValidationFailure;
      expect(validation.code, isNull);
      expect(
        validation.firstErrorFor('session_key'),
        'This session is fully booked.',
      );
      expect(validation.fieldErrors.containsKey('success'), isFalse);
    });

    test('reads the tests-search error key', () {
      final failure = client.mapDioError(badResponse(400, {
        'error': 'Invalid value',
      }));

      expect(failure.message, 'Invalid value');
    });

    test('maps 409 to a ValidationFailure with a plain-string code', () {
      final failure = client.mapDioError(badResponse(409, {
        'code': 'no_numbers',
      }));

      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).code, 'no_numbers');
    });

    test('maps 426 app_update_required and notifies the callback', () {
      UpdateRequiredFailure? notified;
      final client = ApiClient(
        origin: 'https://example.com',
        onUpdateRequired: (failure) => notified = failure,
      );

      final failure = client.mapDioError(badResponse(426, {
        'code': 'app_update_required',
        'min_supported_build': 10,
        'store_url': 'https://play.google.com/store',
        'message': {'en': 'Please update', 'bn': 'আপডেট করুন'},
      }));

      expect(failure, isA<UpdateRequiredFailure>());
      final update = failure as UpdateRequiredFailure;
      expect(update.code, 'app_update_required');
      expect(update.storeUrl, 'https://play.google.com/store');
      expect(update.messageEn, 'Please update');
      expect(update.messageBn, 'আপডেট করুন');
      expect(notified, same(update));
    });

    test('maps 426 api_version_retired and reads update.store_url', () {
      final failure = client.mapDioError(badResponse(426, {
        'code': 'api_version_retired',
        'update': {
          'min_supported_build': 5,
          'latest_build': 9,
          'store_url': 'https://apps.apple.com/app/id1',
        },
        'message': {'en': 'Retired', 'bn': 'বন্ধ'},
      }));

      final update = failure as UpdateRequiredFailure;
      expect(update.code, 'api_version_retired');
      expect(update.storeUrl, 'https://apps.apple.com/app/id1');
    });
  });

  group('AppConfigResponse', () {
    test('parses the v1 shape and an unknown status as not gated', () {
      final config = AppConfigResponse.fromJson({
        'api': {
          'current_version': 'v1',
          'supported_versions': ['v1'],
          'deprecations': {
            'v1': {'deprecated_on': null, 'sunset_on': '2027-06-01'},
          },
        },
        'platforms': {
          'android': {
            'min_supported_build': 3,
            'latest_build': 9,
            'store_url': 'https://play.google.com/store',
          },
          'ios': {
            'min_supported_build': 0,
            'latest_build': 0,
            'store_url': '',
          },
        },
        'update_message': {'en': 'Update', 'bn': 'আপডেট'},
        'client': {'platform': 'android', 'build': 1, 'status': 'new_thing'},
        'server_time': '2026-10-05T10:00:00+06:00',
      });

      expect(config.isUpdateRequired, isFalse);
      expect(config.isUpdateAvailable, isFalse);
      expect(config.clientStatus, ClientUpdateStatus.unknown);
      expect(config.deprecationFor('v1')!.hasSunset, isTrue);
      expect(config.platformBlock('android').storeUrl,
          'https://play.google.com/store');
      expect(config.platformBlock('ios').storeUrl, isEmpty);
      expect(config.updateMessage.forLocale('bn'), 'আপডেট');
    });

    test('tolerates a missing client block', () {
      final config = AppConfigResponse.fromJson({
        'api': {'current_version': 'v1', 'supported_versions': [], 'deprecations': {}},
        'platforms': {'android': {}, 'ios': {}},
        'update_message': {},
        'server_time': '',
        'client': null,
      });

      expect(config.clientStatus, ClientUpdateStatus.unknown);
      expect(config.isUpdateRequired, isFalse);
    });
  });
}
