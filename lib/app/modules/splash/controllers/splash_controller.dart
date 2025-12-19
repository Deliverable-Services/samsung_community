import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../repository/auth_repo/auth_repo.dart';

class SplashController extends GetxController {
  final count = 0.obs;

  /// Determine initial route based on authentication status
  Future<void> _determineInitialRoute() async {
    // Wait for AuthRepo to be initialized and check auth status
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final authRepo = Get.find<AuthRepo>();
      await authRepo.checkAuthStatus();
      // Determine initial route based on auth status
      if (authRepo.isAuthenticated.value) {
        Get.offAllNamed(Routes.BOTTOM_BAR);
      } else {
        Get.offAllNamed(Routes.ON_BOARDING);
      }
    } catch (e) {
      // If AuthRepo is not found, default to welcome screen
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
