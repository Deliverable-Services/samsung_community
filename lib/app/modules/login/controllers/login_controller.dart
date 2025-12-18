import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/services/auth_controller.dart';
import '../../../data/services/auth_service.dart';

class LoginController extends BaseController {
  final count = 0.obs;

  final formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();

  final mobileError = ''.obs;
  final isValidating = false.obs;
  final hasValidated = false.obs;

  late final AuthService _authService;
  final _authController = Get.find<AuthController>();

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

  /// Check if user exists by phone number
  Future<bool> checkUserExists(String phoneNumber) async {
    setLoading(true);
    clearError();

    final result = await _authService.checkUserExists(phoneNumber);

    setLoading(false);

    if (result.isSuccess) {
      return result.dataOrNull ?? false;
    } else {
      final error = result.errorOrNull ?? 'Failed to check user';
      print('Error in checkUserExists: $error');
      handleError(error);
      return false;
    }
  }

  /// Handle login button tap
  Future<void> handleLogin() async {
    // Mark that we've attempted validation
    hasValidated.value = true;
    mobileError.value = '';

    // Validate form first
    if (formKey.currentState?.validate() ?? false) {
      return;
    }

    // Check if user exists
    isValidating.value = true;

    final phoneNumber = mobileController.text.trim();
    final userExists = await _authController.checkUserExists(phoneNumber);
    print('userExists:::::${userExists}');
    if (!userExists) {
      isValidating.value = false;
      mobileError.value = 'user_not_found'.tr;
      // Trigger form validation to show error
      formKey.currentState?.validate();
      return;
    }

    // User exists, generate new OTP for login
    final otpCode = await _authController.generateOTPForLogin(phoneNumber);

    isValidating.value = false;

    if (otpCode == null) {
      // Check for specific error codes
      final errorMessage = _authController.errorMessage.value;
      mobileError.value = errorMessage;
      formKey.currentState?.validate();
      return;
    }

    Get.toNamed(
      Routes.VERIFICATION_CODE_BY_LOGIN,
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
