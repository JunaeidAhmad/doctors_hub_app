sealed class AppFailure {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Unable to connect to the server. Please check your internet connection.']);
}

class TimeoutFailure extends AppFailure {
  const TimeoutFailure([super.message = 'The server took too long to respond. Please try again.']);
}

class ServerFailure extends AppFailure {
  const ServerFailure({
    String message = 'Server error. Please try again later.',
    this.statusCode,
  }) : super(message);

  final int? statusCode;
}

class ValidationFailure extends AppFailure {
  const ValidationFailure({
    required String message,
    this.fieldErrors = const {},
  }) : super(message);

  final Map<String, List<String>> fieldErrors;

  String? firstErrorFor(String field) => fieldErrors[field]?.firstOrNull;
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'The requested resource was not found.']);
}

class RateLimitFailure extends AppFailure {
  const RateLimitFailure([super.message = 'Too many requests. Please wait a moment and try again.']);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
