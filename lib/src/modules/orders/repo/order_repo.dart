import 'dart:convert';
import 'package:care_mall_affiliate/app/utils/network/api_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepo {
  static Future<Map<String, dynamic>> getAllOrders({
    String search = '',
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final normalizedStatus = (status == null || status.isEmpty)
          ? 'all'
          : status.toLowerCase();

      final url = Uri.parse(Apiurls.recentOrders).replace(
        queryParameters: {
          'status': normalizedStatus, // always sent; default 'all'
          'page': page.toString(),
          'limit': limit.toString(),
          'search': search, // always sent; empty string = no filter
        },
      );

      debugPrint('OrderRepo: GET $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint(
        'OrderRepo: status=${response.statusCode} '
        'body=${response.body.substring(0, response.body.length.clamp(0, 300))}',
      );

      if (response.statusCode == 200) {
        var raw = responseData['data'];
        Map<String, dynamic>? paginationJson;

        // Handle nested paginated structure:
        // Shape A: { data: [...], pagination: {...} }
        // Shape B: { data: { data: [...], pagination: {...} } }
        if (raw is Map<String, dynamic>) {
          paginationJson = raw['pagination'] as Map<String, dynamic>?;
          raw = raw['data']; // unwrap inner list
        } else {
          paginationJson = responseData['pagination'] as Map<String, dynamic>?;
        }

        return {
          'success': true,
          'data': raw ?? [],
          'pagination': paginationJson ?? <String, dynamic>{},
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch orders',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> getReturnedOrders({
    String search = '',
    int page = 1,
    int limit = 10,
    String status = 'all',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse(Apiurls.returnOrders).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          'search': search,
          'status': status,
        },
      );

      debugPrint('OrderRepo: GET $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        var raw = responseData['data'];
        Map<String, dynamic>? paginationJson;

        if (raw is Map<String, dynamic>) {
          paginationJson = raw['pagination'] as Map<String, dynamic>?;
          raw = raw['data'];
        } else {
          paginationJson = responseData['pagination'] as Map<String, dynamic>?;
        }

        return {
          'success': true,
          'data': raw ?? [],
          'pagination': paginationJson ?? <String, dynamic>{},
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to fetch returned orders',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
