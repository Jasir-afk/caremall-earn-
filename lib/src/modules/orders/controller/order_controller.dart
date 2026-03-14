import 'package:care_mall_affiliate/app/commenwidget/app_snackbar.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/model/recent_order_model.dart';
import 'package:care_mall_affiliate/src/modules/orders/repo/order_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final orders = <RecentOrderModel>[].obs;
  final filteredOrders = <RecentOrderModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final currentStatus = RxnString();

  // ── Pagination ────────────────────────────────────────────────────────────
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalRecords = 0.obs;
  static const int pageSize = 10;

  Future<void> fetchOrders({
    String? status,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    // If status is provided or null (to clear), update currentStatus
    currentStatus.value = status;

    // If search is provided, update searchQuery
    if (search != null) searchQuery.value = search;

    final finalStatus = currentStatus.value;
    final finalSearch = searchQuery.value;

    if (finalSearch.isEmpty) isLoading.value = true;
    final Map<String, dynamic> result;

    if (finalStatus == 'returned') {
      result = await OrderRepo.getReturnedOrders(
        search: finalSearch,
        page: page,
        limit: limit,
      );
    } else {
      final apiStatus = finalStatus == 'returned' ? null : finalStatus;
      result = await OrderRepo.getAllOrders(
        search: finalSearch,
        status: apiStatus,
        page: page,
        limit: limit,
      );
    }

    debugPrint('OrderController: Fetching orders. Filter: $finalStatus');
    if (result['success']) {
      final List<dynamic> data = result['data'] ?? [];
      debugPrint('OrderController: Found ${data.length} orders from API');
      orders.value = data
          .map((e) => RecentOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Parse pagination if present
      final pag = result['pagination'] as Map<String, dynamic>? ?? {};
      if (pag.isNotEmpty) {
        currentPage.value = (pag['page'] ?? 1) as int;
        totalPages.value = (pag['totalPages'] ?? 1) as int;
        totalRecords.value = (pag['total'] ?? data.length) as int;
      } else {
        // No pagination in response — treat as single page
        totalPages.value = 1;
        totalRecords.value = data.length;
      }

      // Local filtering fallback
      if (finalStatus != null && finalStatus.isNotEmpty) {
        filteredOrders.assignAll(
          orders.where((order) {
            final os = order.status.toLowerCase();
            final fs = finalStatus.toLowerCase();
            if (fs == 'pending') return os == 'pending' || os == 'processing';
            if (fs == 'delivered') {
              return os == 'delivered' || os == 'completed';
            }
            if (fs == 'returned' || fs == 'return') {
              return os == 'returned' ||
                  os == 'return' ||
                  os == 'approved' ||
                  os == 'rejected' ||
                  os == 'requested' ||
                  os == 'refunded' ||
                  os == 'refund' ||
                  os == 'rejected_return' ||
                  os == 'return_requested';
            }
            return os == fs;
          }),
        );
      } else {
        filteredOrders.assignAll(orders);
      }
    } else {
      debugPrint('Error fetching orders: ${result['message']}');
      TcSnackbar.error('Error', result['message']);
    }

    if (finalSearch.isEmpty) isLoading.value = false;
  }

  void searchOrders(String query) {
    searchQuery.value = query;
    // Local filtering for immediate feedback, then server search
    if (query.isEmpty) {
      filteredOrders.assignAll(orders);
    } else {
      filteredOrders.assignAll(
        orders.where(
          (order) =>
              order.productName.toLowerCase().contains(query.toLowerCase()) ||
              order.orderId.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }

    // De-bounce or just call server if depth is needed
    // For now, simplicity is better
    fetchOrders(search: query);
  }

  void clearFilters() {
    searchQuery.value = '';
    currentStatus.value = null;
  }

  // ── Pagination navigation (called from view) ──────────────────────────────
  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages.value) return;
    currentPage.value = page;
    await fetchOrders(status: currentStatus.value, page: page, limit: pageSize);
  }
}
