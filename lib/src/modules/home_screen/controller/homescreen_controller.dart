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
  final slabTarget =
      0.0.obs; // Derived from commission slab (target to reach next slab)
  final slabMinSales = 0.0.obs; // Derived from commission slab (min sales)
  final currentSlabIndex = (-1).obs;
  final currentCommissionRate = 0.0.obs;
  final nextCommissionRate = 0.0.obs;
  final currentTierName = ''.obs;
  final nextTierName = ''.obs;
  final slabTotalSales = 0.0.obs;
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
        TcSnackbar.noInternet();
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
      final double thisMonthSales =
          (data['thisMonthSales'] ??
                  (slabTotalSales.value > 0 ? slabTotalSales.value : 0))
              .toDouble();
      final int clicksThisMonth = (data['clicksThisMonth'] ?? 0).toInt();

      // Total Order card shows delivered orders
      final int totalOrderCount = orderStats['completed'] ?? 0;
      final double totalRevenue =
          (data['totalSales'] ??
                  data['totalCommission'] ??
                  data['total_revenue'] ??
                  data['totalEarnings'] ??
                  data['referredAmount'] ??
                  (slabTotalSales.value > 0 ? slabTotalSales.value : 0))
              .toDouble();

      // Update total order amount (₹) for use in Overall Performance header.
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
          }
        }
      } catch (e) {
        debugPrint("Error syncing KYC status from dashboard: $e");
      }

      // Month target from commission slab
      final String monthTargetDisplay = targetSales > 0
          ? '₹${NumberFormat('#,##,###').format(targetSales.toInt())}'
          : '₹0';

      // Sales This Month: subtitle = amount to target (match design)
      final double remainingToTarget = targetSales > 0
          ? (targetSales - thisMonthSales).clamp(0.0, double.infinity)
          : 0.0;
      final bool targetAchieved =
          targetSales > 0 && thisMonthSales >= targetSales;
      final String salesToTargetSubtitle = targetAchieved
          ? 'Target achieved'
          : (targetSales > 0
                ? '₹${NumberFormat('#,##,###').format(remainingToTarget.toInt())} to Target'
                : '');
      final Color salesToTargetSubtitleColor = targetAchieved
          ? const Color(0xFF22C55E)
          : const Color(0xFFEF4444);
      final IconData salesToTargetSubtitleIcon = targetAchieved
          ? Icons.check_circle_outline_rounded
          : Icons.track_changes_rounded;
      final String? salesToTargetValue = targetAchieved || targetSales <= 0
          ? null
          : '₹${NumberFormat('#,##,###').format(remainingToTarget.toInt())}';
      final String? salesToTargetLabel = targetAchieved || targetSales <= 0
          ? null
          : ' to Target';
      final Color salesToTargetLabelColor = const Color(0xFF64748B);

      // Map API data to DashboardDataModel matching design
      dashboardData.value = [
        DashboardDataModel(
          title: 'Monthly\nTarget',
          value: monthTargetDisplay,
          subtitle: targetAchieved ? 'Target achieved' : '',
          subtitleValue: (targetAchieved || targetSales <= 0)
              ? null
              : '₹${NumberFormat('#,##,###').format(remainingToTarget.toInt())}',
          subtitleLabel: (targetAchieved || targetSales <= 0) ? null : ' to go',
          subtitleColor: targetAchieved
              ? const Color(0xFF22C55E)
              : const Color(0xFFEF4444),
          subtitleLabelColor: const Color(0xFFEF4444),
          subtitleIcon: targetAchieved
              ? Icons.north_east_rounded
              : (targetSales > 0 ? Icons.south_east_rounded : null),
          subtitleIconColor: targetAchieved
              ? const Color(0xFF22C55E)
              : const Color(0xFFEF4444),
          iconColor: const Color(0xFFA855F7), // Purple stripe
          cardIcon: Icons.track_changes_rounded,
          cardIconColor: const Color(0xFFA855F7),
          cardIconBgColor: const Color(0xFFFAF5FF),
          onTap: () => Get.to(() => const EarningScreen()),
        ),
        DashboardDataModel(
          title: 'Sales This\nMonth',
          value: '₹${NumberFormat('#,##,###').format(thisMonthSales.toInt())}',
          subtitle: salesToTargetSubtitle,
          subtitleColor: salesToTargetSubtitleColor,
          subtitleIcon: salesToTargetSubtitleIcon,
          subtitleIconColor: salesToTargetSubtitleColor,
          subtitleValue: salesToTargetValue,
          subtitleLabel: salesToTargetLabel,
          subtitleLabelColor: salesToTargetLabelColor,
          iconColor: const Color(0xFFEF4444), // Red stripe
          cardIcon: Icons.trending_up_rounded,
          cardIconColor: const Color(0xFFEF4444),
          cardIconBgColor: const Color(0xFFFEF2F2),
          onTap: () => Get.to(() => const EarningScreen()),
        ),
        DashboardDataModel(
          title: 'Clicks',
          value: '$clicksThisMonth',
          trendValue: '$clicksThisMonth',
          trendLabel: 'vs last month',
          isTrendPositive: true,
          iconColor: const Color(0xFF3B82F6), // Blue stripe
          cardIcon: Icons.near_me_outlined,
          cardIconColor: const Color(0xFF3B82F6),
          cardIconBgColor: const Color(0xFFEFF6FF),
          onTap: () => Get.to(() => const AllLinkView()),
        ),
        DashboardDataModel(
          title: 'Total\nOrders',
          value: '$totalOrderCount',
          trendValue: '$totalOrderCount',
          trendLabel: 'from last\nmonth',
          isTrendPositive: true,
          iconColor: const Color(0xFF22C55E), // Green stripe
          cardIcon: Icons.shopping_bag_outlined,
          cardIconColor: const Color(0xFF22C55E),
          cardIconBgColor: const Color(0xFFF0FDF4),
          onTap: () {
            if (!Get.isRegistered<OrderController>()) {
              Get.put(OrderController());
            }
            Get.find<OrderController>().clearFilters();
            Get.to(() => const DeliveredOrderScreen());
          },
        ),
        DashboardDataModel(
          title: 'Total\nRevenue',
          value: '₹${NumberFormat('#,##,###').format(totalRevenue.toInt())}',
          trendValue: '0',
          trendLabel: 'since last\nweek',
          isTrendPositive: true,
          iconColor: const Color(0xFFF59E0B), // Orange stripe
          cardIcon: Icons.currency_rupee_rounded,
          cardIconColor: const Color(0xFFF59E0B),
          cardIconBgColor: const Color(0xFFFFFBEB),
          onTap: () => Get.to(() => const EarningScreen()),
        ),
      ];
    } else if (result['success'] && result['data'] == null) {
      // Handle success but null data if needed
      dashboardData.value = [];
    } else {
      final msg = result['message']?.toString() ?? '';
      final isNetworkError =
          msg.contains('SocketException') ||
          msg.contains('Failed host lookup') ||
          msg.contains('Network error') ||
          msg.contains('ClientException');

      if (isNetworkError) {
        TcSnackbar.noInternet();
      } else {
        TcSnackbar.error('Error', result['message']);
      }
    }
    // isLoading.value = false; // Managed by loadDashboardData
  }

  /// Fetches the commission slab from the API and derives the month target
  /// from the current/next slab — matching the Earning Panel.
  Future<void> fetchSlabDetails() async {
    try {
      final result = await DashboardRepo.getSlab();
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        debugPrint("DashboardController: Slab API Response Data: $data");

        if (data is Map<String, dynamic>) {
          // 1. Total Sales from slab
          final totalSalesVal = (data['totalSales'] ?? 0).toDouble();
          slabTotalSales.value = totalSalesVal;

          // 2. Current slab index & maps
          final int currentIndexVal = (data['currentSlabIndex'] as int?) ?? -1;
          currentSlabIndex.value = currentIndexVal;

          final currentSlabMap = data['currentSlab'] is Map<String, dynamic>
              ? data['currentSlab'] as Map<String, dynamic>
              : null;
          final nextSlabMap = data['nextSlab'] is Map<String, dynamic>
              ? data['nextSlab'] as Map<String, dynamic>
              : null;
          final List<dynamic>? slabList = data['allSlabs'] is List
              ? data['allSlabs'] as List<dynamic>
              : null;

          double target = 0.0;
          double minS = 0.0;
          double curComm = 0.0;
          double nextComm = 0.0;
          String curName = '';
          String nxtName = '';

          if (currentSlabMap != null && currentIndexVal >= 0) {
            curComm = (currentSlabMap['commissionPercentage'] ?? 0).toDouble();
            minS = (currentSlabMap['minSales'] ?? 0).toDouble();
            final double curMax = (currentSlabMap['maxSales'] ?? 0).toDouble();
            curName = 'Tier ${currentIndexVal + 1}';

            // Target to reach/complete current slab: prefer upper limit (maxSales), e.g. 1, 40001, 50000
            if (curMax > 0 && curMax < 999999999) {
              target = curMax;
            } else if (nextSlabMap != null) {
              final double nextMax = (nextSlabMap['maxSales'] ?? 0).toDouble();
              target = nextMax > 0
                  ? nextMax
                  : (nextSlabMap['minSales'] ?? 0).toDouble();
            } else {
              target = minS;
            }

            if (nextSlabMap != null) {
              nextComm = (nextSlabMap['commissionPercentage'] ?? 0).toDouble();
              nxtName = 'Tier ${currentIndexVal + 2}';
            } else {
              nxtName = '';
            }
          } else if (nextSlabMap != null) {
            // User has no active slab yet (Starter) -> target is upper threshold of next slab
            curComm = 0.0;
            minS = 0.0;
            curName = 'Starter';
            nextComm = (nextSlabMap['commissionPercentage'] ?? 0).toDouble();
            final double nextMin = (nextSlabMap['minSales'] ?? 0).toDouble();
            final double nextMax = (nextSlabMap['maxSales'] ?? 0).toDouble();
            nxtName = 'Tier 1';
            // Prefer opposite price / maxSales (e.g. 1, 40001, 50000), fallback to minSales
            target = nextMax > 0 ? nextMax : (nextMin > 0 ? nextMin : 0.0);
          } else if (slabList != null && slabList.isNotEmpty) {
            final first = slabList[0] as Map<String, dynamic>;
            final double firstMin = (first['minSales'] ?? 0).toDouble();
            final double firstMax = (first['maxSales'] ?? 0).toDouble();
            nextComm = (first['commissionPercentage'] ?? 0).toDouble();
            nxtName = 'Tier 1';
            curName = 'Starter';
            target = firstMax > 0 ? firstMax : (firstMin > 0 ? firstMin : 0.0);
          }

          slabTarget.value = target;
          slabMinSales.value = minS;
          currentCommissionRate.value = curComm;
          nextCommissionRate.value = nextComm;
          currentTierName.value = curName;
          nextTierName.value = nxtName;

          debugPrint(
            'DashboardController: Slab target=$target, minSales=$minS, curComm=$curComm%, nextComm=$nextComm% ($curName -> $nxtName)',
          );
        }
      }
    } catch (e) {
      debugPrint('DashboardController: Error fetching slab details: $e');
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
