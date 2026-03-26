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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(DioInterceptor());
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw DioExceptionHandler.handleException(e);
    }
  }

  Future<Response> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw DioExceptionHandler.handleException(e);
    }
  }

  Future<Response> put(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw DioExceptionHandler.handleException(e);
    }
  }

  Future<Response> patch(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw DioExceptionHandler.handleException(e);
    }
  }

  Future<Response> delete(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: body,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw DioExceptionHandler.handleException(e);
    }
  }

  Future<Response> postMultipart(
    String endpoint, {
    required Map<String, dynamic> data,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: FormData.fromMap(data),
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw DioExceptionHandler.handleException(e);
    }
  }
}
