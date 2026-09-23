import 'dart:io';
import 'package:dio/dio.dart';
import 'app_failure.dart';

class ApiClient {
  ApiClient({
    String? baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    final effectiveBaseUrl = baseUrl ??
        const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://doctors-hub.onrender.com/api',
        );

    _dio.options = BaseOptions(
      baseUrl: effectiveBaseUrl.endsWith('/') ? effectiveBaseUrl : '$effectiveBaseUrl/',
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

          if (statusCode == 404) {
            return const NotFoundFailure();
          }

          if (statusCode == 429) {
            return const RateLimitFailure();
          }

          if (statusCode != null && statusCode >= 400 && statusCode < 500) {
            if (data is Map<String, dynamic>) {
              final fieldErrors = <String, List<String>>{};
              String mainMessage = 'Validation error.';

              if (data.containsKey('detail') && data['detail'] is String) {
                mainMessage = data['detail'] as String;
              } else if (data.containsKey('message') && data['message'] is String) {
                mainMessage = data['message'] as String;
              }

              data.forEach((key, val) {
                if (val is List) {
                  fieldErrors[key] = val.map((e) => e.toString()).toList();
                } else if (val is String) {
                  fieldErrors[key] = [val];
                }
              });

              return ValidationFailure(
                message: mainMessage,
                fieldErrors: fieldErrors,
              );
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
