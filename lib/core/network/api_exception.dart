import 'package:dio/dio.dart';

/// Application-level exception for API/network failures.
///
/// Feature repositories can catch this exception instead of depending
/// directly on DioException.
class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.data, this.originalException});

  final String message;
  final int? statusCode;
  final Object? data;
  final Object? originalException;

  factory ApiException.fromDioException(DioException exception) {
    final response = exception.response;

    return ApiException(
      message: _resolveMessage(exception),
      statusCode: response?.statusCode,
      data: response?.data,
      originalException: exception,
    );
  }

  static String _resolveMessage(DioException exception) {
    final responseData = exception.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final error = responseData['error'];

      if (error is String && error.trim().isNotEmpty) {
        return error;
      }
    }

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please try again.';

      case DioExceptionType.sendTimeout:
        return 'Request timed out. Please try again.';

      case DioExceptionType.receiveTimeout:
        return 'Server response timed out. Please try again.';

      case DioExceptionType.connectionError:
        return 'Unable to connect to the server. Please check your internet connection.';

      case DioExceptionType.badCertificate:
        return 'Secure connection could not be established.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.badResponse:
        return _badResponseMessage(exception.response?.statusCode);

      case DioExceptionType.transformTimeout:
        return 'Response processing timed out. Please try again.';

      case DioExceptionType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  static String _badResponseMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request.';

      case 401:
        return 'Your session has expired.';

      case 403:
        return 'You do not have permission to perform this action.';

      case 404:
        return 'The requested resource was not found.';

      case 409:
        return 'The request conflicts with existing data.';

      case 422:
        return 'Some of the submitted information is invalid.';

      case 429:
        return 'Too many requests. Please try again later.';

      case 500:
      case 502:
      case 503:
      case 504:
        return 'Server error. Please try again later.';

      default:
        return 'Request failed. Please try again.';
    }
  }

  @override
  String toString() {
    return 'ApiException('
        'message: $message, '
        'statusCode: $statusCode'
        ')';
  }
}
