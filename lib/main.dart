import 'package:care_mall_affiliate/app/deeplink/deeplink_service.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:care_mall_affiliate/src/modules/intilise_screen/view/splash_screen.dart';
import 'package:care_mall_affiliate/src/modules/kyc_profile/controller/kyc_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:care_mall_affiliate/app/utils/dio/dio.dart';
import 'package:care_mall_affiliate/app/services/update_service.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await DeepLinkService().init();
  DI.inject();
  Get.put(AuthController());
  Get.put(KycController(), permanent: true);

  // 🔧 Clear upgrader cache to ensure version check runs accurately
  UpdateService.configure(debugLogging: false);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard mobile design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          color: Colors.white,
          title: 'Care Earn+',
          theme: ThemeData(useMaterial3: true),
          home: Center(child: const SplashScreen()),
        );
      },
    );
  }
}
