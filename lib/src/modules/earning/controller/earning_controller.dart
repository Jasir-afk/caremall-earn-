import 'package:care_mall_affiliate/src/modules/earning/model/earning_model.dart';
import 'package:care_mall_affiliate/src/modules/earning/repo/earning_repo.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/repo/homescreen_repo.dart';
import 'package:care_mall_affiliate/src/modules/payout/controller/payout_repo.dart';
import 'package:care_mall_affiliate/src/modules/payout/model/payout_model.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EarningController extends GetxController {
  final isLoading = true.obs;
  final earningSummary = EarningSummaryModel.empty().obs;
  final monthlyEarning = MonthlyEarningModel.empty().obs;
  final transactions = <EarningTransactionModel>[].obs;
  final slabs = <SlabModel>[
    SlabModel(
      title: 'Tier 1',
      minSales: 1,
      maxSales: 30000,
      commissionPercentage: 10,
      isCurrent: true,
    ),
    SlabModel(
      title: 'Tier 2',
      minSales: 30001,
      maxSales: 40000,
      commissionPercentage: 11,
      isCurrent: false,
    ),
    SlabModel(
      title: 'Tier 3',
      minSales: 40001,
      maxSales: 50000,
      commissionPercentage: 12,
      isCurrent: false,
    ),
    SlabModel(
      title: 'Tier 4',
      minSales: 50001,
      maxSales: 60000,
      commissionPercentage: 12.5,
      isCurrent: false,
    ),
    SlabModel(
      title: 'Tier 5',
      minSales: 60001,
      maxSales: 75000,
      commissionPercentage: 13,
      isCurrent: false,
    ),
  ].obs;
  final currentBadge = Rxn<PartnerBadgeModel>(
    PartnerBadgeModel(name: 'Starter Tier', icon: 'stars', color: '0xFF3B82F6'),
  );
  final selectedTimeRange = 'Last 30 Days'.obs;
  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  void updateTimeRange(String newRange) {
    selectedTimeRange.value = newRange;
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    // Groups that don't depend on each other's summary state
    await Future.wait([
      fetchEarningDetails(),
      fetchSlabDetails(),
      fetchDashboardClicks(),
      fetchMonthlyEarning(),
    ]);

    // Finally apply payout stats patch (to override any zeros from main API)
    await _fetchPayoutStats();

    isLoading.value = false;
  }

  /// Fetches payout stats to fix zero values on earning screen
  Future<void> _fetchPayoutStats() async {
    try {
      final result = await PayoutRepo.getPayouts(page: 1, limit: 1000);
      if (result['success'] && result['data'] != null) {
        final List<dynamic> raw = result['data'];
        final allPayouts = raw
            .map((e) => PayoutModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final stats = PayoutSummaryModel.fromList(allPayouts);

        // Patch the earningSummary with data from Payout API
        final current = earningSummary.value;
        earningSummary.value = EarningSummaryModel(
          totalCommission: stats.totalPayoutAmount.toStringAsFixed(2),
          pendingCommission: stats.pendingPayoutAmount.toStringAsFixed(2),
          withdrawableCommission: stats.completedPayoutAmount.toStringAsFixed(
            2,
          ),
          totalSales: current.totalSales,
          thisMonthSales: current.thisMonthSales,
          conversionRate: current.conversionRate,
          conversions: current.conversions,
          totalClicks: current.totalClicks,
          nextPayoutDate: current.nextPayoutDate,
        );
      }
    } catch (e) {
      debugPrint('EarningController: Error patching payout stats: $e');
    }
  }

  /// Fetches click count from /dashboard/stats (earnings API doesn't include it).
  Future<void> fetchDashboardClicks() async {
    try {
      final result = await DashboardRepo.getDashboardStats();
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        final int clicks = (data['clicksThisMonth'] ?? 0).toInt();
        // Patch clicks into the existing summary without re-fetching earnings
        final current = earningSummary.value;
        earningSummary.value = EarningSummaryModel(
          totalCommission: current.totalCommission,
          pendingCommission: current.pendingCommission,
          withdrawableCommission: current.withdrawableCommission,
          totalSales: current.totalSales,
          thisMonthSales: current.thisMonthSales,
          conversionRate: current.conversionRate,
          conversions: current.conversions,
          totalClicks: clicks,
          nextPayoutDate: current.nextPayoutDate,
        );
      }
    } catch (e) {
      debugPrint('Error fetching clicks from stats: $e');
    }
  }

  Future<void> fetchEarningDetails() async {
    String timeRangeValue = '30d';
    if (selectedTimeRange.value == 'Last 7 Days') {
      timeRangeValue = '7d';
    } else if (selectedTimeRange.value == 'Last 90 Days') {
      timeRangeValue = '90d';
    }

    try {
      final result = await EarningRepo.getEarningDetails(
        timeRange: timeRangeValue,
      );

      if (result['success']) {
        final data = result['data'];
        if (data != null) {
          earningSummary.value = EarningSummaryModel.fromJson(data);

          if (data['history'] is List) {
            final List<dynamic> history = data['history'];
            transactions.value = history
                .map(
                  (e) => EarningTransactionModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching earning details: $e');
    }
  }

  Future<void> fetchMonthlyEarning() async {
    try {
      final result = await EarningRepo.getMonthlyEarning();

      if (result['success']) {
        final data = result['data'];
        if (data != null) {
          monthlyEarning.value = MonthlyEarningModel.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching monthly earning: $e');
    }
  }

  Future<void> fetchSlabDetails() async {
    try {
      final result = await DashboardRepo.getSlab();

      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        List<SlabModel>? apiSlabs;

        if (data is Map<String, dynamic>) {
          // New response structure: allSlabs, currentSlabIndex
          if (data['allSlabs'] is List) {
            final List<dynamic> slabList = data['allSlabs'];
            int? currentIndex = data['currentSlabIndex'];
            final bool noCurrentSlab =
                (currentIndex != null && currentIndex < 0) ||
                data['currentSlab'] == null;

            if (slabList.isNotEmpty) {
              apiSlabs = [];
              if (noCurrentSlab) {
                // When backend returns currentSlabIndex=-1 & currentSlab=null,
                // show a base Starter tier (Tier 1) with 0% until user reaches ₹30,000.
                apiSlabs.add(
                  SlabModel(
                    title: 'Tier 1',
                    minSales: 0,
                    maxSales: 30000,
                    commissionPercentage: 0,
                    isCurrent: true,
                  ),
                );
                // Shift actual slabs by +1 so first real slab becomes Tier 2.
                for (int i = 0; i < slabList.length; i++) {
                  apiSlabs.add(
                    SlabModel.fromJson(
                      slabList[i] as Map<String, dynamic>,
                      index: i + 1,
                      currentIndex: null,
                    ),
                  );
                }
              } else {
                for (int i = 0; i < slabList.length; i++) {
                  apiSlabs.add(
                    SlabModel.fromJson(
                      slabList[i] as Map<String, dynamic>,
                      index: i,
                      currentIndex: currentIndex,
                    ),
                  );
                }
              }
            }
          }

          if (data['currentBadge'] != null) {
            currentBadge.value = PartnerBadgeModel.fromJson(
              data['currentBadge'],
            );
          }
        } else if (data is List && data.isNotEmpty) {
          // Fallback for old list response structure
          apiSlabs = data
              .asMap()
              .entries
              .map(
                (entry) => SlabModel.fromJson(
                  entry.value as Map<String, dynamic>,
                  index: entry.key,
                ),
              )
              .toList();
        }

        if (apiSlabs != null && apiSlabs.isNotEmpty) {
          slabs.value = apiSlabs;
        }
      }
    } catch (e) {
      debugPrint('Error fetching slab details: $e');
    }
  }
}
