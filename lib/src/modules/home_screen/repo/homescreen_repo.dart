import 'dart:convert';
import 'package:care_mall_affiliate/app/utils/network/api_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardRepo {
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse(Apiurls.dashboardStats),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data':
              responseData['data'], // Assuming the API returns data inside a 'data' field
          'message': responseData['message'] ?? 'Success',
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to fetch dashboard stats',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getPerformanceStats({
    String timeRange = '30d',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse(
        Apiurls.dashboardPerformance,
      ).replace(queryParameters: {'timeRange': timeRange});

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      debugPrint("Performance API Response: $responseData");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Success',
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to fetch performance stats',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getRecentOrders({int limit = 6}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse(
        Apiurls.recentOrders,
      ).replace(queryParameters: {'limit': limit.toString()});

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data':
              responseData['data'], // Assuming the list is in 'data' field or 'data.data' based on pagination
          'message': responseData['message'] ?? 'Success',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch recent orders',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getEarnings({
    String timeRange = '30d',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse(
        Apiurls.dashboardEarnings,
      ).replace(queryParameters: {'time_range': timeRange});

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Success',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch earnings',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getSlab() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse(Apiurls.dashboardSlab);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'] ?? 'Success',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch slab data',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
