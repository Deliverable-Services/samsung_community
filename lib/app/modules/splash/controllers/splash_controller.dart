import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../../main.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../../bottom_bar/bindings/bottom_bar_binding.dart';
import '../../bottom_bar/views/bottom_bar_view.dart';
import '../../login/bindings/login_binding.dart';
import '../../login/views/login_view.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final count = 0.obs;
  late AnimationController animationController;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(vsync: this);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void onAnimationLoaded(LottieComposition composition) {
    animationController
      ..duration = composition.duration
      ..forward().whenComplete(() => _determineInitialRoute());
  }

  /// Determine initial route based on authentication status
  Future<void> _determineInitialRoute() async {
    // Wait for AuthRepo to be initialized and check auth status
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final authRepo = Get.find<AuthRepo>();
      await authRepo.checkAuthStatus();
      // Determine initial route based on auth status
      if (authRepo.isAuthenticated.value) {
        Get.offAll(
          () => const BottomBarView(),
          binding: BottomBarBinding(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 1000),
        );
      } else {
        Get.offAll(
          () => const LoginView(),
          binding: LoginBinding(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 1000),
        );
      }
    } catch (e) {
      // If AuthRepo is not found, default to welcome screen
      Get.offAll(
        () => const LoginView(),
        binding: LoginBinding(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 1000),
      );
    }
  }

  @override
  void onReady() {
    super.onReady();
  }
}
