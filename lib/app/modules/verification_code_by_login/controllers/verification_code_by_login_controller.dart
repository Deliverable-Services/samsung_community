import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final supabase = Supabase.instance.client;

  RealtimeChannel? _userStatusChannel;
  String? _currentUserStatus;
  bool _isDialogOpen = false;

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

  Future<void> stopUserStatusListener() async {
    if (_userStatusChannel != null) {
      debugPrint('🛑 Stop user status listener');
      await supabase.removeChannel(_userStatusChannel!);
      _userStatusChannel = null;
    }
  }

  Future<void> startUserStatusListener() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    debugPrint('👂 Listening user status for: $userId');

    _userStatusChannel = supabase
        .channel('user-status-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) async {
            final newStatus = payload.newRecord['status'] as String?;
            if (newStatus == null) return;

            _currentUserStatus = newStatus;
            debugPrint('🔔 Status changed → $newStatus');

            // ✅ Approved
            if (newStatus == 'approved') {
              if (_isDialogOpen) {
                _isDialogOpen = false;
                Get.back();
              }
              return;
            }

            // ❌ Pending / Rejected / 'suspended'
            if ((newStatus == 'pending' ||
                    newStatus == 'rejected' ||
                    newStatus == 'suspended') &&
                !_isDialogOpen) {
              _isDialogOpen = true;

              await Get.dialog(
                CupertinoAlertDialog(
                  title: Text('accountNotApproved'.tr),
                  content: Text(
                    "${'yourAccountIsNotApprovedYet'.tr}\n\n${'pleaseWaitForAdminApprovalOrContactSupport'.tr}",
                  ),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: const Text('OK'),
                      onPressed: () async {
                        _isDialogOpen = false;

                        if (_currentUserStatus != 'approved') {
                          Get.back();
                          await _performLogout();
                        }
                      },
                    ),
                  ],
                ),
                barrierDismissible: false,
              );
            }
          },
        )
        .subscribe();
  }

  Future<void> _performLogout() async {
    try {
      final authRepo = Get.find<AuthRepo>();
      await stopUserStatusListener();
      await authRepo.signOut();
    } catch (e) {
      debugPrint('Error during logout: $e');
      Get.offAllNamed(Routes.LOGIN);
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
    _initFCM();
    await startUserStatusListener();
    Get.offAllNamed(Routes.BOTTOM_BAR);
  }

  Future<void> _initFCM() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    final token = await messaging.getToken();
    if (token != null) {
      await AuthRepo().saveOrUpdatePushToken(
        fcmToken: token,
        platform: Platform.isAndroid ? 'android' : 'ios',
        deviceId: '',
      );
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      AuthRepo().saveOrUpdatePushToken(
        fcmToken: newToken,
        platform: Platform.isAndroid ? 'android' : 'ios',
        deviceId: '',
      );
    });
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
