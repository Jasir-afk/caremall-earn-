import 'package:care_mall_affiliate/app/deeplink/deeplink_service.dart';
import 'package:care_mall_affiliate/app/services/update_service.dart';
import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:care_mall_affiliate/gen/assets.gen.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:care_mall_affiliate/src/modules/auth/view/login_screen.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/controller/homescreen_controller.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/home_screen.dart';
import 'package:care_mall_affiliate/src/modules/kyc_profile/controller/kyc_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  @override
  void initState() {
    super.initState();
    // Trigger fade-in animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _opacity = 1.0);
    });

    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // 🔧 Check for a mandatory update FIRST — halts navigation if update is needed
    if (mounted) {
      final updateRequired = await UpdateService.showUpdateDialogIfNeeded(
        context,
        force: false,
      );

      if (updateRequired) {
        debugPrint('🛑 Update required. Navigation halted.');
        return; // User is blocked on the update dialog until they update
      }
    }

    final authController = Get.find<AuthController>();

    // Initial check: if already logged in (token present in memory/SharedPreferences),
    // we should wait for KycController to fetch the profile so Home is populated.
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      authController.authDataLoaded, // waits for token load
    ]);

    if (!mounted) return;

    if (authController.authToken.value.isNotEmpty) {
      // User is logged in — wait for profile info for a better UX (max 1-2 more seconds if it was slow)
      if (Get.isRegistered<KycController>()) {
        final kycController = Get.find<KycController>();
        // Wait for profile fetch to complete before going Home
        await kycController.profileLoaded;
      }

      // Logged in — go to Home
      if (!Get.isRegistered<DashboardController>()) {
        Get.put(DashboardController(), permanent: true);
      } else {
        Get.find<DashboardController>().loadDashboardData(showLoading: false);
      }
      Get.offAll(() => const HomeScreen());
    } else {
      // Not logged in — go to Login
      Get.offAll(() => const LoginScreen());
    }

    // Process any pending deep links
    DeepLinkService.processPendingLink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whitecolor,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          child: Image.asset(Assets.icons.appLogoPng.keyName, scale: 2),
        ),
      ),
    );
  }
}
