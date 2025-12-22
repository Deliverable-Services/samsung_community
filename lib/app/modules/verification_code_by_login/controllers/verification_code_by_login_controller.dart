import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/core/utils/common_snackbar.dart';
import '../../../repository/auth_repo/auth_repo.dart';

class VerificationCodeByLoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final verificationCodeController = TextEditingController();
  final authRepo = Get.find<AuthRepo>();
  final phoneNumber = ''.obs;
  final isResending = false.obs;
  final isVerifying = false.obs;
  final otpError = ''.obs;
  Timer? resendTimer;
  final resendCountdown = 0.obs;

  /// Check if form is valid
  bool get isFormValid {
    final otpCode = verificationCodeController.text.trim();
    return otpCode.isNotEmpty;
  }

  void startResendTimer() {
    resendTimer?.cancel();
    resendCountdown.value = 60; // 1 minute = 60 seconds

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        timer.cancel();
        resendCountdown.value = 0;
      }
    });
  }

  Future<void> handleResendCode() async {
    if (phoneNumber.value.isEmpty) return;
    if (resendCountdown.value > 0)
      return; // Don't allow resend if timer is active

    isResending.value = true;

    final otpCode = await authRepo.generateOTPForLogin(phoneNumber.value);

    isResending.value = false;
    // Clear error message when OTP is successfully sent
    if (otpCode != null) {
      otpError.value = '';
    }

    if (otpCode != null) {
      // Start timer after successful resend
      startResendTimer();
      // Trigger form validation to clear the error display
      formKey.currentState?.validate();
    }
  }

  Future<void> handleApproval() async {
    otpError.value = '';

    if (phoneNumber.value.isEmpty) {
      otpError.value = 'mobile_number_required'.tr;
      formKey.currentState?.validate();
      return;
    }

    final otpCode = verificationCodeController.text.trim();

    if (otpCode.isEmpty) {
      otpError.value = '${'verificationCode'.tr} ${'isRequired'.tr}';
      formKey.currentState?.validate();
      return;
    }

    isVerifying.value = true;

    // Verify OTP and sign in to get session tokens
    final isValid = await authRepo.verifyOTPAndSignIn(
      phoneNumber: phoneNumber.value,
      otpCode: otpCode,
    );

    isVerifying.value = false;

    if (!isValid) {
      final errorMessage = authRepo.errorMessage.value;

      if (errorMessage.contains('OTP_INCORRECT')) {
        otpError.value = 'otp_incorrect'.tr;
      } else if (errorMessage.contains('OTP_EXPIRED')) {
        otpError.value = 'otp_expired'.tr;
      } else {
        otpError.value = errorMessage;
      }
      formKey.currentState?.validate();
      return;
    }

    // OTP verified and signed in successfully, check user status
    final userDetails = await authRepo.getUserDetailsByPhone(phoneNumber.value);

    if (userDetails == null) {
      otpError.value = 'user_not_found'.tr;
      formKey.currentState?.validate();
      return;
    }

    final status = userDetails['status'] as String?;

    // If user status is pending, show error
    if (status == 'pending') {
      otpError.value = 'wait_for_approval'.tr;
      formKey.currentState?.validate();
      return;
    }
    // User is approved, navigate to main layout
    CommonSnackbar.success('signInSuccessful'.tr);
    Get.offAllNamed(Routes.BOTTOM_BAR);
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    verificationCodeController.dispose();
    super.dispose();
  }

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final parameters = Get.parameters as Map<String, dynamic>?;
    phoneNumber.value = (parameters?['phoneNumber'] as String?) ?? '';
    // Start countdown timer when screen loads
    startResendTimer();
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
