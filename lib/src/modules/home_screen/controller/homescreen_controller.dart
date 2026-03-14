import 'package:care_mall_affiliate/app/commenwidget/app_snackbar.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/view/all_link_view.dart';
import 'package:care_mall_affiliate/src/modules/earning/view/earning_screen.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/model/homescreen_model.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/model/recent_order_model.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/repo/homescreen_repo.dart';
import 'package:care_mall_affiliate/src/modules/earning/repo/earning_repo.dart';
import 'package:care_mall_affiliate/src/modules/orders/controller/order_controller.dart';
import 'package:care_mall_affiliate/src/modules/orders/view/delived_order.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  final dashboardData = <DashboardDataModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final performanceSpots = <FlSpot>[].obs;
  final selectedTimeRange = 'Last 30 Days'.obs;
  // Total order amount (₹) for the selected performance range.
  final totalDelivered = 0.obs;
  // Total order amount (₹) from dashboard stats (used in Overall Performance header).
  final totalOrderAmount = 0.0.obs;
  final monthlyEarningValue = '0'.obs; // NEW
  final slabTarget = 0.0.obs; // Derived from commission slab (max sales)
  final slabMinSales = 0.0.obs; // NEW: Derived from commission slab (min sales)
  final orderStats = <String, int>{
    'pending': 0,
    'completed': 0,
    'cancelled': 0,
    'returned': 0,
  }.obs;
  final selectedOrderTimeRange = 'Last 30 Days'.obs;
  final isFirstLoad = true.obs;
  final recentOrders = <RecentOrderModel>[].obs;
  Future<void> fetchMonthlyEarning() async {
    try {
      final result = await EarningRepo.getMonthlyEarning();
      if (result['success'] && result['data'] != null) {
        monthlyEarningValue.value = (result['data']['monthlyEarning'] ?? '0')
            .toString();
      }
    } catch (e) {
      debugPrint("Error fetching monthly earning for dashboard: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  /// Called every time the home screen is pushed/resumed.
  void refreshData() {
    loadDashboardData(showLoading: dashboardData.isEmpty);
  }

  void updateTimeRange(String newRange) {
    selectedTimeRange.value = newRange;
    fetchPerformanceStats();
  }

  void updateOrderTimeRange(String newRange) {
    selectedOrderTimeRange.value = newRange;
    fetchOrderStats();
  }

  Future<void> loadDashboardData({bool showLoading = true}) async {
    // Show full-screen loader if explicitly requested or no data exists yet
    if (showLoading || dashboardData.isEmpty) {
      isLoading.value = true;
    }

    try {
      // Fetch orderStats first so fetchDashboardStats can use the correct total
      // Fetch slab target before dashboard stats so slabTarget is ready
      await fetchOrderStats();
      await fetchSlabDetails();

      // IMPORTANT: fetchDashboardStats must run BEFORE fetchPerformanceStats
      // so that thisMonthSales / totalOrderAmount are ready for the chart scale.
      await fetchDashboardStats();

      await Future.wait([
        fetchPerformanceStats(),
        fetchRecentOrders(),
        fetchMonthlyEarning(),
      ]);
      errorMessage.value = ''; // Clear error on success
    } catch (e) {
      final msg = e.toString();
      final isNetworkError =
          msg.contains('SocketException') ||
          msg.contains('Failed host lookup') ||
          msg.contains('Network error') ||
          msg.contains('ClientException');
      if (isNetworkError) {
        errorMessage.value = 'No internet connection.';
      } else {
        errorMessage.value = 'Failed to load data. Please try again.';
        TcSnackbar.error('Error', errorMessage.value);
      }
    } finally {
      isLoading.value = false;
      isFirstLoad.value = false;
    }
  }

  Future<void> fetchDashboardStats() async {
    isLoading.value = true; // Managed by loadDashboardData
    final result = await DashboardRepo.getDashboardStats();

    if (result['success'] && result['data'] != null) {
      final data = result['data'];
      debugPrint("Dashboard Stats API Data: $data");

      // Parse numeric values from API
      // Prefer slab-based target (matches Earning Panel); fall back to API value
      final double targetSales = slabTarget.value > 0
          ? slabTarget.value
          : (data['targetSales'] ?? 0).toDouble();
      final double thisMonthSales = (data['thisMonthSales'] ?? 0).toDouble();
      final int clicksThisMonth = (data['clicksThisMonth'] ?? 0).toInt();

      // Total Order card shows only delivered orders
      final int totalOrderCount = orderStats['completed'] ?? 0;
      final int clicksLastMonth = (data['clicksLastMonth'] ?? 0).toInt();
      final int thisMonthConversions = (data['thisMonthConversions'] ?? 0)
          .toInt();
      final int lastMonthConversions = (data['lastMonthConversions'] ?? 0)
          .toInt();
      final double totalRevenue =
          (data['totalSales'] ??
                  data['totalCommission'] ??
                  data['total_revenue'] ??
                  data['totalEarnings'] ??
                  data['referredAmount'] ??
                  0)
              .toDouble();
      final double lastMonthRevenue =
          (data['lastMonthRevenue'] ??
                  data['lastMonthCommission'] ??
                  data['last_month_revenue'] ??
                  0)
              .toDouble();

      // Update total order amount (₹) for use in Overall Performance header.
      // Prefer thisMonthSales (matches \"Sales This Month\" card); fall back to totalRevenue.
      totalOrderAmount.value = thisMonthSales > 0
          ? thisMonthSales
          : totalRevenue;

      // Sync KYC Status if present in dashboard data
      try {
        if (Get.isRegistered<AuthController>()) {
          final authCtrl = Get.find<AuthController>();
          final status =
              (data['kycStatus'] ?? data['kyc_status'] ?? data['status'])
                  ?.toString();
          if (status != null && status.isNotEmpty) {
            await authCtrl.saveUserData(kyc: status);
            debugPrint("DashboardController: Synced KYC Status -> $status");
          }
        }
      } catch (e) {
        debugPrint("Error syncing KYC status from dashboard: $e");
      }

      // Helper to compute percentage change string
      String pctChange(double current, double previous) {
        if (previous == 0) return current > 0 ? '+100%' : '0';
        final pct = ((current - previous) / previous * 100).round();
        if (pct == 0) return '0';
        return pct >= 0 ? '+$pct%' : '$pct%';
      }

      // Helper to determine if trend is positive
      bool isPositive(double current, double previous) => current >= previous;

      // Month target from current commission slab (same as Earning panel).
      // Default current slab is Tier 1 → target is slab maxSales (e.g. ₹30,000).
      final String monthTargetDisplay = targetSales > 0
          ? '₹${NumberFormat('#,##,###').format(targetSales.toInt())}'
          : '₹30,000';

      // Sales This Month: subtitle = amount to target (match design)
      final double remainingToTarget = targetSales > 0
          ? (targetSales - thisMonthSales).clamp(0.0, double.infinity)
          : 0.0;
      final bool targetAchieved =
          targetSales > 0 && thisMonthSales >= targetSales;
      final String salesToTargetSubtitle = targetAchieved || targetSales <= 0
          ? 'Target achieved'
          : '₹${NumberFormat('#,##,###').format(remainingToTarget.toInt())} to Target';
      final Color salesToTargetSubtitleColor = targetAchieved
          ? const Color(0xFF22C55E)
          : const Color(0xFFEF4444);
      final IconData salesToTargetSubtitleIcon = targetAchieved
          ? Icons.trending_up
          : Icons.trending_down;
      final String? salesToTargetValue = targetAchieved
          ? null
          : '₹${NumberFormat('#,##,###').format(remainingToTarget.toInt())}';
      final String? salesToTargetLabel = targetAchieved ? null : ' to Target';
      final Color salesToTargetLabelColor = const Color(0xFF64748B);

      // Map API data to DashboardDataModel
      dashboardData.value = [
        DashboardDataModel(
          title: 'Month Target',
          value: monthTargetDisplay,
          iconColor: Colors.purple[400]!,
          onTap: () => Get.to(() => const EarningScreen()),
        ),
        DashboardDataModel(
          title: 'Sales This Month',
          value: '₹${NumberFormat('#,##,###').format(thisMonthSales.toInt())}',
          subtitle: salesToTargetSubtitle,
          subtitleColor: salesToTargetSubtitleColor,
          subtitleIcon: salesToTargetSubtitleIcon,
          subtitleIconColor: salesToTargetSubtitleColor,
          subtitleValue: salesToTargetValue,
          subtitleLabel: salesToTargetLabel,
          subtitleLabelColor: salesToTargetLabelColor,
          iconColor: Colors.red[400]!,
          onTap: () => Get.to(() => const EarningScreen()),
        ),
        DashboardDataModel(
          title: 'Clicks',
          value: '$clicksThisMonth',
          trendValue: pctChange(
            clicksThisMonth.toDouble(),
            clicksLastMonth.toDouble(),
          ),
          trendLabel: 'vs last month',
          isTrendPositive: isPositive(
            clicksThisMonth.toDouble(),
            clicksLastMonth.toDouble(),
          ),
          iconColor: Colors.blue[400]!,
          onTap: () => Get.to(() => const AllLinkView()),
        ),
        DashboardDataModel(
          title: 'Total Orders',
          value: '$totalOrderCount',
          trendValue: pctChange(
            thisMonthConversions.toDouble(),
            lastMonthConversions.toDouble(),
          ),
          trendLabel: 'from last month',
          isTrendPositive: isPositive(
            thisMonthConversions.toDouble(),
            lastMonthConversions.toDouble(),
          ),
          iconColor: Colors.green[400]!,
          onTap: () {
            if (!Get.isRegistered<OrderController>()) {
              Get.put(OrderController());
            }
            Get.find<OrderController>().clearFilters();
            Get.to(() => const DeliveredOrderScreen());
          },
        ),
        DashboardDataModel(
          title: 'Total Revenue',
          value: '₹${NumberFormat('#,##,###').format(totalRevenue.toInt())}',
          trendValue: pctChange(totalRevenue, lastMonthRevenue),
          trendLabel: 'since last week',
          isTrendPositive: isPositive(totalRevenue, lastMonthRevenue),
          iconColor: Colors.orange[400]!,
          onTap: () => Get.to(() => const EarningScreen()),
        ),
      ];
    } else if (result['success'] && result['data'] == null) {
      // Handle success but null data if needed
      dashboardData.value = [];
    } else {
      TcSnackbar.error('Error', result['message']);
    }
    // isLoading.value = false; // Managed by loadDashboardData
  }

  /// Fetches the commission slab from the API and derives the month target
  /// from the current slab's maxSales — the same target shown in Earning Panel.
  Future<void> fetchSlabDetails() async {
    try {
      final result = await DashboardRepo.getSlab();
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        List<dynamic>? slabList;
        int? currentIndex;

        if (data is Map<String, dynamic>) {
          if (data['allSlabs'] is List) {
            slabList = data['allSlabs'] as List<dynamic>;
            currentIndex = data['currentSlabIndex'] as int?;
          }
        } else if (data is List && data.isNotEmpty) {
          slabList = data;
          // Fallback: find isCurrent flag
          currentIndex = slabList.indexWhere(
            (s) => (s as Map<String, dynamic>)['isCurrent'] == true,
          );
          if (currentIndex == -1) currentIndex = 0;
        }

        if (slabList != null && slabList.isNotEmpty) {
          int tierForLog = 1;
          // When no current slab yet (e.g. currentSlabIndex=-1), use nextSlab.minSales as the target (₹1).
          if (data is Map<String, dynamic> &&
              currentIndex != null &&
              currentIndex < 0 &&
              data['nextSlab'] is Map<String, dynamic>) {
            final next = data['nextSlab'] as Map<String, dynamic>;
            final double nextMin = (next['minSales'] ?? 0).toDouble();
            slabMinSales.value = 0;
            if (nextMin > 0) slabTarget.value = nextMin;
          } else {
            final idx = (currentIndex ?? 0).clamp(0, slabList.length - 1);
            tierForLog = idx + 1;
            final currentSlab = slabList[idx] as Map<String, dynamic>;
            final double maxSales = (currentSlab['maxSales'] ?? 0).toDouble();
            final double minSales = (currentSlab['minSales'] ?? 0).toDouble();
            if (maxSales > 0) slabTarget.value = maxSales;
            if (minSales >= 0) slabMinSales.value = minSales;
          }
          debugPrint(
            'DashboardController: Slab range set to ${slabMinSales.value} - ${slabTarget.value} (Tier $tierForLog)',
          );
        }
        // Default current slab is Tier 1 → use ₹30,000 if no slab target was set
        if (slabTarget.value <= 1) {
          slabTarget.value = 30000;
          slabMinSales.value = 1;
          debugPrint(
            'DashboardController: Using default Tier 1 target ${slabTarget.value}',
          );
        }
      }
    } catch (e) {
      debugPrint('DashboardController: Error fetching slab details: $e');
      if (slabTarget.value <= 0) {
        slabTarget.value = 30000;
        slabMinSales.value = 1;
      }
    }
  }

  Future<void> fetchPerformanceStats() async {
    String timeRangeValue = '30d';
    if (selectedTimeRange.value == 'Last 7 Days') {
      timeRangeValue = '7d';
    } else if (selectedTimeRange.value == 'Last 90 Days') {
      timeRangeValue = '90d';
    }

    final result = await DashboardRepo.getPerformanceStats(
      timeRange: timeRangeValue,
    );
    if (result['success']) {
      final List<dynamic> data = result['data'] ?? [];
      debugPrint("Performance Stats API Data: $data");

      // When API returns no breakdown, synthesize a smooth curve
      // based on this month's sales, so the chart is still meaningful.
      if (data.isEmpty) {
        final double thisMonthSales = totalOrderAmount.value;
        if (thisMonthSales > 0) {
          final double w1 = thisMonthSales * 0.1;
          final double w2 = thisMonthSales * 0.3;
          final double w3 = thisMonthSales * 0.6;
          final double w4 = thisMonthSales;

          performanceSpots.value = const [
            // Will be replaced below (we can't use non-const with doubles directly in const list)
          ];

          performanceSpots.value = [
            FlSpot(0, w1),
            FlSpot(1, w2),
            FlSpot(2, w3),
            FlSpot(3, w4),
          ];
          totalDelivered.value = thisMonthSales.toInt();
          return;
        }

        performanceSpots.value = [
          const FlSpot(0, 0),
          const FlSpot(1, 0),
          const FlSpot(2, 0),
          const FlSpot(3, 0),
        ];
        totalDelivered.value = 0;
        return;
      }

      // 1. Sort by date (just in case) — null-safe
      data.sort((a, b) {
        final da = (a['date'] ?? '').toString();
        final db = (b['date'] ?? '').toString();
        return da.compareTo(db);
      });

      // 2. Aggregate into exactly 4 buckets (Week 1, Week 2, Week 3, Week 4)
      List<double> bucketSums = [0, 0, 0, 0];
      int itemsPerBucket = (data.length / 4).ceil();
      if (itemsPerBucket == 0) itemsPerBucket = 1;

      int _toInt(dynamic v) {
        if (v == null) return 0;
        if (v is num) return v.toInt();
        if (v is String) {
          final cleaned = v.replaceAll(',', '').trim();
          return int.tryParse(cleaned) ?? 0;
        }
        return 0;
      }

      double total = 0;
      for (int i = 0; i < data.length; i++) {
        int bucketIndex = (i / itemsPerBucket).floor();
        if (bucketIndex > 3) bucketIndex = 3;

        final int value = _toInt(
          data[i]['deliveredAmount'] ??
              data[i]['delivered_amount'] ??
              data[i]['orderAmount'] ??
              data[i]['order_amount'] ??
              data[i]['salesAmount'] ??
              data[i]['sales_amount'] ??
              data[i]['totalRevenue'] ??
              data[i]['total_revenue'] ??
              data[i]['totalSales'] ??
              data[i]['total_sales'] ??
              data[i]['amount'] ??
              data[i]['delivered'],
        );
        bucketSums[bucketIndex] += value.toDouble();
        total += value;
      }

      // Update total delivered amount for the UI
      totalDelivered.value = total.toInt();

      // 3. Update observable with precisely 4 spots
      double scaleFactor = 1.0;
      if (total > 0 &&
          totalOrderAmount.value > 100 &&
          (totalOrderAmount.value / total) > 5) {
        // If totalOrderAmount is much larger than the sum of our spots (total),
        // then total likely reflects order COUNTS, not currency amounts.
        // Scale the spots to match totalOrderAmount proportionally.
        scaleFactor = totalOrderAmount.value / total;
        debugPrint(
          "DashboardController: Scaling performance counts by $scaleFactor to match revenue ₹${totalOrderAmount.value}",
        );
      }

      if (total <= 0 && totalOrderAmount.value > 0) {
        // Fallback: synthesize curve from this month's sales
        final double thisMonthSales = totalOrderAmount.value;
        final double w1 = thisMonthSales * 0.1;
        final double w2 = thisMonthSales * 0.3;
        final double w3 = thisMonthSales * 0.6;
        final double w4 = thisMonthSales;

        performanceSpots.value = [
          FlSpot(0, w1),
          FlSpot(1, w2),
          FlSpot(2, w3),
          FlSpot(3, w4),
        ];
        totalDelivered.value = thisMonthSales.toInt();
      } else {
        performanceSpots.value = bucketSums
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value * scaleFactor))
            .toList();
      }
    }
  }

  Future<void> fetchOrderStats() async {
    String timeRangeValue = '30d';
    if (selectedOrderTimeRange.value == 'Last 7 Days') {
      timeRangeValue = '7d';
    } else if (selectedOrderTimeRange.value == 'Last 90 Days') {
      timeRangeValue = '90d';
    }

    final result = await DashboardRepo.getPerformanceStats(
      timeRange: timeRangeValue,
    );

    if (result['success']) {
      final List<dynamic> data = result['data'] ?? [];
      debugPrint("Order Stats API Data: $data");
      int pending = 0;
      int completed = 0;
      int cancelled = 0;
      int returned = 0;

      for (var item in data) {
        // API may return either 'pending' or 'processing' for pending orders
        pending += ((item['pending'] ?? item['processing']) as num? ?? 0)
            .toInt();
        completed += (item['delivered'] as num? ?? 0).toInt();
        cancelled += (item['cancelled'] as num? ?? 0).toInt();
        returned += (item['returned'] as num? ?? 0).toInt();
      }

      orderStats.value = {
        'pending': pending,
        'completed': completed,
        'cancelled': cancelled,
        'returned': returned,
      };
    }
  }

  Future<void> fetchRecentOrders() async {
    final result = await DashboardRepo.getRecentOrders();
    if (result['success']) {
      final List<dynamic> data = result['data'] is List ? result['data'] : [];
      debugPrint("DEBUG: Recent Orders Raw Data: $data");
      recentOrders.value = data
          .where((e) => e != null && e is Map<String, dynamic>)
          .map((e) => RecentOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }
}
