import 'package:get/get.dart';

import '../../../data/services/auth_controller.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );
    Get.lazyPut<AuthController>(
      () => AuthController(),
    );
  }
}
