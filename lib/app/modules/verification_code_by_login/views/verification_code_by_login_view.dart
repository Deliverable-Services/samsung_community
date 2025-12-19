import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../controllers/verification_code_by_login_controller.dart';

class VerificationCodeByLoginView
    extends GetView<VerificationCodeByLoginController> {
  const VerificationCodeByLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 36.h),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.asset(
                            AppImages.appLogo,
                            width: 84.w,
                            height: 78.h,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 26.h),
                    SizedBox(
                      width: 304.w,
                      height: 58.h,
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'welcomeToOur'.tr,
                                style: TextStyle(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0,
                                  color: AppColors.white,
                                  height: 40 / 26,
                                ),
                              ),
                              TextSpan(
                                text: 'sCommunity'.tr,
                                style: TextStyle(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
                                  color: AppColors.white,
                                  height: 40 / 30,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          textScaler: const TextScaler.linear(1.0),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    SizedBox(
                      width: 304.w,
                      height: 32.h,
                      child: Center(
                        child: Text(
                          'loginDescription'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                            color: AppColors.white,
                            height: 22 / 14,
                          ),
                          textScaler: const TextScaler.linear(1.0),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                controller.count.value;
                return Positioned(
                  top: 334.h,
                  left: 20.w,
                  child: SizedBox(
                    width: 350.w,
                    child: Form(
                      key: controller.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: 'verificationCode'.tr,
                            controller: controller.verificationCodeController,
                            keyboardType: TextInputType.number,
                            placeholder: 'type'.tr,
                            validator: (value) {
                              if (controller.otpError.value.isNotEmpty) {
                                return controller.otpError.value;
                              }
                              if (value == null || value.trim().isEmpty) {
                                return 'verificationCode'.tr + ' is required';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Clear error and update button state when user types
                              if (controller.otpError.value.isNotEmpty) {
                                controller.otpError.value = '';
                              }
                            },
                          ),
                          SizedBox(height: 16.h),
                          Center(
                            child: Obx(() {
                              if (controller.resendCountdown.value > 0) {
                                return Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'otp_sent'.tr + ' ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp,
                                          height: 22 / 14,
                                          letterSpacing: 0,
                                          color: AppColors.white.withOpacity(0.7),
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${controller.resendCountdown.value}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.sp,
                                          height: 22 / 14,
                                          letterSpacing: 0,
                                          color: AppColors.linkBlue,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' ${'seconds'.tr}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp,
                                          height: 22 / 14,
                                          letterSpacing: 0,
                                          color: AppColors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                  textScaler: const TextScaler.linear(1.0),
                                );
                              } else {
                                return Obx(() => GestureDetector(
                                      onTap: (controller.isResending.value ||
                                              controller.resendCountdown.value > 0)
                                          ? null
                                          : controller.handleResendCode,
                                      child: Opacity(
                                        opacity: (controller.isResending.value ||
                                                controller.resendCountdown.value >
                                                    0)
                                            ? 0.5
                                            : 1.0,
                                        child: Text(
                                          'resendVerificationCode'.tr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.sp,
                                            height: 22 / 14,
                                            letterSpacing: 0,
                                            color: AppColors.linkBlue,
                                          ),
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                        ),
                                      ),
                                    ));
                              }
                            }),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Positioned(
                top: 710.h,
                left: 20.w,
                child: Obx(() {
                  controller.count.value;
                  return AppButton(
                    onTap:
                        (controller.isVerifying.value ||
                            !controller.isFormValid)
                        ? null
                        : controller.handleApproval,
                    text: controller.isVerifying.value
                        ? 'verifying'.tr
                        : 'approval'.tr,
                    width: 350.w,
                    height: 48.h,
                    isEnabled:
                        !controller.isVerifying.value && controller.isFormValid,
                  );
                }),
              ),
              Positioned(
                top: 788.h,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    child: RichText(
                      textScaler: const TextScaler.linear(1.0),
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'dontHaveAccount'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              letterSpacing: 0,
                              color: AppColors.linkBlue,
                              height: 24 / 16,
                            ),
                          ),
                          TextSpan(
                            text: 'signUp'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              letterSpacing: 0,
                              color: AppColors.linkBlue,
                              height: 24 / 16,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed(Routes.SIGN_UP);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
