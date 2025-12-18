import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/custom_text_field.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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
                    SizedBox(height: 73.h),
                    Form(
                      key: controller.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            controller.mobileError.value;
                            return CustomTextField(
                              label: 'mobile_number'.tr,
                              controller: controller.mobileController,
                              keyboardType: TextInputType.phone,
                              placeholder: 'type'.tr,
                              validator: (value) {
                                // Only validate if button has been clicked
                                if (!controller.hasValidated.value) return null;

                                final validationError = controller
                                    .validatePhone(value);
                                if (validationError != null) {
                                  return validationError;
                                }
                                // Return custom error if user doesn't exist
                                return controller.mobileError.value;
                              },
                            );
                          }),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 710.h,
                left: 20.w,
                child: Obx(
                  () => AppButton(
                    onTap: controller.isValidating.value
                        ? null
                        : controller.handleLogin,
                    text: controller.isValidating.value
                        ? 'checking'.tr
                        : 'getVerificationCode'.tr,
                    width: 350.w,
                    height: 48.h,
                    isEnabled: !controller.isValidating.value,
                  ),
                ),
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
