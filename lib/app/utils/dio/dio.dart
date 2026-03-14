import 'package:care_mall_affiliate/app/utils/dio/dio_client.dart';
import 'package:get/instance_manager.dart';

class DI {
  static inject() {
    Get.lazyPut(() => DioClient());
  }
}
