import 'package:care_mall_affiliate/app/commenwidget/app_snackbar.dart';
import 'package:care_mall_affiliate/src/modules/intilise_screen/view/splash_screen.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DioExceptionHandler {
  static String handleException(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "⏳ Connection timeout. Please check your internet.";
        case DioExceptionType.sendTimeout:
          return "⚠️ Send timeout. Please try again.";
        case DioExceptionType.receiveTimeout:
          return "⏳ Server response timeout.";
        case DioExceptionType.badResponse:
          return _handleBadResponse(error);
        case DioExceptionType.cancel:
          return "🚫 Request cancelled.";
        case DioExceptionType.connectionError:
          return "❌ No internet connection.";
        case DioExceptionType.badCertificate:
          return "🔒 Security certificate error.";
        case DioExceptionType.unknown:
          return "⚠️ Unexpected error occurred: ${error.message ?? 'Unknown'}";
      }
    } else {
      return error.toString();
    }
  }

  static String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (statusCode == 401) {
      handleUnauthorized();
      return "🔑 Session expired. Please login again.";
    }

    String message = "Something went wrong.";

    if (data is Map) {
      message = data['message'] ?? data['msg'] ?? data['error'] ?? _messageFromStatusCode(statusCode);
      
      if (data.containsKey('errors') && data['errors'] is List) {
        final errorsList = data['errors'] as List;
        final detailedErrors = errorsList.map((e) {
          if (e is Map) {
            return e.values.join(", ");
          }
          return e.toString();
        }).join('\n');
        if (detailedErrors.isNotEmpty) {
          message = "$message\n$detailedErrors";
        }
      }
    } else if (data is String && !data.toLowerCase().contains('<html')) {
      message = data;
    } else {
      message = _messageFromStatusCode(statusCode);
    }

    return message;
  }

  static String _messageFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return "Bad request. Please check your input.";
      case 403:
        return "Forbidden. You don't have permission.";
      case 404:
        return "Resource not found.";
      case 422:
        return "Invalid data provided.";
      case 500:
        return "Internal server error. Please try later.";
      case 502:
        return "Bad gateway. Server is down.";
      case 503:
        return "Service unavailable. Please try later.";
      default:
        return "⚠️ HTTP Error $statusCode: Unknown error.";
    }
  }
}

Future<void> handleUnauthorized() async {
  final storage = GetStorage();
  await storage.remove('token');
  await storage.remove('user');
  Get.offAll(() => const SplashScreen());
  TcSnackbar.error('Session Expired', 'Please log in again.');
}
