import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:smart_task_manager/core/network/network_exceptions.dart';

class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_createLoggingInterceptor());
  }

  late final Dio _dio;

  InterceptorsWrapper _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        log('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log('✅ RESPONSE[${response.statusCode}] => DATA: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        log(
          '❌ ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}',
        );
        return handler.next(error);
      },
    );
  }

  // GET request
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParams,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  // POST request
  Future<Response<dynamic>> post(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  // DELETE request
  Future<void> delete(String path) async {
    try {
      await _dio.delete<dynamic>(path);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}
