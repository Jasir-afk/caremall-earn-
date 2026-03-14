import 'package:care_mall_affiliate/app/utils/network/api_urls.dart';
import 'package:dio/dio.dart';

import 'dio_exception.dart';
import 'dio_interceptor.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Apiurls.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (_) => true,
      ),
    );

    _dio.interceptors.add(DioInterceptor());
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: options ?? Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      throw DioExceptionHandler.handleException(e);
    }
  }

  Future<Response> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      throw DioExceptionHandler.handleException(e);
    }
  }

  Future<Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      throw DioExceptionHandler.handleException(e);
    }
  }

  Future<Response> patch(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      throw DioExceptionHandler.handleException(e);
    }
  }

  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      throw DioExceptionHandler.handleException(e);
    }
  }

  Response _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 500) {
      return response;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
