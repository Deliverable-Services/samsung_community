/// Custom exception class for application errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({required this.message, this.code, this.originalError});

  factory AppException.fromError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    return AppException(message: error.toString(), originalError: error);
  }

  factory AppException.network(String message) {
    return AppException(message: message, code: 'NETWORK_ERROR');
  }

  factory AppException.database(String message) {
    return AppException(message: message, code: 'DATABASE_ERROR');
  }

  factory AppException.auth(String message) {
    return AppException(message: message, code: 'AUTH_ERROR');
  }

  factory AppException.validation(String message) {
    return AppException(message: message, code: 'VALIDATION_ERROR');
  }

  @override
  String toString() => message;
}
