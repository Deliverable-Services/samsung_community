import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonSnackbar {
  static void error(String? message) {
    Get.snackbar(
      'error'.tr,
      message ?? 'somethingWentWrong'.tr,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  static void success(String message, {Duration? duration}) {
    Get.snackbar(
      'Success'.tr,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF0076FF),
      colorText: Colors.white,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}
