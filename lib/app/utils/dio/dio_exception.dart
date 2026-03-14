import 'dart:developer';
import 'package:care_mall_affiliate/app/commenwidget/app_snackbar.dart';
import 'package:care_mall_affiliate/src/modules/intilise_screen/view/splash_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DioExceptionHandler {
  static String handleException(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "⏳ Connection timeout. Please try again.";
        case DioExceptionType.sendTimeout:
          return "⚠️ Request timeout. Please try again.";
        case DioExceptionType.receiveTimeout:
          return "⏳ Server response timeout.";
        case DioExceptionType.badResponse:
          return _handleBadResponse(error);
        case DioExceptionType.cancel:
          return "🚫 Request cancelled.";
        case DioExceptionType.connectionError:
          return "❌ No internet connection.";
        case DioExceptionType.unknown:
        default:
          return "⚠️ Unexpected error occurred.";
      }
    } else {
      return _handleNonDioError(error);
    }
  }

  static String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (statusCode != null && statusCode >= 400) {
      handleUnauthorized();
    }

    String message = "Unknown server error.";

    if (data is Map) {
      if (data.containsKey('message')) {
        message = data['message'];
      }

      if (data.containsKey('errors') && data['errors'] is List) {
        final errorsList = data['errors'] as List;
        final detailedErrors = errorsList
            .map(
              (e) => e.entries
                  .map((entry) => "${entry.key}: ${entry.value}")
                  .join('\n'),
            )
            .join('\n');
        message += "\n$detailedErrors";
      }
    } else if (data is String && !data.toLowerCase().contains('<html')) {
      message = data;
    } else {
      message = _messageFromStatusCode(statusCode);
    }

    return "⚠️ HTTP $statusCode: $message";
  }

  static String _messageFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return "Bad request. Please check your input.";
      case 401:
        return "Unauthorized. Please login again.";
      case 403:
        return "Forbidden. You don't have permission.";
      case 404:
        return "Resource not found.";
      case 500:
        return "Internal server error. Please try later.";
      case 503:
        return "Service unavailable. Please try later.";
      case 422:
      default:
        return "The request was well-formed but had semantic errors.";
    }
  }

  static String _handleNonDioError(dynamic error) {
    if (error is String && error.contains("HTTP")) {
      RegExp regExp = RegExp(r"HTTP \d+:\s*(.*)");
      var match = regExp.firstMatch(error);
      return match?.group(1) ?? error;
    }

    if (error is String) return error;
    log("Unexpected error: ${error.toString()}");
    return error.toString();
  }

  static Future<bool> checkNetworkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.first != ConnectivityResult.none;
  }

  static Future<String> getNetworkErrorMessage() async {
    return await checkNetworkConnectivity() ? "" : "📴 No internet connection.";
  }
}

Future<void> handleUnauthorized() async {
  await GetStorage().erase();
  Get.offAll(() => const SplashScreen());
  TcSnackbar.error('Session Expired', 'Please log in again.');
}
