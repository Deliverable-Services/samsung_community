import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.count.value;
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: AppColors.primary,
          body: Image.asset(AppImages.imageSplash, fit: BoxFit.cover),
        ),
      );
    });
  }
}
