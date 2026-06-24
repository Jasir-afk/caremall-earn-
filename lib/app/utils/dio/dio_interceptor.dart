import 'dart:developer';

import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
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
      log('🔄 Session expired, logging out...');

      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().logout();
      } else {
        _storage.remove('token');
        _storage.remove('user');
      }
    } else if (err.response?.statusCode == 400) {
      log(
        '❌ Bad Request: ${err.response?.data['message'] ?? "Invalid request"}',
      );
    }

    handler.next(err);
  }
}
