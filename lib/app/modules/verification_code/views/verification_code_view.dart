import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';
import 'package:flutter_svg/svg.dart';
import '../../../common/services/analytics_service.dart';
import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../controllers/verification_code_controller.dart';

class VerificationCodeView extends GetView<VerificationCodeController> {
  const VerificationCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Log screen view when screen appears
    AnalyticsService.trackScreenView(
      screenName: 'signup screen verification code',
      screenClass: 'VerificationCodeView',
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: TitleAppBar(text: "", isLeading: false),
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
                      padding: EdgeInsets.only(top: 10.h),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: SvgPicture.asset(
                            AppImages.logo,
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
                                  fontFamily: 'Samsung Sharp Sans',
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
                                  fontFamily: 'Samsung Sharp Sans',
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
                    SizedBox(height: 40.h),
                    SizedBox(
                      width: 304.w,
                      height: 32.h,
                      child: Center(
                        child: Text(
                          'signUpDescription'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                            color: AppColors.white,
                            height: 22 / 14,
                            fontFamily: 'Samsung Sharp Sans',
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
              Positioned(
                top: 304.h,
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (value) {
                            if (controller.otpError.value.isNotEmpty) {
                              return controller.otpError.value;
                            }
                            if (value == null || value.trim().isEmpty) {
                              return 'verificationCode'.tr + ' is_required'.tr;
                            }
                            return null;
                          },
                          onChanged: (value) {
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
                                      text: '${'otp_sent'.tr} ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12.sp,
                                        height: 22 / 14,
                                        letterSpacing: 0,
                                        color: AppColors.white.withOpacity(0.7),
                                        fontFamily: 'Samsung Sharp Sans',
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '${controller.resendCountdown.value}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.sp,
                                        height: 22 / 14,
                                        letterSpacing: 0,
                                        color: AppColors.linkBlue,
                                        fontFamily: 'Samsung Sharp Sans',
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
                                        fontFamily: 'Samsung Sharp Sans',
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                textScaler: const TextScaler.linear(1.0),
                              );
                            } else {
                              return Obx(
                                () => GestureDetector(
                                  onTap:
                                      (controller.isResending.value ||
                                          controller.resendCountdown.value > 0)
                                      ? null
                                      : () {
                                          // Log button click event
                                          AnalyticsService.logButtonClick(
                                            screenName:
                                                'signup screen verification code',
                                            buttonName:
                                                'Resend verification code',
                                            eventName:
                                                'signup_verification_code_click',
                                          );
                                          controller.handleResendCode();
                                        },
                                  child: Opacity(
                                    opacity:
                                        (controller.isResending.value ||
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
                                        fontFamily: 'Samsung Sharp Sans',
                                      ),
                                      textScaler: const TextScaler.linear(1.0),
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 660.h,
                left: 20.w,
                child: AppButton(
                  onTap:
                      (controller.isVerifying.value || !controller.isFormValid)
                      ? null
                      : () {
                          // Log button click event
                          AnalyticsService.logButtonClick(
                            screenName: 'signup screen verification code',
                            buttonName: 'signup',
                            eventName: 'signup_verification_code_click',
                          );
                          controller.handleSignUp();
                        },
                  text: controller.isVerifying.value
                      ? 'verifying'.tr
                      : 'signUp'.tr,
                  width: 350.w,
                  height: 48.h,
                  isEnabled:
                      !controller.isVerifying.value && controller.isFormValid,
                ),
              ),
              Positioned(
                top: 738.h,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    child: Obx(() {
                      final disabled =
                          controller.isVerifying.value ||
                          controller.isResending.value;
                      final baseColor = AppColors.linkBlue.withOpacity(
                        disabled ? 0.6 : 1.0,
                      );
                      return RichText(
                        textScaler: const TextScaler.linear(1.0),
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'alreadyHaveAccount'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16.sp,
                                letterSpacing: 0,
                                color: baseColor,
                                height: 24 / 16,
                                fontFamily: 'Samsung Sharp Sans',
                              ),
                            ),
                            TextSpan(
                              text: 'logIn'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                letterSpacing: 0,
                                color: baseColor,
                                height: 24 / 16,
                                fontFamily: 'Samsung Sharp Sans',
                              ),
                              recognizer: disabled
                                  ? null
                                  : (TapGestureRecognizer()
                                      ..onTap = () {
                                        AnalyticsService.logButtonClick(
                                          screenName:
                                              'signup screen verification code',
                                          buttonName: 'login',
                                          eventName:
                                              'signup_verification_code_click',
                                        );
                                        Get.toNamed(Routes.LOGIN);
                                      }),
                            ),
                          ],
                        ),
                      );
                    }),
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
