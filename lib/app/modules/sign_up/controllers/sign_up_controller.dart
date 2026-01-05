import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/core/utils/common_snackbar.dart';
import '../../../repository/auth_repo/auth_repo.dart';

class SignUpController extends GetxController {
  final count = 0.obs;

  final formKey = GlobalKey<FormState>();
  TextEditingController mobileController = TextEditingController();
  final _authRepo = Get.find<AuthRepo>();

  final isValidating = false.obs;
  final hasValidated = false.obs;

  bool get isFormValid {
    final phoneNumber = mobileController.text.trim();
    if (phoneNumber.isEmpty) return false;

    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return normalizedPhone.length >= 10;
  }

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'mobile_number_required'.tr;
    }

    final normalizedPhone = value.replaceAll(RegExp(r'\D'), '');

    if (normalizedPhone.length < 10) {
      return 'invalid_phone_number'.tr;
    }

    return null;
  }

  Future<void> handleSignUp() async {
    hasValidated.value = true;

    if (!(formKey.currentState?.validate() ?? false)) {
      final phoneError = validatePhone(mobileController.text);
      if (phoneError != null) {
        CommonSnackbar.error(phoneError);
      }
      return;
    }

    final phoneNumber = mobileController.text.trim();
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

    isValidating.value = true;

    try {
      final userDetails = await _authRepo.checkUserForSignup(normalizedPhone);
      final checkUserError = _authRepo.errorMessage.value;

      // Check for USER_ALREADY_SIGNED_UP error early and return
      if (userDetails == null && checkUserError.contains('USER_ALREADY_SIGNED_UP')) {
        isValidating.value = false;
        _authRepo.clearError(); // Clear error after showing
        CommonSnackbar.error('user_already_signed_up'.tr);
        return;
      }

      // If there was an error in checkUserForSignup but not USER_ALREADY_SIGNED_UP, show it and return
      if (userDetails == null && checkUserError.isNotEmpty) {
        isValidating.value = false;
        _authRepo.clearError(); // Clear error after showing
        CommonSnackbar.error(checkUserError);
        return;
      }

      final authUserId = await _authRepo.createOrGetAuthUser(normalizedPhone);
      if (authUserId == null) {
        isValidating.value = false;
        final errorMessage = _authRepo.errorMessage.value;
        _authRepo.clearError(); // Clear error after showing
        // Don't show error if it's USER_ALREADY_SIGNED_UP (already shown above)
        if (!errorMessage.contains('USER_ALREADY_SIGNED_UP')) {
          CommonSnackbar.error(
            errorMessage.isNotEmpty
                ? errorMessage
                : 'failedToGenerateVerificationCode'.tr,
          );
        }
        return;
      }

      final userCreated = await _authRepo.createOrUpdatePublicUser(
        phoneNumber: normalizedPhone,
        authUserId: authUserId,
        existingUserDetails: userDetails,
      );

      if (!userCreated) {
        isValidating.value = false;
        final errorMessage = _authRepo.errorMessage.value;
        _authRepo.clearError(); // Clear error after showing
        // Don't show error if it's USER_ALREADY_SIGNED_UP (already shown above)
        if (!errorMessage.contains('USER_ALREADY_SIGNED_UP')) {
          CommonSnackbar.error(
            errorMessage.isNotEmpty
                ? errorMessage
                : 'failedToGenerateVerificationCode'.tr,
          );
        }
        return;
      }

      final otpCode = await _authRepo.generateOTP(normalizedPhone);

      isValidating.value = false;

      if (otpCode == null) {
        final errorMessage = _authRepo.errorMessage.value;
        _authRepo.clearError(); // Clear error after showing
        // Don't show error if it's USER_ALREADY_SIGNED_UP (already shown above)
        if (errorMessage.contains('USER_ALREADY_SIGNED_UP')) {
          return; // Already shown, don't show again
        }

        if (errorMessage.contains('WAIT_FOR_APPROVAL') ||
            errorMessage.contains('wait_for_approval')) {
          CommonSnackbar.error('wait_for_approval'.tr);
        } else if (errorMessage.isNotEmpty) {
          CommonSnackbar.error(errorMessage);
        } else {
          CommonSnackbar.error('failedToGenerateVerificationCode'.tr);
        }
        return;
      }

    Get.toNamed(
      Routes.VERIFICATION_CODE,
        parameters: {'phoneNumber': normalizedPhone},
    );
    } catch (e) {
      isValidating.value = false;
      debugPrint('Error in handleSignUp: $e');
      CommonSnackbar.error('somethingWentWrong'.tr);
    }
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
