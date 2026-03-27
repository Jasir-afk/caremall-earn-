import 'package:care_mall_affiliate/app/commenwidget/app_snackbar.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:care_mall_affiliate/src/modules/kyc_profile/view/kyc_screen.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/model/link_model.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/repo/link_repo.dart';
import 'package:care_mall_affiliate/src/modules/commoncontroller/share_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateLinkController extends GetxController {
  final products = <ProductLinkModel>[].obs;
  final filteredProducts = <ProductLinkModel>[].obs;
  final generatedFilteredProducts = <ProductLinkModel>[].obs;
  final isLoading = false.obs;
  final isGenerating = false.obs;
  final searchQuery = ''.obs;
  final currentPage = 1.obs;
  final itemsPerPage = 10;

  // Products Pagination (Generate Links Screen)
  final scrollController = ScrollController();
  final currentPageProducts = 1.obs;
  final totalProductsPages = 1.obs;
  final hasMoreProducts = true.obs;
  final isLoadingMore = false.obs;

  int get totalPages {
    if (generatedFilteredProducts.isEmpty) return 1;
    return (generatedFilteredProducts.length / itemsPerPage).ceil();
  }

  List<ProductLinkModel> get paginatedProducts {
    final start = (currentPage.value - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    if (start >= generatedFilteredProducts.length) return [];
    return generatedFilteredProducts.sublist(
      start,
      end > generatedFilteredProducts.length
          ? generatedFilteredProducts.length
          : end,
    );
  }

  void nextPage() {
    if (currentPage.value < totalPages) {
      currentPage.value++;
    }
  }

  void prevPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  // Stats
  final clicks = '0'.obs;
  final activeLinks = '0'.obs;
  final totalOrders = '0'.obs;
  final totalCommissions = '0'.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    // Optional: Keep listener active if needed for other scrolling logic
    // but remove auto-triggering loadMoreProducts as user wants a button
  }

  void loadNextPageProducts() {
    if (hasMoreProducts.value && !isLoading.value) {
      fetchProducts(search: searchQuery.value, isNextPage: true);
    }
  }

  void loadPrevPageProducts() {
    if (currentPageProducts.value > 1 && !isLoading.value) {
      fetchProducts(search: searchQuery.value, isPrevPage: true);
    }
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([fetchProducts(), fetchGeneratedLinks(), fetchStats()]);
    isLoading.value = false;
  }

  Future<void> fetchProducts({
    String search = '',
    int limit = 10,
    bool isNextPage = false,
    bool isPrevPage = false,
  }) async {
    isLoading.value = true;

    if (isNextPage) {
      currentPageProducts.value++;
    } else if (isPrevPage) {
      currentPageProducts.value--;
    } else {
      currentPageProducts.value = 1;
      hasMoreProducts.value = true;
    }

    try {
      final result = await CreateLinkRepo.getProducts(
        search: search,
        limit: limit,
        page: currentPageProducts.value,
      );
      if (result['success']) {
        final List<dynamic> data = result['data'] ?? [];
        totalProductsPages.value = result['totalPages'] ?? 1;

        final List<ProductLinkModel> fetchedProducts = data
            .map((e) => ProductLinkModel.fromJson(e))
            .toList();

        if (fetchedProducts.length < limit ||
            currentPageProducts.value >= totalProductsPages.value) {
          hasMoreProducts.value = false;
        } else {
          hasMoreProducts.value = true;
        }

        if (search.isEmpty) {
          products.assignAll(fetchedProducts);
          _applyFilters();
        } else {
          filteredProducts.assignAll(fetchedProducts);
        }

        // Scroll to top
        if (scrollController.hasClients) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } else {
        debugPrint('Error fetching products: ${result['message']}');
        if (isNextPage) currentPageProducts.value--;
        if (isPrevPage) currentPageProducts.value++;
      }
    } catch (e) {
      debugPrint('Exception in fetchProducts: $e');
      if (isNextPage) currentPageProducts.value--;
      if (isPrevPage) currentPageProducts.value++;
    }
    isLoading.value = false;
  }

  Future<void> fetchGeneratedLinks() async {
    try {
      final result = await CreateLinkRepo.getGeneratedLinks();
      if (result['success']) {
        final List<dynamic> data = result['data'] ?? [];
        final List<ProductLinkModel> fetchedLinks = data
            .map((e) => ProductLinkModel.fromJson(e))
            .toList();

        // Update the source of truth for all links view
        generatedFilteredProducts.assignAll(fetchedLinks);

        // Update active count from the dedicated API results
        activeLinks.value = fetchedLinks.length.toString();

        // Merge link data back into the main products list if they exist there
        for (var linkedProduct in fetchedLinks) {
          final index = products.indexWhere((p) => p.id == linkedProduct.id);
          if (index != -1) {
            products[index] = linkedProduct;
          }
        }
      } else {
        debugPrint('Error fetching generated links: ${result['message']}');
      }
    } catch (e) {
      debugPrint('Exception in fetchGeneratedLinks: $e');
    }
  }

  void _applyFilters() {
    if (searchQuery.isEmpty) {
      filteredProducts.assignAll(products);
      // Note: generatedFilteredProducts is managed separately via fetchGeneratedLinks
      // to avoid overwriting it with limited catalog data.
    } else {
      String query = searchQuery.value.toLowerCase();
      filteredProducts.assignAll(
        products
            .where((p) => p.productName.toLowerCase().contains(query))
            .toList(),
      );
      // Also filter generated links locally to ensure search works there immediately
      generatedFilteredProducts.assignAll(
        generatedFilteredProducts
            .where((p) => p.productName.toLowerCase().contains(query))
            .toList(),
      );
    }
  }

  Future<void> fetchStats() async {
    try {
      final result = await CreateLinkRepo.getLinksStats();
      if (result['success']) {
        final data = result['data'];
        // Link specific stats from the new API
        clicks.value = (data['totalClicks'] ?? 0).toString();
        activeLinks.value = (data['activeLinks'] ?? 0).toString();
        totalOrders.value = (data['totalOrders'] ?? 0).toString();
        totalCommissions.value = (data['totalCommission'] ?? 0).toString();
      } else {
        debugPrint('Error fetching link stats: ${result['message']}');
      }
    } catch (e) {
      debugPrint('Exception in fetchStats: $e');
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    currentPage.value = 1;
    currentPageProducts.value = 1;
    hasMoreProducts.value = true;
    products.clear();
    filteredProducts.clear();
    loadData();
  }

  void resetPagination() {
    if (currentPageProducts.value > 1 || searchQuery.value.isNotEmpty) {
      searchQuery.value = '';
      currentPageProducts.value = 1;
      hasMoreProducts.value = true;
      if (products.length > 10) {
        products.assignAll(products.take(10).toList());
      }
      _applyFilters();
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    currentPageProducts.value = 1;
    hasMoreProducts.value = true;
    if (query.isEmpty) {
      loadData();
    } else {
      // For general catalog, we search on server
      fetchProducts(search: query);
      // For generated links, we search locally to ensure we don't lose data
      _applyFilters();
    }
  }

  void getLink(ProductLinkModel product, {bool showDialog = false}) async {
    // Check KYC Status
    final authController = Get.find<AuthController>();
    final status = authController.kycStatus.value.toLowerCase();
    if (status != 'approved' && status != 'pending') {
      _showKycWarningDialog();
      return;
    }

    if (product.linkUrl.isNotEmpty) {
      if (showDialog) {
        _showLinkDialog(product.linkUrl, product);
      } else {
        _copyToClipboard(product.linkUrl);
      }

      // Move to top if it exists in the generated list
      final index = generatedFilteredProducts.indexWhere(
        (p) => p.id == product.id,
      );
      if (index != -1) {
        final item = generatedFilteredProducts.removeAt(index);
        generatedFilteredProducts.insert(0, item);
      }
      return;
    }

    isGenerating.value = true;
    try {
      final result = await CreateLinkRepo.generateProductLink(product.id);
      if (result['success']) {
        final data = result['data'];
        final linkUrl = data['linkUrl'] ?? '';

        // Refresh the generated links list first
        await fetchGeneratedLinks();

        // Move the newly generated one to top
        final index = generatedFilteredProducts.indexWhere(
          (p) => p.id == product.id,
        );
        if (index != -1) {
          final item = generatedFilteredProducts.removeAt(index);
          generatedFilteredProducts.insert(0, item);
        }

        if (showDialog) {
          TcSnackbar.success('Success', 'Link generated successfully');
          _showLinkDialog(linkUrl, product);
        } else {
          _copyToClipboard(linkUrl);
        }
        fetchProducts(search: searchQuery.value);
      } else {
        TcSnackbar.error('Error', result['message']);
      }
    } catch (e) {
      TcSnackbar.error('Error', 'Something went wrong. Please try again.');
    } finally {
      isGenerating.value = false;
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    TcSnackbar.success('Copied', 'Copied to clipboard');
  }

  void _showLinkDialog(String linkUrl, [ProductLinkModel? product]) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, size: 24.sp, color: Colors.grey[600]),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: const Color(0xFF4CAF50),
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Link Generated!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
              if (product != null) ...[
                SizedBox(height: 12.h),
                Text(
                  product.productName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],

              SizedBox(height: 24.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Affiliate Link',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF343A40),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Text(
                  linkUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF495057),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _copyToClipboard(linkUrl);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.copy, size: 18.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'Copy',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: (product != null)
                        ? OutlinedButton(
                            onPressed: () {
                              Get.back();
                              ProductSharingService.shareProduct(
                                name: product.productName,
                                url: linkUrl,
                                mrp: product.mrpPrice,
                                sellingPrice: product.landingSellPrice,
                                imageUrl: product.productImages.isNotEmpty
                                    ? product.productImages[0]
                                    : null,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF101828),
                              side: const BorderSide(color: Color(0xFFE9ECEF)),
                              minimumSize: Size(double.infinity, 50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 0,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.share, size: 18.sp),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Share',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : OutlinedButton(
                            onPressed: () {
                              Get.back(); // Close dialog
                              launchCareMallLink(linkUrl);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF101828),
                              side: const BorderSide(color: Color(0xFFE9ECEF)),
                              minimumSize: Size(double.infinity, 50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.open_in_new, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'Open',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              OutlinedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  launchCareMallLink(linkUrl);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF101828),
                  side: const BorderSide(color: Color(0xFFE9ECEF)),
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.open_in_new, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Open',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
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

  Future<void> launchCareMallLink(String linkUrl) async {
    debugPrint('CreateLinkController: Attempting to open link: $linkUrl');
    final Uri webUri = Uri.parse(linkUrl);

    // Extract slug: looks for 'product' in path segments and takes the next segment
    String? slug;
    final String host = webUri.host;
    if (host.contains('caremallonline.com') ||
        host.contains('caremall-userside-frontend')) {
      final index = webUri.pathSegments.indexOf('product');
      if (index != -1 && webUri.pathSegments.length > index + 1) {
        slug = webUri.pathSegments[index + 1];
      }
    }

    // ── Strategy 1: Try caremall:// custom scheme ──────────────────────────
    if (slug != null && slug.isNotEmpty) {
      final appUri = Uri.parse('caremall://product/$slug');
      debugPrint('CreateLinkController: [1] Trying caremall:// → $appUri');
      try {
        final bool launched = await launchUrl(
          appUri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
        if (launched) {
          debugPrint('CreateLinkController: Opened via caremall:// scheme');
          return;
        }
      } catch (e) {
        debugPrint('CreateLinkController: caremall:// failed: $e');
      }
    }

    // ── Strategy 2: Try HTTPS URL as App Link (non-browser) ────────────────
    // If CareMall app has registered caremallonline.com as an App Link,
    // this will open directly in the CareMall app without a browser.
    debugPrint('CreateLinkController: [2] Trying HTTPS App Link → $webUri');
    try {
      final bool launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (launched) {
        debugPrint('CreateLinkController: Opened via HTTPS App Link');
        return;
      }
    } catch (e) {
      debugPrint('CreateLinkController: HTTPS App Link failed: $e');
    }

    // ── Strategy 3: CareMall not installed → Play Store ────────────────────
    debugPrint('CreateLinkController: [3] Opening Play Store for CareMall');
    await _openPlayStore();
  }

  /// Opens the CareMall app listing on the Play Store.
  /// Tries the native market:// scheme first; falls back to the web Play Store URL.
  static const String _careMallPackageId = 'com.caremall.care_mall';

  Future<void> _openPlayStore() async {
    final marketUri = Uri.parse('market://details?id=$_careMallPackageId');
    final webStoreUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$_careMallPackageId',
    );

    try {
      final bool canOpenMarket = await canLaunchUrl(marketUri);
      if (canOpenMarket) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      debugPrint('CreateLinkController: market:// failed: $e');
    }
    // Fallback: open web Play Store
    try {
      await launchUrl(webStoreUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('CreateLinkController: Play Store web fallback failed: $e');
      TcSnackbar.error('Error', 'Could not open Play Store');
    }
  }

  void _showKycWarningDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.red,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'KYC Verification Required',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'You need to complete your KYC verification to generate affiliate links and start earning commissions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF101828),
                        side: const BorderSide(color: Color(0xFFE9ECEF)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.to(() => const KycScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Complete KYC',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
