import 'package:care_mall_affiliate/app/utils/dio/dio_client.dart';
import 'package:care_mall_affiliate/app/utils/network/api_urls.dart';
import 'package:get/get.dart';

class PayoutRepo {
  /// Fetches payout list from [Apiurls.payouts] using DioClient.
  static Future<Map<String, dynamic>> getPayouts({
    String search = '',
    String? status,
    int page = 1,
    int limit = 9,
  }) async {
    try {
      final dio = Get.find<DioClient>();

      final response = await dio.get(
        Apiurls.payouts,
        queryParams: {
          'page': page,
          'limit': limit,
          if (search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

      final body = response.data as Map<String, dynamic>;

      if (response.statusCode == 200 && (body['success'] == true || body['status'] == true)) {
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
      return {'success': false, 'message': e.toString()};
    }
  }
}
