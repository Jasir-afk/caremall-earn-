import 'dart:developer';

import 'package:care_mall_affiliate/app/utils/network/api_urls.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';

class DioInterceptor extends Interceptor {
  final GetStorage _storage = GetStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    bool isConnected = await _checkNetwork();
    if (!isConnected) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No internet connection. Please check your network.',
        ),
      );
    }

    final token = _storage.read<String>('token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    log('📤 Request: ${options.method} ${options.uri}');
    log('☁️ Headers: ${options.headers}');
    if (options.data != null) log('📄 Body: ${options.data}');

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('✅ Response: ${response.statusCode} ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    log('❌ Error: ${err.response?.statusCode} - ${err.message}');
    if (err.response != null) {
      log('🔗 Headers: ${err.response!.headers}');
      log('📄 Response Data: ${err.response!.data}');
    }

    if (err.response?.statusCode == 401) {
      log('🔄 Token expired. Refreshing token...');
      bool success = await _refreshToken();

      if (success) {
        return handler.resolve(await _retryRequest(err.requestOptions));
      } else {
        log('🚫 Token refresh failed. Logging out...');
        if (Get.isRegistered<AuthController>()) {
          Get.find<AuthController>().logout();
        } else {
          _storage.remove('token');
          _storage.remove('user');
        }
      }
    } else if (err.response?.statusCode == 400) {
      log(
        '❌ Bad Request: ${err.response?.data['message'] ?? "Invalid request"}',
      );
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final dio = Dio();
      final refreshToken = _storage.read<String>('refresh_token');
      if (refreshToken == null) return false;

      final response = await dio.post(
        '${Apiurls.baseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['accessToken'];
        await _storage.write('token', newToken);
        log('🔑 Token refreshed.');
        return true;
      }
    } catch (e) {
      log('🚨 Token refresh error: $e');
    }
    return false;
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = Dio();
    final newToken = _storage.read<String>('token');

    if (newToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
    }

    return await dio.fetch(requestOptions);
  }

  Future<bool> _checkNetwork() async {
    final result = await Connectivity().checkConnectivity();
    return result.first != ConnectivityResult.none;
  }
}
