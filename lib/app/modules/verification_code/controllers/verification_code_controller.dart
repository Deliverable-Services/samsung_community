import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/constants/language_options.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/option_item.dart';
import '../../../data/localization/language_controller.dart';
import '../../../repository/auth_repo/auth_repo.dart';

class VerificationCodeController extends GetxController {
  final count = 0.obs;
  final formKey = GlobalKey<FormState>();
  final verificationCodeController = TextEditingController();
  final authRepo = Get.find<AuthRepo>();
  final selectedLanguageId = ''.obs;
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

  @override
  void dispose() {
    resendTimer?.cancel();
    verificationCodeController.dispose();
    super.dispose();
  }

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
    if (resendCountdown.value > 0) {
      return; // Don't allow resend if timer is active
    }

    isResending.value = true;

    final otpCode = await authRepo.generateOTP(phoneNumber.value);

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
    } else {
      // Show error if OTP generation failed
      final errorMessage = authRepo.errorMessage.value;
      if (errorMessage.isNotEmpty) {
        CommonSnackbar.error(errorMessage);
      } else {
        CommonSnackbar.error('failedToGenerateVerificationCode'.tr);
      }
    }
  }

  Future<void> handleSignUp() async {
    otpError.value = '';

    if (phoneNumber.value.isEmpty) {
      otpError.value = 'mobile_number_required'.tr;
      formKey.currentState?.validate();
      return;
    }

    final otpCode = verificationCodeController.text.trim();

    if (otpCode.isEmpty) {
      otpError.value = 'verificationCode'.tr + ' is required';
      formKey.currentState?.validate();
      return;
    }

    isVerifying.value = true;

    // Verify OTP (for signup, we only verify, don't sign in)
    final isValid = await authRepo.verifyOTP(
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
        otpError.value = errorMessage.isNotEmpty
            ? errorMessage
            : 'OTP verification failed';
      }
      formKey.currentState?.validate();
      return;
    }

    // OTP verified successfully, show language selector
    _showLanguageSelector();
  }

  void _showLanguageSelector() {
    BottomSheetModal.show(
      Get.context!,
      content: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageOptions.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isLast = index == LanguageOptions.options.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 10.h : 15.h),
              child: OptionItem(
                text: option.name,
                boxText: option.boxText,
                isSelected: selectedLanguageId.value == option.id,
                onTap: () async {
                  selectedLanguageId.value = option.id;

                  if (phoneNumber.value.isNotEmpty) {
                    // Save language preference
                    final success = await authRepo.saveProfile(
                      phoneNumber: phoneNumber.value,
                      profileData: {'languagePreference': option.id},
                    );

                    if (!success) {
                      debugPrint('Failed to save language preference');
                      final errorMessage = authRepo.errorMessage.value;
                      CommonSnackbar.error(
                        errorMessage.isNotEmpty
                            ? errorMessage
                            : 'Failed to save language preference',
                      );
                      return;
                    }
                  }

                  final languageController = Get.find<LanguageController>();
                  languageController.changeLanguage(option.id);
                  Get.back();
                  Get.offNamed(
                    Routes.PERSONAL_DETAILS,
                    parameters: {'phoneNumber': phoneNumber.value},
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
