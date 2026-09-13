```dart
import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';

/// Central HTTP client used by the application.
///
/// This class intentionally hides Dio from feature/domain layers.
///
/// Features should eventually communicate through this client instead
/// of creating Dio instances themselves.
///
/// IMPORTANT:
/// This client is being introduced now, but existing Supabase-based
/// data sources are NOT being replaced yet.
class ApiClient {
  ApiClient({
    Dio? dio,
  }) : _dio = dio ?? _createDio();

  final Dio _dio;

  Dio get dio => _dio;

  // ================================================================
  // GET
  // ================================================================

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  // ================================================================
  // POST
  // ================================================================

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  // ================================================================
  // PUT
  // ================================================================

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  // ================================================================
  // PATCH
  // ================================================================

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  // ================================================================
  // DELETE
  // ================================================================

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  // ================================================================
  // DIO CREATION
  // ================================================================

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.fullBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        headers: const {
          Headers.acceptHeader: Headers.jsonContentType,
        },
      ),
    );

    return dio;
  }
}
```
