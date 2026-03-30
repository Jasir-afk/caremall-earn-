import 'package:care_mall_affiliate/app/utils/dio/dio_client.dart';
import 'package:care_mall_affiliate/app/utils/network/api_urls.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// Repository class for authentication-related API calls
/// Follows the repository pattern to separate data layer from business logic
class AuthRepo {
  static DioClient get _dio => Get.find<DioClient>();

  /// Sends OTP to the provided phone number
  static Future<Map<String, dynamic>> sendOtp({
    required String phone,
    required String mode,
    String name = '',
    String email = '',
  }) async {
    try {
      final response = await _dio.post(
        Apiurls.sendOtp,
        body: {'phone': phone, 'mode': mode, 'name': name, 'email': email},
      );
      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP sent successfully!',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Failed to send OTP. Please try again.',
          'data': responseData,
        };
      }
    } catch (e) {
      return {'success': false, 'message': _extractErrorMessage(e)};
    }
  }

  /// Verifies the OTP entered by the user
  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        Apiurls.verifyOtp,
        body: {'phone': phone, 'otp': otp},
      );

      final responseData = response.data;
      print("Verify OTP Response: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle token potentially being nested
        String? token = responseData['token'];
        if (token == null && responseData['data'] is Map) {
          token = responseData['data']['token'];
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP verified successfully!',
          'data': responseData,
          'token': token,
          'user': responseData['user'],
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Invalid OTP. Please try again.',
          'data': responseData,
        };
      }
    } catch (e) {
      return {'success': false, 'message': _extractErrorMessage(e)};
    }
  }

  /// Deletes the user's account
  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _dio.delete(Apiurls.deleteAccount);
      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Account deleted successfully',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Failed to delete account. Please try again.',
          'data': responseData,
        };
      }
    } catch (e) {
      return {'success': false, 'message': _extractErrorMessage(e)};
    }
  }

  /// Extracts the real server error message from a DioException or String.
  /// DioClient converts DioExceptions to Strings via DioExceptionHandler,
  /// so we receive a String like "Phone number already registered."
  static String _extractErrorMessage(dynamic e) {
    // DioClient throws a String (from DioExceptionHandler.handleException)
    if (e is String) return e;
    // For DioException (if thrown directly without going through DioClient)
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        return data['message']?.toString() ??
            data['msg']?.toString() ??
            data['error']?.toString() ??
            'Something went wrong.';
      }
      return e.message ?? 'Something went wrong.';
    }
    return e.toString();
  }
}
