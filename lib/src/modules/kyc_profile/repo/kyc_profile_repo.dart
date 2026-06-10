import 'package:care_mall_affiliate/app/utils/dio/dio_client.dart';
import 'package:care_mall_affiliate/app/utils/network/api_urls.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:get/get.dart' hide Response, MultipartFile;

class KycProfileRepo {
  static DioClient get _dio => Get.find<DioClient>();

  static Future<Map<String, dynamic>> getKycData() async {
    try {
      final response = await _dio.get(Apiurls.kycupdates);
      final responseData = response.data;

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
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        Apiurls.kycupdates,
        body: {'name': name, 'email': email},
      );

      final responseData = response.data;

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
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getProfileData() async {
    try {
      final response = await _dio.get(Apiurls.kycupdates);
      final responseData = response.data;

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
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> submitKycData(
    Map<String, dynamic> kycData,
  ) async {
    try {
      final response = await _dio.post(Apiurls.kycupdates, body: kycData);
      final responseData = response.data;

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
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<String?> uploadImage(File file, String folder) async {
    try {
      final response = await _dio.postMultipart(
        Apiurls.uploadImage,
        data: {
          'file': await MultipartFile.fromFile(file.path, filename: 'image.jpg'),
        },
        queryParams: {'folder': folder},
      );

      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data['url'] ??
            data['path'] ??
            data['data']?['url'] ??
            data['data']?['file'] ??
            data['data']?['path'] ??
            data['filePath'];
      }
    } catch (e) {
      print("KycProfileRepo: Error uploading image: $e");
    }
    return null;
  }
}
