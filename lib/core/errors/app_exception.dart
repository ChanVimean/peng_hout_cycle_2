class AppException implements Exception {
  final String message;
  final int status;

  const AppException(this.message, this.status);

  @override
  String toString() => message;
  int toInt() => status;
}

class NetworkException extends AppException {
  const NetworkException()
    : super(
        'No internet connection',
        0, // ! 0 = no HTTP response
      );
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Server error, try again later',
    super.status = 500, // ! Server Error
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException()
    : super(
        'Resource not found',
        404, // ! Not Found
      );
}

/// Catch-all for other API errors (401, 422 validation, etc.)
/// carrying the server's own message.
class ApiException extends AppException {
  const ApiException(super.message, super.status);
}
