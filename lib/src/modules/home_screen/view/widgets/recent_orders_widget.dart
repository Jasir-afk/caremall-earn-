import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/model/recent_order_model.dart';
import 'package:care_mall_affiliate/src/modules/orders/view/all_order_screen.dart';
import 'package:care_mall_affiliate/src/modules/orders/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RecentOrdersWidget extends StatelessWidget {
  final List<RecentOrderModel> orders;
  const RecentOrdersWidget({super.key, required this.orders});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D0D1B),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (!Get.isRegistered<OrderController>()) {
                    Get.put(OrderController());
                  }
                  Get.find<OrderController>().clearFilters();
                  Get.to(() => const OrderScreen());
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color:
                        AppColors.primarycolor, // Using red color as in image
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(4),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: AppColors.bordercolor),
          ),
          child: orders.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Text(
                      'No recent orders found',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return GestureDetector(
                      onTap: () => _showOrderDetails(context, order),
                      child: _buildOrderCard(order),
                    );
                  },
                ),
        ),
      ],
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
                  _buildPopupStatusBadge(order.status),
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
                      value: '##${order.orderId}',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupStatusBadge(String status) {
    Color bg;
    Color text;
    String displayLabel = '';

    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        bg = const Color(0xFFECFDF5);
        text = const Color(0xFF027A48);
        displayLabel = 'DELIVERED';
        break;
      case 'processing':
      case 'pending':
        bg = const Color(0xFFFFFAEB);
        text = const Color(0xFFB54708);
        displayLabel = 'PROCESSING';
        break;
      case 'cancelled':
        bg = const Color(0xFFFEF3F2);
        text = const Color(0xFFB42318);
        displayLabel = 'CANCELLED';
        break;
      case 'return':
      case 'returned':
        bg = const Color(0xFFF9F5FF);
        text = const Color(0xFF6941C6);
        displayLabel = 'RETURNED';
        break;
      default:
        bg = const Color(0xFFF9FAFB);
        text = const Color(0xFF475467);
        displayLabel = status.toString().toUpperCase();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: text.withAlpha(4)),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          fontSize: 10.sp,
          color: text,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF031633),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(RecentOrderModel order) {
    Color statusColor;
    Color statusBgColor;

    switch (order.status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        statusColor = const Color(0xFF027A48);
        statusBgColor = const Color(0xFFECFDF5);
        break;
      case 'pending':
      case 'processing':
        statusColor = const Color(0xFFB54708);
        statusBgColor = const Color(0xFFFFFAEB);
        break;
      case 'cancelled':
        statusColor = const Color(0xFFB42318);
        statusBgColor = const Color(0xFFFEF3F2);
        break;
      case 'return':
      case 'returned':
        statusColor = const Color(0xFF6941C6);
        statusBgColor = const Color(0xFFF9F5FF);
        break;
      default:
        statusColor = const Color(0xFF475467);
        statusBgColor = const Color(0xFFF9FAFB);
    }
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F4F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(8.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: order.productImage.isNotEmpty
                ? Image.network(
                    order.productImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.grey[400],
                      size: 20.sp,
                    ),
                  )
                : Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.grey[400],
                    size: 20.sp,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF031633),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  order.orderId,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '₹${order.amount}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF28C76F), // Keep green for amount
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: statusColor.withAlpha(4)),
            ),
            child: Text(
              order.status,
              style: TextStyle(
                fontSize: 11.sp,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
