class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'Cannot connect to server. Please check your internet connection or verify the backend is running.'])
      : super(statusCode: 0);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Session expired. Please log in again.'])
      : super(statusCode: 401);
}

class ConflictException extends ApiException {
  ConflictException([super.message = 'Conflict: The selected time slot is already booked.'])
      : super(statusCode: 409);
}

class ValidationException extends ApiException {
  ValidationException(super.message, {super.errors})
      : super(statusCode: 400);
}
