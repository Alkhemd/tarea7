import 'package:dio/dio.dart';

class NetworkException implements Exception {

  NetworkException(this.message);

  factory NetworkException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timed out. Check your internet connection.',
        );
      case DioExceptionType.badResponse:
        return NetworkException._handleStatusCode(
          dioError.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled');
      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please connect and try again.',
        );
      case DioExceptionType.unknown:
        return NetworkException('Unexpected error occurred');
      case DioExceptionType.badCertificate:
        return NetworkException('Bad certificate');
    }
  }

  factory NetworkException._handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return NetworkException('Invalid request. Please check your input.');
      case 401:
        return NetworkException('Unauthorized. Please log in again.');
      case 404:
        return NetworkException('Resource not found.');
      case 500:
        return NetworkException('Server error. Please try again later.');
      default:
        return NetworkException('Error: HTTP $statusCode');
    }
  }
  final String message;

  @override
  String toString() => message;
}
