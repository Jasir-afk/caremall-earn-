import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/home_screen.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/widgets/app_drawer.dart';
import 'package:care_mall_affiliate/src/modules/payout/controller/payout_controller.dart';
import 'package:care_mall_affiliate/src/modules/payout/model/payout_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ─── View ─────────────────────────────────────────────────────────────────────
class PayoutView extends StatelessWidget {
  const PayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<PayoutController>()
        ? Get.find<PayoutController>()
        : Get.put(PayoutController());

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: _buildAppBar(),
      body: Obx(() {
        return RefreshIndicator(
          color: Colors.red,
          backgroundColor: Colors.white,
          onRefresh: () => controller.fetchPayouts(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Summary stat cards (2×2 grid)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: Column(children: [_buildSummaryGrid(controller)]),
                ),
              ),

              // ── Section heading + Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payout History',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildSearchBar(controller),
                    ],
                  ),
                ),
              ),

              // ── Loading / Error / Empty / List
              if (controller.isLoading.value)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                )
              else if (controller.errorMessage.value.isNotEmpty &&
                  controller.payouts.isEmpty)
                SliverFillRemaining(
                  child: _buildErrorState(controller.errorMessage.value),
                )
              else if (controller.filteredPayouts.isEmpty)
                SliverFillRemaining(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = controller.filteredPayouts[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _PayoutCard(item: item),
                      );
                    }, childCount: controller.filteredPayouts.length),
                  ),
                ),

              // ── Pagination bar (Previous / Page X of Y / Next)
              if (!controller.isLoading.value &&
                  controller.totalPages.value > 1)
                SliverToBoxAdapter(
                  child: _PaginationBar(
                    currentPage: controller.currentPage.value,
                    totalPages: controller.totalPages.value,
                    onPrevious: () =>
                        controller.goToPage(controller.currentPage.value - 1),
                    onNext: () =>
                        controller.goToPage(controller.currentPage.value + 1),
                  ),
                ),

              // ── Bottom spacing
              SliverToBoxAdapter(child: SizedBox(height: 32.h)),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.to(() => const HomeScreen()),
        ),
      ),
      title: Text(
        'Payout Management',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(PayoutController controller) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.currency_rupee_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBg: const Color(0xFFDCFCE7).withValues(alpha: 0.6),
                label: 'Total Paid',
                value: '₹${controller.totalPaidThisPage.toStringAsFixed(0)}',
                isCompact: true,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                icon: Icons.payments_outlined,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFDBEAFE).withValues(alpha: 0.6),
                label: 'Total Records',
                value: controller.totalRecords.value.toString(),
                isCompact: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _StatCard(
          icon: Icons.access_time_filled_rounded,
          iconColor: const Color(0xFFD97706),
          iconBg: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
          label: 'Pending / Processing',
          value: controller.pendingOrProcessingCount.toString(),
        ),
      ],
    );
  }

  Widget _buildSearchBar(PayoutController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.onSearchChanged,
        style: TextStyle(fontSize: 14.sp, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search by status, method, month…',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.grey[400],
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 52, color: Colors.red),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 52,
            color: Colors.grey[300],
          ),
          SizedBox(height: 12.h),
          Text(
            'No payouts found',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Your payouts will appear here once processed.',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final bool isCompact;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16.w : 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 20.sp),
                ),
                SizedBox(height: 12.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Payout Card ─────────────────────────────────────────────────────────────
class _PayoutCard extends StatelessWidget {
  final PayoutModel item;

  const _PayoutCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.bordercolor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Top accent stripe by status colour
          Container(height: 4.h, color: _statusAccentColor(item.payoutStatus)),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Month/Year label · Status Badge
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 16.sp,
                      color: const Color(0xFF64748B),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      item.monthYearLabel,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    _StatusBadge(status: item.payoutStatus),
                  ],
                ),
                SizedBox(height: 14.h),

                // Row 2: Payout Amount (big) · Method badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payout Amount',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          item.formattedPayoutAmount,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: _statusAccentColor(item.payoutStatus),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _MethodBadge(method: item.methodLabel),
                  ],
                ),
                SizedBox(height: 14.h),

                // Divider
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                SizedBox(height: 14.h),

                // Row 3: commission + TDS info
                Row(
                  children: [
                    _InfoChip(
                      label: 'Commission',
                      value: '₹${item.commissionAmount.toStringAsFixed(2)}',
                      color: const Color(0xFF3B82F6),
                    ),
                    SizedBox(width: 10.w),
                    if (item.tdsDeduction > 0)
                      _InfoChip(
                        label: 'TDS',
                        value: '₹${item.tdsDeduction.toStringAsFixed(2)}',
                        color: const Color(0xFFF97316),
                      ),
                    if (item.commissionPercentage > 0) ...[
                      SizedBox(width: 10.w),
                      _InfoChip(
                        label: 'Rate',
                        value: '${item.commissionPercentage}%',
                        color: const Color(0xFF8B5CF6),
                      ),
                    ],
                  ],
                ),

                // Row 4: Paid date + remarks (if any)
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 13.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      item.formattedDate,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (item.remarks.isNotEmpty) ...[
                      SizedBox(width: 12.w),
                      Icon(
                        Icons.notes_rounded,
                        size: 13.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          item.remarks,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusAccentColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'received':
        return const Color(0xFF22C55E);
      case 'pending':
        return const Color(0xFFFF7B00);
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'failed':
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10.sp,
              color: color.withAlpha(200),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Method Badge ─────────────────────────────────────────────────────────────
class _MethodBadge extends StatelessWidget {
  final String method;

  const _MethodBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _methodIcon(method),
            size: 13.sp,
            color: const Color(0xFF3B82F6),
          ),
          SizedBox(width: 4.w),
          Text(
            method,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  IconData _methodIcon(String method) {
    final m = method.toLowerCase();
    if (m == 'upi') return Icons.currency_rupee_rounded;
    if (m.contains('bank') || m == 'neft' || m == 'imps') {
      return Icons.account_balance_rounded;
    }
    if (m == 'wallet') return Icons.account_balance_wallet_rounded;
    return Icons.payment_rounded;
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color textColor;
    final Color bgColor;
    final String label;
    final IconData icon;

    switch (status.toLowerCase()) {
      case 'completed':
        label = 'Completed';
        borderColor = const Color(0xFF22C55E);
        textColor = const Color(0xFF16A34A);
        bgColor = const Color(0xFFF0FDF4);
        icon = Icons.check_circle_rounded;
        break;
      case 'paid':
      case 'received':
        label = 'Paid';
        borderColor = const Color(0xFF22C55E);
        textColor = const Color(0xFF16A34A);
        bgColor = const Color(0xFFF0FDF4);
        icon = Icons.check_circle_rounded;
        break;
      case 'pending':
        label = 'Pending';
        borderColor = const Color(0xFFFF7B00);
        textColor = const Color(0xFFFF7B00);
        bgColor = const Color(0xFFFFF7ED);
        icon = Icons.hourglass_empty_rounded;
        break;
      case 'processing':
        label = 'Processing';
        borderColor = const Color(0xFF3B82F6);
        textColor = const Color(0xFF3B82F6);
        bgColor = const Color(0xFFEFF6FF);
        icon = Icons.sync_rounded;
        break;
      case 'failed':
      case 'rejected':
        label = 'Failed';
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEF2F2);
        icon = Icons.cancel_rounded;
        break;
      default:
        label = status.isNotEmpty
            ? status[0].toUpperCase() + status.substring(1)
            : 'Unknown';
        borderColor = Colors.grey;
        textColor = Colors.grey;
        bgColor = const Color(0xFFF9FAFB);
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pagination Bar ──────────────────────────────────────────────────────────
class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = currentPage <= 1;
    final isLast = currentPage >= totalPages;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PagButton(
            label: 'Previous',
            icon: Icons.chevron_left,
            iconFirst: true,
            enabled: !isFirst,
            onTap: onPrevious,
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              'Page $currentPage of $totalPages',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          _PagButton(
            label: 'Next',
            icon: Icons.chevron_right,
            iconFirst: false,
            enabled: !isLast,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _PagButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool iconFirst;
  final bool enabled;
  final VoidCallback onTap;

  const _PagButton({
    required this.label,
    required this.icon,
    required this.iconFirst,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.black87 : Colors.grey[350]!;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: enabled ? Colors.grey[300]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconFirst) ...[
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (!iconFirst) ...[
              SizedBox(width: 4.w),
              Icon(icon, size: 16.sp, color: color),
            ],
          ],
        ),
      ),
    );
  }
}
