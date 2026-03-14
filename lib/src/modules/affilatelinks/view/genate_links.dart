import 'package:care_mall_affiliate/src/modules/affilatelinks/controller/link_controller.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/model/link_model.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GenerateLinksScreen extends GetView<CreateLinkController> {
  const GenerateLinksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.resetPagination();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text(
            'Generate Link',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              controller.resetPagination();
              Get.back();
            },
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(4),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => controller.searchProducts(value),
                  decoration: InputDecoration(
                    hintText: 'Search products by name...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 20.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),

            // Product Grid
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.products.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                }

                if (controller.filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No products found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return CustomScrollView(
                  controller: controller.scrollController,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = controller.filteredProducts[index];
                          return _buildProductCard(product);
                        }, childCount: controller.filteredProducts.length),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child:
                          (!controller.isLoading.value &&
                              (controller.hasMoreProducts.value ||
                                  controller.currentPageProducts.value > 1) &&
                              controller.filteredProducts.isNotEmpty)
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 24.h,
                                horizontal: 16.w,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildPaginationButton(
                                      icon: Icons.keyboard_arrow_left,
                                      label: 'Previous',
                                      onPressed:
                                          controller.currentPageProducts.value >
                                              1
                                          ? () => controller
                                                .loadPrevPageProducts()
                                          : null,
                                    ),
                                    Obx(
                                      () => Text(
                                        'Page ${controller.currentPageProducts.value} / ${controller.totalProductsPages.value}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    _buildPaginationButton(
                                      icon: Icons.keyboard_arrow_right,
                                      label: 'Next',
                                      isTrailingIcon: true,
                                      onPressed:
                                          controller.hasMoreProducts.value
                                          ? () => controller
                                                .loadNextPageProducts()
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(height: 24.h),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductLinkModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(4),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        // onTap: () {
        //   if (product.linkUrl.isNotEmpty) {
        //     controller.launchCareMallLink(product.linkUrl);
        //   } else {
        //     controller.getLink(product, showDialog: false);
        //   }
        // },
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                      child: product.productImages.isNotEmpty
                          ? Image.network(
                              product.productImages[0],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey[300],
                                    size: 48.sp,
                                  ),
                            )
                          : Icon(
                              Icons.image_outlined,
                              color: Colors.grey[300],
                              size: 48.sp,
                            ),
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12.sp),
                          SizedBox(width: 2.w),
                          Text(
                            '4.5',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Info
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        '₹${product.landingSellPrice % 1 == 0 ? product.landingSellPrice.toInt().toString() : product.landingSellPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      if (product.mrpPrice > product.landingSellPrice)
                        Text(
                          '₹${product.mrpPrice % 1 == 0 ? product.mrpPrice.toInt().toString() : product.mrpPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[400],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 36.h,
                    child: ElevatedButton(
                      onPressed: () =>
                          controller.getLink(product, showDialog: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.link, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'Generate Link',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                fontSize: 14.sp,
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
}
