import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../common/services/analytics_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/constants/language_options.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/option_item.dart';
import '../../../data/localization/language_controller.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../../on_boarding/controllers/on_boarding_controller.dart';

class VerificationCodeController extends GetxController {
  final count = 0.obs;
  final formKey = GlobalKey<FormState>();
  final verificationCodeController = TextEditingController();
  final authRepo = Get.find<AuthRepo>();
  final selectedLanguageId = ''.obs;
  final phoneNumber = ''.obs;
  final isResending = false.obs;
  final isVerifying = false.obs;
  final isLoading = false.obs;
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

  Future<void> clickOnSignUpWithGoogleButton() async {
    const webClientId =
        '750436578430-gd5c9nh6cndglhsn9u0rjslnurbdk61m.apps.googleusercontent.com';
    const iosClientId = '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';

    final scopes = ['email', 'profile'];

    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      serverClientId: webClientId,
      clientId: iosClientId,
    );

    final googleUser = await googleSignIn.authenticate();

    final idToken = googleUser.authentication.idToken;

    if (idToken == null) {
      debugPrint('No ID token found');
      return;
    }
    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
        await googleUser.authorizationClient.authorizeScopes(scopes);

    final accessToken = authorization.accessToken;

    AuthResponse response = await Supabase.instance.client.auth
        .signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

    UserIdentity? identityData = response.user?.identities
        ?.where((element) => element.userId == response.user?.id)
        .first;

    userData.value = {
      'id': response.user?.id,
      'email': response.user?.email,
      'name': identityData?.identityData?['full_name'],
      'photoUrl': identityData?.identityData?['avatar_url'],
    };

    Get.offNamed(
      Routes.PERSONAL_DETAILS,
      parameters: {'phoneNumber': phoneNumber.value},
    );

    debugPrint('response user email :::  ${response.user?.email}');
    debugPrint('response user id :::  ${response.user?.id}');
    debugPrint(
      'response user identities full_name:::  ${identityData?.identityData?['full_name']}',
    );
    debugPrint(
      'response user identities avatar_url:::  ${identityData?.identityData?['avatar_url']}',
    );
  }

  /*
  void clickOnSignUpWithGoogleButton1() async {
    final supabase = Supabase.instance.client;

    /// TODO: update the Web client ID with your own.
    ///
    /// Web Client ID that you registered with Google Cloud.
    const webClientId =
        '420519811486-vrrntteo6nbh4kbrocl4ogk3u8v2bctc.apps.googleusercontent.com';
    const iosClientId = 'my-ios.apps.googleusercontent.com';
    final GoogleSignIn signIn = GoogleSignIn.instance;
    unawaited(
      signIn.initialize(clientId: iosClientId, serverClientId: webClientId),
    );
    final googleAccount = await signIn.authenticate();
    final googleAuthentication = googleAccount.authentication;
    final idToken = googleAuthentication.idToken;
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    userData.value = {
      'id': googleAccount.id,
      'email': googleAccount.email,
      'name': googleAccount.displayName,
      'photoUrl': googleAccount.photoUrl,
    };

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    Get.offNamed(
      Routes.PERSONAL_DETAILS,
      parameters: {'phoneNumber': phoneNumber.value},
    );
  }
*/

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
      otpError.value = 'verificationCode'.tr + ' is_required'.tr;
      formKey.currentState?.validate();
      return;
    }

    isVerifying.value = true;

    // Verify OTP (for signup, we only verify, don't sign in)
    final isValid = await verifyOTP(
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

  Future<bool> verifyOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    print({
      'phoneNumber': phoneNumber,
      'otp': otpCode,
    });
    final response = await SupabaseService.client.functions.invoke(
      'update_signup_data',
      body: {
        'phoneNumber': phoneNumber,
        'otp': otpCode,
      },
    );

    if (response.data == null) return false;

    await SupabaseService.client.auth.setSession(
      //response.data['access_token'],
      response.data['refresh_token'],
    );

    return true;
  }


  void _showLanguageSelector() {
    // Log screen view when language selector appears
    AnalyticsService.logScreenView(
      screenName: 'signup screen choose language',
      screenClass: 'LanguageSelectorModal',
    );

    BottomSheetModal.show(
      Get.context!,
      content: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageOptions.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isLast = index == LanguageOptions.options.length - 1;
            // Map language ID to button name for analytics
            final buttonName = option.id == 'en' ? 'english' : 'hebrew';
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 10.h : 15.h),
              child: OptionItem(
                text: option.name,
                boxText: option.boxText,
                isSelected: selectedLanguageId.value == option.id,
                onTap: () async {
                  // Log button click event
                  AnalyticsService.logButtonClick(
                    screenName: 'signup screen choose language',
                    buttonName: buttonName,
                    eventName: 'signup_choose_language_click',
                  );
                  selectedLanguageId.value = option.id;

                  if (phoneNumber.value.isNotEmpty) {
                    // Save language preference
                    final success = await authRepo.saveProfile(
                      phoneNumber: phoneNumber.value,
                      profileData: {'languagePreference': option.id},
                    );

                    if (!success) {
                      final errorMessage = authRepo.errorMessage.value;
                      CommonSnackbar.error(
                        errorMessage.isNotEmpty
                            ? errorMessage
                            : 'failed_to_save_language_preference'.tr,
                      );
                      return;
                    }
                  }

                  final languageController = Get.find<LanguageController>();
                  languageController.changeLanguage(option.id);
                  Get.back();
                  Get.toNamed(Routes.LOGIN_OPTIONS);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
