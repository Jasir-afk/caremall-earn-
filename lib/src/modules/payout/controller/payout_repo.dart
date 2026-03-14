import 'dart:convert';
import 'package:care_mall_affiliate/app/utils/network/api_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PayoutRepo {
  /// Fetches payout list from [Apiurls.payouts].
  ///
  /// Endpoint: GET /api/v1/affiliate/payouts?page=1&limit=9
  ///
  /// Actual API response shape:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": [ { "id", "amount", "status", "method", "date", ... } ],
  ///   "pagination": { "total": 0, "page": 1, "limit": 9, "totalPages": 0 }
  /// }
  /// ```
  ///
  /// Returns on success:
  /// ```dart
  /// { 'success': true, 'data': [...], 'pagination': { ... } }
  /// ```
  /// Returns on failure:
  /// ```dart
  /// { 'success': false, 'message': '...' }
  /// ```
  static Future<Map<String, dynamic>> getPayouts({
    String search = '',
    String? status,
    int page = 1,
    int limit = 9,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse(Apiurls.payouts).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

      debugPrint('PayoutRepo: GET $url');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint(
        'PayoutRepo: status=${response.statusCode} '
        'body=${response.body.substring(0, response.body.length.clamp(0, 300))}',
      );

      if (response.statusCode == 200 && body['success'] == true) {
        // List is under the "data" key; "payouts" kept as fallback
        final list = body['data'] ?? body['payouts'] ?? [];
        final pagination = body['pagination'] as Map<String, dynamic>? ?? {};

        return {'success': true, 'data': list, 'pagination': pagination};
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Failed to fetch payouts',
        };
      }
    } catch (e) {
      debugPrint('PayoutRepo error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
