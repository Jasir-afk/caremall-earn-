import 'package:care_mall_affiliate/app/commenwidget/app_snackbar.dart';
import 'package:care_mall_affiliate/src/modules/earning/repo/earning_repo.dart';
import 'package:care_mall_affiliate/src/modules/payout/controller/payout_repo.dart';
import 'package:care_mall_affiliate/src/modules/payout/model/payout_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PayoutController extends GetxController {
  // ── State ─────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final nextPayoutDate = ''.obs;

  /// Current page's payout list (for the scrollable list)
  final payouts = <PayoutModel>[].obs;
  final filteredPayouts = <PayoutModel>[].obs;

  /// All-records list used exclusively for deriving dashboard stats
  final _allPayouts = <PayoutModel>[];

  /// Stat card values (derived from _allPayouts)
  final summary = PayoutSummaryModel.empty().obs;

  // ── Pagination ────────────────────────────────────────────────────────────
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalRecords = 0.obs;
  static const int _pageSize = 9;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  // ── Load everything ───────────────────────────────────────────────────────
  Future<void> _loadAll() async {
    isLoading.value = true;
    errorMessage.value = '';

    // Run fetches in parallel
    await Future.wait([
      _fetchStatsData(),
      _fetchPagedList(page: 1),
      _fetchNextPayoutDate(),
    ]);

    isLoading.value = false;
  }

  /// Fetches next payout date from earnings dashboard API
  Future<void> _fetchNextPayoutDate() async {
    try {
      final result = await EarningRepo.getEarningDetails();
      if (result['success'] && result['data'] != null) {
        nextPayoutDate.value = (result['data']['nextPayoutDate'] ?? '')
            .toString();
      }
    } catch (e) {
      debugPrint('PayoutController: Error fetching next payout date: $e');
    }
  }

  /// Fetch ALL records to correctly calculate dashboard stats.
  Future<void> _fetchStatsData() async {
    final result = await PayoutRepo.getPayouts(page: 1, limit: 1000);
    if (result['success'] == true) {
      final List<dynamic> raw = result['data'] ?? [];
      _allPayouts
        ..clear()
        ..addAll(
          raw.map((e) => PayoutModel.fromJson(e as Map<String, dynamic>)),
        );
      summary.value = PayoutSummaryModel.fromList(_allPayouts);
      debugPrint(
        'PayoutController: stats loaded from ${_allPayouts.length} records. '
        'Total: ₹${summary.value.totalPayoutAmount.toStringAsFixed(0)}, '
        'Completed: ${summary.value.completedPayouts}, '
        'Pending: ${summary.value.pendingPayouts}',
      );
    }
  }

  /// Fetch a single page intended for the list UI.
  Future<void> _fetchPagedList({int page = 1}) async {
    final result = await PayoutRepo.getPayouts(
      search: searchQuery.value,
      page: page,
      limit: _pageSize,
    );

    if (result['success'] == true) {
      final List<dynamic> raw = result['data'] ?? [];

      // Parse pagination
      final pag = result['pagination'] as Map<String, dynamic>? ?? {};
      currentPage.value = (pag['page'] ?? page) as int;
      totalPages.value = (pag['totalPages'] ?? 1) as int;
      totalRecords.value = (pag['total'] ?? _allPayouts.length) as int;

      payouts.value = raw
          .map((e) => PayoutModel.fromJson(e as Map<String, dynamic>))
          .toList();

      _applyLocalFilter(searchQuery.value);
      debugPrint(
        'PayoutController: list page $page — ${payouts.length} items, '
        'totalRecords=${totalRecords.value}',
      );
    } else {
      errorMessage.value = result['message'] ?? 'Failed to fetch payouts';
      debugPrint('PayoutController error: ${errorMessage.value}');
      TcSnackbar.error('Error', errorMessage.value);
    }
  }

  // ── Computed Values ──────────────────────────────────────────────────────
  double get totalPaidThisPage {
    return payouts
        .where((p) => p.payoutStatus == 'completed' || p.payoutStatus == 'paid')
        .fold(0.0, (sum, p) => sum + p.payoutAmount);
  }

  int get pendingOrProcessingCount {
    return _allPayouts
        .where(
          (p) => p.payoutStatus == 'pending' || p.payoutStatus == 'processing',
        )
        .length;
  }

  // ── Public refresh (pull-to-refresh) ──────────────────────────────────────
  Future<void> fetchPayouts() => _loadAll();

  // ── Search / filter ───────────────────────────────────────────────────────
  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyLocalFilter(query);
  }

  void _applyLocalFilter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      filteredPayouts.assignAll(payouts);
    } else {
      filteredPayouts.assignAll(
        payouts.where(
          (p) =>
              p.id.toLowerCase().contains(q) ||
              p.affiliateId.toLowerCase().contains(q) ||
              p.payoutMethod.toLowerCase().contains(q) ||
              p.payoutStatus.toLowerCase().contains(q) ||
              p.monthYearLabel.toLowerCase().contains(q) ||
              p.remarks.toLowerCase().contains(q),
        ),
      );
    }
  }

  // ── Pagination navigation ──────────────────────────────────────────────────
  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages.value) return;
    isLoading.value = true;
    await _fetchPagedList(page: page);
    isLoading.value = false;
  }
}
