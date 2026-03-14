import 'package:care_mall_affiliate/src/modules/home_screen/model/recent_order_model.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/widgets/app_drawer.dart';
import 'package:care_mall_affiliate/src/modules/orders/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OrderScreen extends GetView<OrderController> {
  final String? status;
  const OrderScreen({super.key, this.status});
  String get _getTitle {
    if (status == null) return 'All Orders';
    if (status == 'returned') return 'Returned Orders';
    return '${status![0].toUpperCase()}${status!.substring(1)} Orders';
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<OrderController>()) {
      Get.put(OrderController());
    }
    // Fetch initial data for the specific status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchOrders(status: status);
    });
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
          "Affiliate Orders",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  onChanged: controller.searchOrders,
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15.sp,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    status == 'returned'
                        ? 'Monitor approved/completed returns that affect your commission'
                        : (status == null
                              ? 'Manage and track all your affiliate orders'
                              : 'Track your $status orders in real-time'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Orders List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.orders.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                }

                if (controller.filteredOrders.isEmpty) {
                  return Center(
                    child: Text(
                      'No orders found',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: Colors.red,
                  backgroundColor: Colors.white,
                  onRefresh: () => controller.fetchOrders(status: status),
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                    itemCount: controller.filteredOrders.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final order = controller.filteredOrders[index];
                      return GestureDetector(
                        onTap: () => _showOrderDetails(context, order),
                        child: _buildOrderCard(order),
                      );
                    },
                  ),
                );
              }),
            ),

            // ── Pagination bar ──────────────────────────────────────────
            if (!controller.isLoading.value && controller.totalPages.value > 1)
              _PaginationBar(
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages.value,
                onPrevious: () =>
                    controller.goToPage(controller.currentPage.value - 1),
                onNext: () =>
                    controller.goToPage(controller.currentPage.value + 1),
              ),
          ],
        );
      }),
    );
  }

  void _showOrderDetails(BuildContext context, RecentOrderModel order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF031633),
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F4F9)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 70.w,
                    height: 70.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFF1F4F9)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: order.productImage.isNotEmpty
                        ? Image.network(
                            order.productImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.grey[400],
                            ),
                          )
                        : Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.grey[400],
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.productName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF031633),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF031633),
                            ),
                            children: [
                              TextSpan(text: '₹${order.amount} '),
                              TextSpan(
                                text: '(${order.itemCount} items)',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailInfoCard(
                      icon: Icons.inventory_2_outlined,
                      label: 'ORDER ID',
                      value: '#${order.orderId}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailInfoCard(
                      icon: Icons.calendar_today_outlined,
                      label: 'DATE',
                      value: order.formattedDate,
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 24),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () => Navigator.pop(context),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.red,
              //       foregroundColor: Colors.white,
              //       elevation: 0,
              //       padding: EdgeInsets.symmetric(vertical: 14.h),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12.r),
              //       ),
              //     ),
              //     child: Text(
              //       'Close',
              //       style: TextStyle(
              //         fontSize: 14.sp,
              //         fontWeight: FontWeight.w700,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(RecentOrderModel order) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F4F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Placeholder/Icon
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.all(12.w),
            child: order.productImage.isNotEmpty
                ? Image.network(
                    order.productImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.shopping_bag_outlined,
                      color: const Color(0xFFCBD5E1),
                      size: 24.sp,
                    ),
                  )
                : Icon(
                    Icons.shopping_bag_outlined,
                    color: const Color(0xFFCBD5E1),
                    size: 24.sp,
                  ),
          ),

          SizedBox(width: 14.w),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        status == 'returned'
                            ? '-₹${order.amount}'
                            : 'Rs ${order.amount}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: status == 'returned'
                              ? Colors.red[600]
                              : Colors.black,
                        ),
                      ),
                      if (status != 'returned') ...[
                        SizedBox(height: 4.h),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.formattedDate,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '#${order.orderId}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    String displayLabel;
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        displayLabel = 'DELIVERED';
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'processing':
      case 'pending':
        displayLabel = 'PROCESSING';
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFEF6C00);
        break;
      case 'cancelled':
        displayLabel = 'CANCELLED';
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
      case 'return':
      case 'returned':
      case 'approved':
        displayLabel = status.toLowerCase() == 'approved'
            ? 'approved'
            : 'RETURNED';
        bgColor = const Color(0xFFF0F4FF);
        textColor = const Color(0xFF4361EE);
        break;
      case 'rejected':
        displayLabel = 'REJECTED';
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
      default:
        displayLabel = status.toString().toUpperCase();
        bgColor = Colors.grey[100]!;
        textColor = Colors.black87;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: textColor.withAlpha(4)),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          fontSize: 11.sp,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Pagination Bar ─────────────────────────────────────────────────────
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
