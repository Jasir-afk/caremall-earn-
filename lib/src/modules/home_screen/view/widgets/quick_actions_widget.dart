import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/controller/link_controller.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/view/genate_links.dart';
import 'package:care_mall_affiliate/src/modules/orders/controller/order_controller.dart';
import 'package:care_mall_affiliate/src/modules/orders/view/all_order_screen.dart';
import 'package:care_mall_affiliate/src/modules/earning/view/earning_screen.dart';
import 'package:care_mall_affiliate/src/modules/payout/view/payout_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.bordercolor.withAlpha(4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.primarycolor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.blackcolor,
                  letterSpacing: -0.5,
                ),
              ),
              // const Spacer(),
              // Icon(
              //   Icons.grid_view_rounded,
              //   size: 18.sp,
              //   color: AppColors.textDefaultSecondarycolor,
              // ),
            ],
          ),
          SizedBox(height: 24.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14.w,
            crossAxisSpacing: 14.w,
            childAspectRatio: 1.2,
            children: [
              _buildDecoratedCard(
                label: 'Generate\nLink',
                icon: Icons.link_rounded,
                primaryColor: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
                onTap: () {
                  if (!Get.isRegistered<CreateLinkController>()) {
                    Get.put(CreateLinkController());
                  }
                  Get.to(() => const GenerateLinksScreen());
                },
              ),
              _buildDecoratedCard(
                label: 'View\nPayouts',
                icon: Icons.account_balance_wallet_rounded,
                primaryColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                onTap: () => Get.to(() => const PayoutView()),
              ),
              _buildDecoratedCard(
                label: 'Earning\nPanel',
                icon: Icons.auto_graph_rounded,
                primaryColor: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF5F3FF),
                onTap: () => Get.to(() => const EarningScreen()),
              ),
              _buildDecoratedCard(
                label: 'My\nOrders',
                icon: Icons.shopping_bag_rounded,
                primaryColor: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
                onTap: () {
                  if (!Get.isRegistered<OrderController>()) {
                    Get.put(OrderController());
                  }
                  Get.find<OrderController>().clearFilters();
                  Get.to(() => const OrderScreen());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecoratedCard({
    required String label,
    required IconData icon,
    required Color primaryColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: primaryColor.withAlpha(4)),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withAlpha(4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle background accent
              Positioned(
                right: -8,
                top: -8,
                child: Icon(
                  icon,
                  size: 50.sp,
                  color: primaryColor.withAlpha(4),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: primaryColor, size: 20.sp),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16.sp,
                          color: primaryColor.withAlpha(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
