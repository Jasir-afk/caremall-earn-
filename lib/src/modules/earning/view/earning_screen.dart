import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:care_mall_affiliate/src/modules/earning/controller/earning_controller.dart';
import 'package:care_mall_affiliate/src/modules/earning/model/earning_model.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EarningScreen extends StatelessWidget {
  const EarningScreen({super.key});

  String _tierCategory(int tierNumber) {
    if (tierNumber >= 1 && tierNumber <= 4) return 'Starter';
    if (tierNumber >= 5 && tierNumber <= 8) return 'Bronze';
    if (tierNumber >= 9 && tierNumber <= 12) return 'Silver';
    if (tierNumber >= 13 && tierNumber <= 16) return 'Gold';
    if (tierNumber >= 17 && tierNumber <= 18) return 'Diamond';
    return 'Platinum';
  }

  double _parseAmount(String v) {
    return double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }

  String _formatCurrencyCompact(double v) {
    final intVal = v.isFinite ? v.toInt() : 0;
    return '₹$intVal';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EarningController());

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Earning Panel',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        // actions: [
        //   Obx(() => _buildTimeRangeDropdown(controller)),
        //   SizedBox(width: 8.w),
        // ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.earningSummary.value.totalCommission == '0') {
          return const Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchEarningDetails,
          color: Colors.red,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildPartnerBadge(controller.currentBadge.value),
                // SizedBox(height: 24.h),
                _buildSummarySection(
                  controller.earningSummary.value,
                  controller.monthlyEarning.value,
                ),
                SizedBox(height: 24.h),
                // _buildMonthlyEarningSection(controller.monthlyEarning.value),
                // SizedBox(height: 32.h),
                _buildSlabSection(
                  controller.slabs,
                  controller.earningSummary.value,
                ),
                SizedBox(height: 32.h),
                _buildAllSlabsSection(controller.slabs),
                SizedBox(height: 32.h),
                _buildMonthlyBreakdownSection(
                  controller.monthlyEarning.value,
                  controller.earningSummary.value,
                  controller.slabs,
                ),
                SizedBox(height: 32.h),
                _buildPayoutStatusSection(controller.earningSummary.value),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Widget _buildPartnerBadge(PartnerBadgeModel? badge) {
  //   if (badge == null) return const SizedBox();

  //   Color badgeColor;
  //   try {
  //     String colorStr = badge.color.replaceAll('#', '').replaceAll('0x', '');
  //     if (colorStr.length == 6) colorStr = 'FF$colorStr';
  //     badgeColor = Color(int.parse(colorStr, radix: 16));
  //   } catch (e) {
  //     badgeColor = const Color(0xFF6366F1);
  //   }

  //   return Container(
  //     padding: EdgeInsets.all(16.w),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF8FAFC),
  //       borderRadius: BorderRadius.circular(16.r),
  //       border: Border.all(color: const Color(0xFFE2E8F0)),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(10.w),
  //           decoration: BoxDecoration(
  //             color: badgeColor.withOpacity(0.1),
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(Icons.stars_rounded, color: badgeColor, size: 24.sp),
  //         ),
  //         SizedBox(width: 16.w),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               badge.name,
  //               style: TextStyle(
  //                 fontSize: 16.sp,
  //                 fontWeight: FontWeight.w800,
  //                 color: const Color(0xFF031633),
  //               ),
  //             ),
  //             Text(
  //               'Current Status',
  //               style: TextStyle(
  //                 fontSize: 12.sp,
  //                 color: const Color(0xFF64748B),
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const Spacer(),
  //         Icon(
  //           Icons.chevron_right,
  //           color: const Color(0xFF94A3B8),
  //           size: 20.sp,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildTimeRangeDropdown(EarningController controller) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 12.w),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF8F9FB),
  //       borderRadius: BorderRadius.circular(8.r),
  //       border: Border.all(color: const Color(0xFFE2E8F0)),
  //     ),
  //     child: DropdownButton<String>(
  //       value: controller.selectedTimeRange.value,
  //       items: ['Last 7 Days', 'Last 30 Days', 'Last 90 Days']
  //           .map(
  //             (range) => DropdownMenuItem(
  //               value: range,
  //               child: Text(
  //                 range,
  //                 style: TextStyle(
  //                   fontSize: 12.sp,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //           )
  //           .toList(),
  //       onChanged: (val) => controller.updateTimeRange(val!),
  //       underline: const SizedBox(),
  //       icon: Icon(Icons.keyboard_arrow_down, size: 18.sp),
  //       dropdownColor: Colors.white,
  //     ),
  //   );
  // }

  Widget _buildSummarySection(
    EarningSummaryModel summary,
    MonthlyEarningModel monthly,
  ) {
    // Format period label e.g. "8 Mar - 9 Mar"
    String _fmtDate(String iso) {
      try {
        if (iso.isEmpty) return '';
        final dt = DateTime.tryParse(iso);
        if (dt == null) return iso;
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${dt.day} ${months[dt.month - 1]}';
      } catch (_) {
        return iso;
      }
    }

    final periodLabel =
        (monthly.periodStart.isNotEmpty && monthly.periodEnd.isNotEmpty)
        ? '${_fmtDate(monthly.periodStart)} - ${_fmtDate(monthly.periodEnd)}'
        : 'This Month';

    final cards = [
      _DashCardData(
        title: 'Total Earnings',
        value: '₹${summary.totalCommission}',
        subtitle: '+0.0% vs last month',
        subtitleColor: const Color(0xFF16A34A),
        subtitleIcon: Icons.north_east_rounded,
        stripeColor: const Color(0xFF22C55E),
        icon: Icons.attach_money_rounded,
        iconBg: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF16A34A),
      ),
      _DashCardData(
        title: 'Pending Payout',
        value: '₹${summary.pendingCommission}',
        subtitle: 'Available for withdrawal',
        subtitleColor: const Color(0xFF94A3B8),
        stripeColor: const Color(0xFFF97316),
        icon: Icons.trending_up_rounded,
        iconBg: const Color(0xFFFFF7ED),
        iconColor: const Color(0xFFF97316),
      ),
      _DashCardData(
        title: 'This Month Sales',
        value: '₹${summary.thisMonthSales}',
        subtitle: '${summary.conversions} conversions',
        subtitleColor: const Color(0xFF94A3B8),
        stripeColor: const Color(0xFFA855F7),
        icon: Icons.track_changes_rounded,
        iconBg: const Color(0xFFF5F3FF),
        iconColor: const Color(0xFFA855F7),
      ),
      _DashCardData(
        title: 'Monthly Earning',
        value: '₹${monthly.monthlyEarning}',
        subtitle: periodLabel,
        subtitleColor: const Color(0xFF94A3B8),
        stripeColor: const Color(0xFF3B82F6),
        icon: Icons.account_circle_outlined,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF3B82F6),
      ),
    ];

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildDashCard(cards[0])),
              SizedBox(width: 12.w),
              Expanded(child: _buildDashCard(cards[1])),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildDashCard(cards[2])),
              SizedBox(width: 12.w),
              Expanded(child: _buildDashCard(cards[3])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashCard(_DashCardData d) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left coloured stripe
          Container(width: 4.w, color: d.stripeColor),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d.title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  // Big value
                  Text(
                    d.value,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // Subtitle row
                  Row(
                    children: [
                      if (d.subtitleIcon != null) ...[
                        Icon(
                          d.subtitleIcon,
                          size: 11.sp,
                          color: d.subtitleColor,
                        ),
                        SizedBox(width: 2.w),
                      ],
                      Expanded(
                        child: Text(
                          d.subtitle,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: d.subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the accent color for a given tier number / title.
  /// This is the single source of truth for slab colour theming.
  ({Color accent, Color light, Color accentLight}) _slabColor(
    int tierNumber,
    String title,
  ) {
    final t = title.toLowerCase();
    if (t.contains('bronze') || (tierNumber >= 5 && tierNumber <= 8)) {
      return (
        accent: const Color(0xFF16A34A),
        light: const Color(0xFFDCFCE7),
        accentLight: const Color(0xFF4ADE80),
      );
    } else if (t.contains('silver') || (tierNumber >= 9 && tierNumber <= 12)) {
      return (
        accent: const Color(0xFFD97706),
        light: const Color(0xFFFEF9C3),
        accentLight: const Color(0xFFFBBF24),
      );
    } else if (t.contains('gold') || (tierNumber >= 13 && tierNumber <= 16)) {
      return (
        accent: const Color(0xFFE11D48),
        light: const Color(0xFFFFE4E6),
        accentLight: const Color(0xFFFB7185),
      );
    } else if (t.contains('diamond') ||
        (tierNumber >= 17 && tierNumber <= 18)) {
      return (
        accent: const Color(0xFF7C3AED),
        light: const Color(0xFFEDE9FE),
        accentLight: const Color(0xFFA78BFA),
      );
    } else if (t.contains('platinum') || tierNumber >= 19) {
      return (
        accent: const Color(0xFF6D28D9),
        light: const Color(0xFFEDE9FE),
        accentLight: const Color(0xFF8B5CF6),
      );
    } else {
      // Starter / default (Tiers 1-4) → blue
      return (
        accent: const Color(0xFF3B82F6),
        light: const Color(0xFFEFF6FF),
        accentLight: const Color(0xFF60A5FA),
      );
    }
  }

  Widget _buildSlabSection(List<SlabModel> slabs, EarningSummaryModel summary) {
    if (slabs.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commission Slab',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              'Slab information unavailable',
              style: TextStyle(
                color: AppColors.textDefaultSecondarycolor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    final markedCurrentIndex = slabs.indexWhere((s) => s.isCurrent);
    final effectiveCurrentIndex = markedCurrentIndex != -1
        ? markedCurrentIndex
        : 0; // If API doesn't send isCurrent/currentIndex, assume Tier 1.
    final currentSlab = slabs[effectiveCurrentIndex];
    final tierNumber = effectiveCurrentIndex + 1;
    final tierCategory = _tierCategory(tierNumber);
    final nextSlab = effectiveCurrentIndex + 1 < slabs.length
        ? slabs[effectiveCurrentIndex + 1]
        : null;

    // ── Dynamic colour for this tier ──────────────────────────────────────────
    final colors = _slabColor(tierNumber, currentSlab.title);
    final accentColor = colors.accent;
    final lightBg = colors.light;
    final accentLight = colors.accentLight;

    // Use numeric fields for progress calculation
    double progress = 0.0;
    final salesNum = _parseAmount(summary.thisMonthSales);
    final targetAmountNum = currentSlab.maxSales;
    final bool isStarterNoSales = tierNumber == 1 && salesNum <= 0;
    final displayedCommission = isStarterNoSales
        ? '0%'
        : currentSlab.commission;
    final displayedRange = isStarterNoSales ? '₹0 - ₹0' : currentSlab.range;
    final progressTargetNum = targetAmountNum > 0
        ? targetAmountNum
        : (tierNumber == 1
              ? 1.0
              : (nextSlab?.minSales ??
                    0.0)); // Starter needs ₹1 to unlock Tier 2
    final String progressSubText =
        '${_formatCurrencyCompact(salesNum)} / ${_formatCurrencyCompact(progressTargetNum)}';
    String targetAmount = progressTargetNum.toInt().toString();

    // Calculate progress using the same target shown to the user.
    if (progressTargetNum > 0) {
      progress = (salesNum / progressTargetNum).clamp(0.0, 1.0);
    } else {
      progress = 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withAlpha(20),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // ── Top accent stripe — changes colour with tier ───────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 6.h,
                color: accentColor,
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Commission Slab',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "You're in ${currentSlab.title} ($tierCategory)",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textDefaultSecondarycolor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ── Tier badge circle — gradient changes with tier ───
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 80.r,
                          height: 80.r,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentLight, accentColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withAlpha(40),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${currentSlab.title} - $displayedCommission',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeaturedInfoCard(
                            'Commission Rate',
                            displayedCommission,
                            lightBg,
                            accentColor,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildFeaturedInfoCard(
                            'Slab Range',
                            displayedRange,
                            lightBg,
                            accentColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    _buildProgressBar(
                      'Progress in ${currentSlab.title}',
                      progress,
                      progressSubText,
                      accentColor,
                    ),
                    if (nextSlab != null) ...[
                      SizedBox(height: 24.h),
                      _buildNextTierPromotion(
                        nextSlab,
                        targetAmount,
                        summary.thisMonthSales,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedInfoCard(
    String label,
    String value,
    Color bg,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    String label,
    double progress,
    String subText,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE2E8F0),
            color: color,
            minHeight: 10.h,
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            subText,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextTierPromotion(
    SlabModel nextSlab,
    String targetAmount,
    String currentSalesStr,
  ) {
    final target = nextSlab.minSales;
    final currentSales =
        double.tryParse(currentSalesStr.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0;
    final remaining = (target - currentSales).clamp(0.0, double.infinity);
    final nextTierNumberMatch = RegExp(r'(\d+)').firstMatch(nextSlab.title);
    final nextTierNumber =
        int.tryParse(nextTierNumberMatch?.group(1) ?? '') ?? 0;
    final nextTierCategory = nextTierNumber > 0
        ? _tierCategory(nextTierNumber)
        : '';
    final progressValue = target > 0
        ? (currentSales / target).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA78BFA).withAlpha(4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: const Color(0xFFA78BFA),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Next Tier',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          const TextSpan(text: 'Reach '),
                          TextSpan(
                            text: '₹${target.toInt()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const TextSpan(text: ' in sales to unlock '),
                          TextSpan(
                            text: nextSlab.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          if (nextTierCategory.isNotEmpty)
                            TextSpan(
                              text: ' ($nextTierCategory)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          const TextSpan(text: ' and earn '),
                          TextSpan(
                            text: nextSlab.commission,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                          const TextSpan(text: ' commission!'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.white,
                    color: const Color(0xFFA78BFA),
                    minHeight: 6.h,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '₹${remaining.toInt()} to go',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4C1D95),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdownSection(
    MonthlyEarningModel monthlyEarning,
    EarningSummaryModel summary,
    List<SlabModel> slabs,
  ) {
    // Determine the current commission rate to show decimal values if available
    final markedCurrentIndex = slabs.indexWhere((s) => s.isCurrent);
    final effectiveCurrentIndex = markedCurrentIndex != -1
        ? markedCurrentIndex
        : 0;
    final String commissionRateStr = slabs.isNotEmpty
        ? slabs[effectiveCurrentIndex].commission
        : '${monthlyEarning.commissionRate}%';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Breakdown',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 24.h),
          _buildBreakdownRow('Total Sales', '₹${summary.totalSales}'),
          SizedBox(height: 12.h),
          // _buildBreakdownRow(
          //   'Monthly Sales',
          //   '₹${monthlyEarning.monthlySales}',
          // ),
          // SizedBox(height: 12.h),
          _buildBreakdownRow('Commission Rate', commissionRateStr),
          SizedBox(height: 12.h),
          _buildBreakdownRow(
            'Total Earnings',
            '₹${summary.totalCommission}',
            bgColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFDCFCE7),
            valueColor: const Color(0xFF16A34A),
          ),
          SizedBox(height: 12.h),
          _buildBreakdownRow('Conversions', '${summary.conversions}'),
          SizedBox(height: 12.h),
          // _buildBreakdownRow(
          //   'Monthly Conversions',
          //   '${monthlyEarning.confirmedConversions}',
          // ),
          // SizedBox(height: 12.h),
          _buildBreakdownRow(
            'Monthly Earning',
            '₹${monthlyEarning.monthlyEarning}',
            bgColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFDBEAFE),
            valueColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutStatusSection(EarningSummaryModel summary) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payout Status',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 24.h),
          _buildBreakdownRow(
            'Pending Payout',
            '₹${summary.pendingCommission}',
            valueColor: const Color(0xFFF97316), // Orange
            bgColor: const Color(0xFFFFF7ED),
            borderColor: const Color(0xFFFFEDD5),
          ),
          SizedBox(height: 12.h),
          _buildBreakdownRow(
            'Completed Payouts',
            '₹${summary.withdrawableCommission}',
            valueColor: const Color(0xFF22C55E), // Green
            bgColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFDCFCE7),
          ),
          SizedBox(height: 12.h),
          _buildBreakdownRow(
            'Total Lifetime Earnings',
            '₹${summary.totalCommission}',
            valueColor: const Color(0xFF3B82F6), // Blue
            bgColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFDBEAFE),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE0E7FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Payout Date',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  summary.nextPayoutDate.isNotEmpty
                      ? _formatPayoutDate(summary.nextPayoutDate)
                      : 'To be announced',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF8B5CF6), // Purple
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Payouts are processed monthly',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPayoutDate(String dateStr) {
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return dateStr;
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return 'Payout in ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildBreakdownRow(
    String label,
    String value, {
    Color? valueColor,
    Color? bgColor,
    Color? borderColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: bgColor ?? const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor ?? Colors.transparent, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // ─── All Commission Slabs ───────────────────────────────────────────────────

  Widget _buildAllSlabsSection(List<SlabModel> slabs) {
    if (slabs.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'All Commission Slabs',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Compare all ${slabs.length} progressive commission tiers',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 20.h),

          // Fixed height scrollable list (approx 4 items)
          SizedBox(
            height: 480.h,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: slabs.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildSlabTileItem(slabs[index], index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlabTileItem(SlabModel slab, int tierNumber) {
    final bool isActive = slab.isCurrent;

    // Color palette based on tier category OR fallback to index ranges
    Color badgeBg;
    Color badgeText;
    String displayTitle = slab.title;
    final t = slab.title.toLowerCase();

    // If title is generic "Tier X", derive category name from index
    if (!t.contains('starter') &&
        !t.contains('bronze') &&
        !t.contains('silver') &&
        !t.contains('gold') &&
        !t.contains('diamond') &&
        !t.contains('platinum')) {
      if (tierNumber >= 1 && tierNumber <= 4) {
        displayTitle = 'Starter';
      } else if (tierNumber >= 5 && tierNumber <= 8) {
        displayTitle = 'Bronze';
      } else if (tierNumber >= 9 && tierNumber <= 12) {
        displayTitle = 'Silver';
      } else if (tierNumber >= 13 && tierNumber <= 16) {
        displayTitle = 'Gold';
      } else if (tierNumber >= 17 && tierNumber <= 18) {
        displayTitle = 'Diamond';
      } else if (tierNumber >= 19) {
        displayTitle = 'Platinum';
      }
    }

    if (t.contains('bronze') || (tierNumber >= 5 && tierNumber <= 8)) {
      badgeBg = const Color(0xFFDCFCE7); // light green
      badgeText = const Color(0xFF16A34A); // green
    } else if (t.contains('silver') || (tierNumber >= 9 && tierNumber <= 12)) {
      badgeBg = const Color(0xFFFEF9C3); // light yellow
      badgeText = const Color(0xFFD97706); // amber/orange
    } else if (t.contains('gold') || (tierNumber >= 13 && tierNumber <= 16)) {
      badgeBg = const Color(0xFFFFE4E6); // light pink
      badgeText = const Color(0xFFE11D48); // rose/red
    } else if (t.contains('diamond') ||
        (tierNumber >= 17 && tierNumber <= 18)) {
      badgeBg = const Color(0xFFEDE9FE); // light lavender
      badgeText = const Color(0xFF7C3AED); // purple
    } else if (t.contains('platinum') || (tierNumber >= 19)) {
      badgeBg = const Color(0xFFEDE9FE);
      badgeText = const Color(0xFF6D28D9); // deep purple
    } else {
      // Starter / default (Tiers 1-4) → blue
      badgeBg = const Color(0xFFEFF6FF);
      badgeText = const Color(0xFF3B82F6);
    }

    // Use the same colour helper so active tile colour matches current slab card
    final tileColors = _slabColor(tierNumber, slab.title);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [tileColors.accentLight, tileColors.accent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isActive ? null : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isActive ? tileColors.accent : const Color(0xFFE2E8F0),
          width: isActive ? 0 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: tileColors.accent.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Tier badge
          Container(
            width: 62.w,
            height: 62.w,
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withValues(alpha: 0.2) : badgeBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tier $tierNumber',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.85)
                        : badgeText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  slab.commission,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : badgeText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Sales: ${slab.range}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.8)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Active badge / checkmark
          if (isActive)
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Data class for dashboard stat cards ────────────────────────────────────
class _DashCardData {
  final String title;
  final String value;
  final String subtitle;
  final Color subtitleColor;
  final IconData? subtitleIcon;
  final Color stripeColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _DashCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
    this.subtitleIcon,
    required this.stripeColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}
