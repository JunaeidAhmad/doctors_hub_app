import 'dart:io';
import 'package:dio/dio.dart';
import 'app_failure.dart';

class ApiClient {
  ApiClient({
    String? origin,
    Dio? dio,
    this.appBuild,
    this.platform,
    this.onUpdateRequired,
  }) : _dio = dio ?? Dio() {
    final rawOrigin = origin ??
        const String.fromEnvironment(
          'API_ORIGIN',
          defaultValue: 'https://doctors-hub.onrender.com',
        );
    _origin = rawOrigin.endsWith('/')
        ? rawOrigin.substring(0, rawOrigin.length - 1)
        : rawOrigin;

    _dio.options = BaseOptions(
      baseUrl: '$_origin/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (platform != null && platform!.isNotEmpty) {
            options.headers['X-App-Platform'] = platform;
          }
          if (appBuild != null) {
            options.headers['X-App-Build'] = appBuild;
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Retry once on GET timeout
          final req = error.requestOptions;
          final isGet = req.method.toUpperCase() == 'GET';
          final isTimeout = error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout;

          final retried = req.extra['retried'] == true;

          if (isGet && isTimeout && !retried) {
            req.extra['retried'] = true;
            try {
              final response = await _dio.fetch(req);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  Dio get dio => _dio;

  late final String _origin;
  String get origin => _origin;

  final int? appBuild;
  final String? platform;

  final void Function(UpdateRequiredFailure failure)? onUpdateRequired;

  String get appConfigUrl => '$_origin/api/app-config/';

  void setLocale(String languageCode) {
    _dio.options.headers['Accept-Language'] = languageCode;
  }

  AppFailure mapDioError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return const TimeoutFailure();

        case DioExceptionType.connectionError:
          return const NetworkFailure();

        case DioExceptionType.badResponse:
          final response = error.response;
          final statusCode = response?.statusCode;
          final data = response?.data;
          final body = data is Map ? Map<String, dynamic>.from(data) : null;

          if (statusCode == 426) {
            final failure = _parseUpdateRequired(body);
            onUpdateRequired?.call(failure);
            return failure;
          }

          if (statusCode == 404) {
            return const NotFoundFailure();
          }

          if (statusCode == 429) {
            return const RateLimitFailure();
          }

          if (statusCode != null && statusCode >= 400 && statusCode < 500) {
            if (body != null) {
              return _parseValidationFailure(body);
            }
          }

          return ServerFailure(
            message: 'Server returned error ($statusCode)',
            statusCode: statusCode,
          );

        default:
          if (error.error is SocketException) {
            return const NetworkFailure();
          }
          return UnknownFailure(error.message ?? 'Unknown network error');
      }
    }

    if (error is AppFailure) {
      return error;
    }

    return UnknownFailure(error.toString());
  }

  ValidationFailure _parseValidationFailure(Map<String, dynamic> data) {
    final code = _readScalar(data['code']);
    final detail = _readScalar(data['detail']);
    final errorText = _readScalar(data['error']);
    final messageText = _readScalar(data['message']);

    const reservedKeys = {'code', 'detail', 'error', 'message', 'success'};
    final fieldErrors = <String, List<String>>{};
    data.forEach((key, value) {
      if (reservedKeys.contains(key)) return;
      final values = _readStringList(value);
      if (values != null && values.isNotEmpty) {
        fieldErrors[key] = values;
      }
    });

    return ValidationFailure(
      message: detail ?? errorText ?? messageText ?? 'Validation error.',
      code: code,
      fieldErrors: fieldErrors,
    );
  }

  UpdateRequiredFailure _parseUpdateRequired(Map<String, dynamic>? data) {
    final rawCode = data?['code'];
    final code = rawCode is String && rawCode.isNotEmpty ? rawCode : 'unknown';

    String? storeUrl;
    final topLevelUrl = data?['store_url'];
    if (topLevelUrl is String && topLevelUrl.isNotEmpty) {
      storeUrl = topLevelUrl;
    } else {
      final update = data?['update'];
      if (update is Map) {
        final updateUrl = update['store_url'];
        if (updateUrl is String && updateUrl.isNotEmpty) {
          storeUrl = updateUrl;
        }
      }
    }

    String? messageEn;
    String? messageBn;
    final message = data?['message'];
    if (message is Map) {
      final en = message['en'];
      final bn = message['bn'];
      if (en is String && en.isNotEmpty) messageEn = en;
      if (bn is String && bn.isNotEmpty) messageBn = bn;
    }

    return UpdateRequiredFailure(
      code: code,
      storeUrl: storeUrl,
      messageEn: messageEn,
      messageBn: messageBn,
      message: messageEn ?? 'Please update the app to continue.',
    );
  }

  static String? _readScalar(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    if (value is List && value.isNotEmpty && value.first is String) {
      return value.first as String;
    }
    return null;
  }

  static List<String>? _readStringList(dynamic value) {
    if (value is String) return [value];
    if (value is List) {
      final strings = value.whereType<String>().toList();
      return strings.isEmpty ? null : strings;
    }
    return null;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw mapDioError(e);
    }
  }
}
