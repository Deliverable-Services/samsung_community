import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/services/auth_controller.dart';

class SignUpController extends GetxController {
  final count = 0.obs;

  final formKey = GlobalKey<FormState>();
  TextEditingController mobileController = TextEditingController();
  final _authController = Get.find<AuthController>();

  final mobileError = ''.obs;
  final isValidating = false.obs;
  final hasValidated = false.obs;

  /// Check if form is valid
  bool get isFormValid {
    final phoneNumber = mobileController.text.trim();
    if (phoneNumber.isEmpty) return false;

    // Normalize phone number for validation
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return normalizedPhone.length >= 10;
  }

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  /// Validate phone number format
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'mobile_number_required'.tr;
    }

    // Normalize phone number for validation
    final normalizedPhone = value.replaceAll(RegExp(r'\D'), '');

    if (normalizedPhone.length < 10) {
      return 'invalid_phone_number'.tr;
    }

    return null;
  }

  /// Handle sign up button tap
  Future<void> handleSignUp() async {
    // Mark that we've attempted validation
    hasValidated.value = true;
    mobileError.value = '';

    // Validate form first
    if (formKey.currentState?.validate() ?? false) {
      return;
    }

    final phoneNumber = mobileController.text.trim();

    // Generate OTP (this will handle all user existence and validation checks)
    isValidating.value = true;

    final otpCode = await _authController.generateOTP(phoneNumber);

    isValidating.value = false;

    if (otpCode == null) {
      // Check for specific error codes
      final errorMessage = _authController.errorMessage.value;

      if (errorMessage.contains('USER_ALREADY_SIGNED_UP')) {
        mobileError.value = 'user_already_signed_up'.tr;
      } else if (errorMessage.contains('WAIT_FOR_APPROVAL')) {
        mobileError.value = 'wait_for_approval'.tr;
      } else {
        mobileError.value = errorMessage;
      }

      formKey.currentState?.validate();
      return;
    }

    Get.toNamed(
      Routes.VERIFICATION_CODE,
      parameters: {'phoneNumber': phoneNumber},
    );
  }

  @override
  void onInit() {
    super.onInit();
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
