import 'package:care_mall_affiliate/app/commenwidget/apptext.dart';
import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/controller/link_controller.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/model/link_model.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AllLinkView extends GetView<CreateLinkController> {
  const AllLinkView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateLinkController>()) {
      Get.put(CreateLinkController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        // title: SizedBox(
        //   height: 30,
        //   child: Assets.images.logo.image(fit: BoxFit.fitHeight),
        // ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications_outlined, color: Colors.black),
        //     onPressed: () {},
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.person_outline, color: Colors.black),
        //     onPressed: () {},
        //   ),
        //   SizedBox(width: 8.w),
        // ],
        title: AppText(
          text: 'Product Links',
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: controller.loadData,
                color: AppColors.primarycolor,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      SizedBox(height: 20.h),
                      _buildStatsGrid(),
                      SizedBox(height: 24.h),
                      _buildSearchBar(),
                      SizedBox(height: 24.h),
                      _buildGeneratedProductList(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
              if (controller.isLoading.value)
                Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  // child: const Center(
                  //   child: CircularProgressIndicator(color: Colors.red),
                  // ),
                ),
              if (controller.isGenerating.value)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Generating Link...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Clicks',
                  value: controller.clicks.value,
                  dotColor: Colors.red,
                  subtitle: '+22 from last month',
                  subtitleColor: const Color(0xFF3B82F6),
                  showTrend: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  label: 'Active Links',
                  value: controller.activeLinks.value,
                  dotColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Total Orders',
                  value: controller.totalOrders.value,
                  dotColor: Colors.deepPurple,
                  subtitle: '+2% than last month',
                  subtitleColor: const Color(0xFF8B5CF6),
                  showTrend: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  label: 'Total Commissions',
                  value: '₹${controller.totalCommissions.value}',
                  dotColor: Colors.purple,
                  subtitle: '+25% than last week',
                  subtitleColor: const Color(0xFFD97706),
                  showTrend: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color dotColor,
    String? subtitle,
    Color? subtitleColor,
    bool showTrend = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.bordercolor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: AppText(
                  text: label,
                  fontSize: 14.sp,
                  color: Colors.grey[600]!,
                  fontWeight: FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          AppText(text: value, fontSize: 18.sp, fontWeight: FontWeight.bold),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                if (showTrend) ...[
                  Icon(
                    Icons.trending_up,
                    size: 12.sp,
                    color: subtitleColor ?? Colors.blue,
                  ),
                  SizedBox(width: 4.w),
                ],
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: subtitleColor ?? Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.bordercolor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          onChanged: controller.searchProducts,
          decoration: InputDecoration(
            hintText: 'Search Products',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedProductList() {
    final products = controller.paginatedProducts;
    if (products.isEmpty && !controller.isLoading.value) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: AppText(text: 'No product links found'),
        ),
      );
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        ),
        if (controller.generatedFilteredProducts.length >
            controller.itemsPerPage) ...[
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPaginationButton(
                  icon: Icons.keyboard_arrow_left,
                  label: 'Previous',
                  onPressed: controller.currentPage.value > 1
                      ? () => controller.prevPage()
                      : null,
                ),
                Obx(
                  () => Text(
                    'Page ${controller.currentPage.value} / ${controller.totalPages}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textNeutralSecondarycolor,
                    ),
                  ),
                ),
                _buildPaginationButton(
                  icon: Icons.keyboard_arrow_right,
                  label: 'Next',
                  isTrailingIcon: true,
                  onPressed:
                      controller.currentPage.value < controller.totalPages
                      ? () => controller.nextPage()
                      : null,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    bool isTrailingIcon = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(8.r),
          color: onPressed == null ? Colors.grey[50] : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isTrailingIcon) ...[
              Icon(
                icon,
                size: 18.sp,
                color: onPressed == null ? Colors.grey[400] : Colors.grey[700],
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: onPressed == null ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            if (isTrailingIcon) ...[
              SizedBox(width: 4.w),
              Icon(
                icon,
                size: 18.sp,
                color: onPressed == null ? Colors.grey[400] : Colors.grey[700],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductLinkModel product) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              InkWell(
                // onTap: () {
                //   if (product.linkUrl.isNotEmpty) {
                //     controller.launchCareMallLink(product.linkUrl);
                //   } else {
                //     controller.getLink(product, showDialog: false);
                //   }
                // },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.grey[50],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: product.productImages.isNotEmpty
                            ? Image.network(
                                product.productImages[0],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              )
                            : const Icon(Icons.image),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: product.productName,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              AppText(
                                text:
                                    '₹${product.landingSellPrice % 1 == 0 ? product.landingSellPrice.toInt().toString() : product.landingSellPrice.toStringAsFixed(2)}',
                                fontSize: 16.sp,
                                color: const Color(0xFF2ECC71),
                                fontWeight: FontWeight.bold,
                              ),
                              if (product.mrpPrice >
                                  product.landingSellPrice) ...[
                                SizedBox(width: 8.w),
                                Text(
                                  '₹${product.mrpPrice % 1 == 0 ? product.mrpPrice.toInt().toString() : product.mrpPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[400],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Transform.rotate(
                                angle: -0.5,
                                child: Icon(
                                  Icons.near_me_outlined,
                                  size: 14.sp,
                                  color: Colors.grey[400],
                                ),
                              ),
                              SizedBox(width: 4.w),
                              AppText(
                                text: '${product.clickCount} clicks',
                                fontSize: 13.sp,
                                color: Colors.grey[500]!,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (product.stock <= 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Text(
                      'Out of Stock',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else if (product.isAffiliateActive)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: const Color(0xFF2ECC71)),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Color(0xFF2ECC71),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: OutlinedButton.icon(
              onPressed: product.stock <= 0
                  ? null
                  : () => controller.getLink(product),
              icon: Icon(
                Icons.link,
                size: 18,
                color: product.stock <= 0 ? Colors.grey[400] : Colors.grey[600],
              ),
              label: Text(
                'Get link',
                style: TextStyle(
                  color: product.stock <= 0
                      ? Colors.grey[400]
                      : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: product.stock <= 0
                      ? Colors.grey[200]!
                      : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
