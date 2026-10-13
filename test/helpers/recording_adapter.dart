import 'dart:typed_data';

import 'package:dio/dio.dart';

/// HttpClientAdapter that records the last request and returns a canned body.
class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter(this.body, {this.statusCode = 200});

  final String body;
  final int statusCode;
  RequestOptions? lastOptions;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    requestCount++;
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
