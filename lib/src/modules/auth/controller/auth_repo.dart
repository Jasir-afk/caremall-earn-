import 'package:care_mall_affiliate/app/utils/dio/dio_client.dart';
import 'package:care_mall_affiliate/app/utils/network/api_urls.dart';
import 'package:get/get.dart';

/// Repository class for authentication-related API calls
/// Follows the repository pattern to separate data layer from business logic
class AuthRepo {
  static final DioClient _dio = Get.find<DioClient>();

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
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
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
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
