import 'package:care_mall_affiliate/app/utils/dio/dio_client.dart';
import 'package:care_mall_affiliate/app/utils/network/api_urls.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
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
        body: {
          'phone': phone,
          'mode': mode,
          'name': name,
          'email': email,
        },
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
        // Robust token extraction
        String? token;

        // 1. Check root level
        token =
            responseData['token']?.toString() ??
            responseData['accessToken']?.toString() ??
            responseData['access_token']?.toString() ??
            responseData['jwt']?.toString();

        // 2. Check within 'data' object if still null
        if (token == null && responseData['data'] is Map) {
          final data = responseData['data'] as Map;
          token =
              data['token']?.toString() ??
              data['accessToken']?.toString() ??
              data['access_token']?.toString() ??
              data['access']?.toString();
        }

        // Save token to persistent storage (SharedPreferences)
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          print("Token successfully saved to SharedPreferences: $token");

          // Also save user data if needed
          if (responseData['user'] != null) {
            await prefs.setString(
              'user_data',
              jsonEncode(responseData['user']),
            );
          } else if (responseData['data'] is Map &&
              responseData['data']['user'] != null) {
            await prefs.setString(
              'user_data',
              jsonEncode(responseData['data']['user']),
            );
          }
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP verified successfully!',
          'data': responseData,
          'token': token,
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
