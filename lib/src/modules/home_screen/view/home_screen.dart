import 'package:care_mall_affiliate/gen/assets.gen.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/controller/homescreen_controller.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/widgets/order_management_chart.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/widgets/recent_orders_widget.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/widgets/overall_performance_chart.dart';
import 'package:care_mall_affiliate/src/modules/kyc_profile/view/kyc_screen.dart';
import 'package:care_mall_affiliate/app/commenwidget/apptext.dart';
import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/widgets/app_drawer.dart';
import 'package:care_mall_affiliate/src/modules/dashboard/view/dashboardcard.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/widgets/quick_actions_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  late final DashboardController _dashboardController;
  final ScrollController _scrollController = ScrollController();
  static final RouteObserver<ModalRoute<void>> _routeObserver =
      RouteObserver<ModalRoute<void>>();

  @override
  void initState() {
    super.initState();
    _dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController(), permanent: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  /// Called every time we navigate back to this screen.
  @override
  void didPopNext() {
    _dashboardController.refreshData();
  }

  Future<void> _onRefresh() async {
    await _dashboardController.loadDashboardData(showLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final dashboardController = _dashboardController;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: SizedBox(
          height: 30,
          child: Assets.icons.appLogoPng.image(fit: BoxFit.fitHeight),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.notifications_outlined),
          //   onPressed: () {
          //     // TODO: Navigate to notifications
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                Get.to(() => const KycScreen());
              },
            ),
          ),
        ],
        // Leading button removed to let AppBar automatically handle the Drawer
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.red,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KYC Reminder Notification
                      Obx(() {
                        final status = authController.kycStatus.value
                            .toLowerCase()
                            .trim();
                        debugPrint(
                          "HomeScreen: Current KYC Status -> '$status'",
                        );

                        // Hide banner if KYC is in any "submitted" or "done" state
                        final isHidden =
                            status == 'approved' ||
                            status == 'pending' ||
                            status == 'submitted' ||
                            status == 'verified' ||
                            status == 'success';

                        if (isHidden) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          margin: EdgeInsets.only(bottom: 24.h),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange[100]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange[800],
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      text: 'Complete Your KYC',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange[900]!,
                                    ),
                                    AppText(
                                      text:
                                          'Submit KYC details to activate all features.',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.orange[700]!,
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.to(() => KycScreen());
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.primarycolor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Submit'),
                              ),
                            ],
                          ),
                        );
                      }),
                      Obx(() {
                        if (dashboardController.isLoading.value) {
                          return Container(
                            height: 0.7.sh,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              color: Colors.red,
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Dashboard Header
                            Text(
                              'Affiliate Dashboard',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.blackcolor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Welcome back${authController.userName.value.isNotEmpty ? ', ${authController.userName.value}' : ''}! Here's what's happening with\nyour affiliate account today.",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textDefaultSecondarycolor,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            const Center(child: QuickActionsWidget()),
                            SizedBox(height: 24.h),

                            // Cards and Charts
                            if (dashboardController
                                    .errorMessage
                                    .value
                                    .isNotEmpty &&
                                dashboardController.dashboardData.isEmpty)
                              Container(
                                height: constraints.maxHeight * 0.65,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.wifi_off_rounded,
                                      size: 52,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      dashboardController.errorMessage.value,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pull down to refresh',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (dashboardController.dashboardData.isEmpty)
                              SizedBox(
                                height: constraints.maxHeight * 0.7,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 56,
                                        color: Colors.grey[350],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No Data Available',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Pull down to refresh',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: DashboardCard(
                                            data: dashboardController
                                                .dashboardData[0],
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: DashboardCard(
                                            data: dashboardController
                                                .dashboardData[1],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: DashboardCard(
                                            data: dashboardController
                                                .dashboardData[2],
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: DashboardCard(
                                            data: dashboardController
                                                .dashboardData[3],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: DashboardCard(
                                      data:
                                          dashboardController.dashboardData[4],
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  const OverallPerformanceWidget(),
                                  SizedBox(height: 20.h),
                                  OrderManagementChart(
                                    data: dashboardController.orderStats,
                                    selectedTimeRange: dashboardController
                                        .selectedOrderTimeRange
                                        .value,
                                    onTimeRangeChanged: (newRange) {
                                      dashboardController.updateOrderTimeRange(
                                        newRange,
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20.h),
                                  RecentOrdersWidget(
                                    orders: dashboardController.recentOrders
                                        .toList(),
                                  ),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
