import 'dart:convert';
import 'package:care_mall_affiliate/app/utils/network/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:get/get.dart';

class KycProfileRepo {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      try {
        if (Get.isRegistered<AuthController>()) {
          final authController = Get.find<AuthController>();
          if (authController.authToken.value.isNotEmpty) {
            token = authController.authToken.value;
          }
        }
      } catch (e) {
        debugPrint("KycProfileRepo: Error finding AuthController: $e");
      }
    }
    return token;
  }

  static Future<Map<String, dynamic>> getKycData() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse(Apiurls.kycupdates),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      debugPrint("KycProfileRepo: GET KYC Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data =
            responseData['kycData'] ??
            responseData['data'] ??
            responseData['profile'] ??
            responseData['user'] ??
            responseData;
        return {'success': true, 'data': data, 'full_response': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch KYC data',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse(Apiurls.kycupdates),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'email': email}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data =
            responseData['kycData'] ??
            responseData['data'] ??
            responseData['profile'] ??
            responseData['user'] ??
            responseData;
        return {
          'success': true,
          'data': data,
          'message': responseData['message'] ?? 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> getProfileData() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse(Apiurls.kycupdates),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      debugPrint("KycProfileRepo: GET PROFILE Response: ${response.body}");

      if (response.statusCode == 200) {
        final data =
            responseData['kycData'] ??
            responseData['data'] ??
            responseData['profile'] ??
            responseData['user'] ??
            responseData;
        return {'success': true, 'data': data, 'full_response': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch profile info',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> submitKycData(
    Map<String, dynamic> kycData,
  ) async {
    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse(Apiurls.kycupdates),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(kycData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'KYC submitted successfully',
          'data': responseData,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'KYC submission failed',
          'data': responseData,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
