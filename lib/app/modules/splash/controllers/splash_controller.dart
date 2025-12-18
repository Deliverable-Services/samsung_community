import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/services/auth_controller.dart';

class SplashController extends GetxController {
  final count = 0.obs;

  /// Determine initial route based on authentication status
  Future<void> _determineInitialRoute() async {
    // Wait for AuthController to be initialized and check auth status
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final authController = Get.find<AuthController>();
      await authController.checkAuthStatus();
      // Determine initial route based on auth status
      if (authController.isAuthenticated.value) {
        Get.offAllNamed(Routes.BOTTOM_BAR);
      } else {
        Get.offAllNamed(Routes.ON_BOARDING);
      }
    } catch (e) {
      // If AuthController is not found, default to welcome screen
      Get.offAllNamed(Routes.ON_BOARDING);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _determineInitialRoute();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
