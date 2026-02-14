import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../repository/auth_repo/auth_repo.dart';

class LoginController extends BaseController {
  final count = 0.obs;

  final formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();

  final isValidating = false.obs;
  final hasValidated = false.obs;

  final _authRepo = Get.find<AuthRepo>();

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

  Future<void> handleLogin() async {
    hasValidated.value = true;

    if (!(formKey.currentState?.validate() ?? false)) {
      final phoneError = validatePhone(mobileController.text);
      if (phoneError != null) {
        CommonSnackbar.error(phoneError);
      }
      return;
    }

    isValidating.value = true;

    final phoneNumber = mobileController.text.trim();
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');


    final otpCode = await AuthRepo().callLoginApi(phoneNumber: normalizedPhone);


    // final userExists = await _authRepo.checkUserExists(normalizedPhone);
    // if (!userExists) {
    //   isValidating.value = false;
    //   CommonSnackbar.error('user_not_found'.tr);
    //   return;
    // }
    //
    // final otpCode = await _authRepo.generateOTPForLogin(normalizedPhone);

    isValidating.value = false;

    if (otpCode == null) {
      final errorMessage = _authRepo.errorMessage.value;
      _authRepo.clearError();
      if (errorMessage.isNotEmpty) {
        CommonSnackbar.error(errorMessage);
      } else {
        CommonSnackbar.error('failedToGenerateVerificationCode'.tr);
      }
      return;
    }

    Get.toNamed(
      Routes.VERIFICATION_CODE_BY_LOGIN,
      parameters: {'phoneNumber': normalizedPhone},
    );
  }

  void increment() => count.value++;
}
