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
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Log screen view when screen appears
    AnalyticsService.trackScreenView(
      screenName: 'Login screen enter phone',
      screenClass: 'LoginView',
    );

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
                          'loginDescription'.tr,
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
                    SizedBox(height: 73.h),
                    Form(
                      key: controller.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: 'mobile_number'.tr,
                            controller: controller.mobileController,
                            keyboardType: TextInputType.phone,
                            placeholder: 'type'.tr,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              // Only validate if button has been clicked
                              if (!controller.hasValidated.value) return null;

                              return controller.validatePhone(value);
                            },
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 690.h,
                left: 20.w,
                child: Obx(
                  () => AppButton(
                    onTap: controller.isValidating.value
                        ? null
                        : () {
                            // Log button click event
                            AnalyticsService.logButtonClick(
                              screenName: 'Login screen enter phone',
                              buttonName: 'Get verification code',
                              eventName: 'login_enter_phone_click',
                            );
                            controller.handleLogin();
                          },
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
                top: 768.h,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    child: Obx(() {
                      final disabled = controller.isValidating.value;
                      final baseColor = AppColors.linkBlue.withOpacity(
                        disabled ? 0.6 : 1.0,
                      );
                      return GestureDetector(
                        onTap: disabled
                            ? null
                            : () {
                                AnalyticsService.logButtonClick(
                                  screenName: 'Login screen enter phone',
                                  buttonName: 'signup',
                                  eventName: 'login_enter_phone_click',
                                );
                                Get.toNamed(Routes.SIGN_UP);
                              },
                        child: Text(
                          '${'dontHaveAccount'.tr}${'signUp'.tr}',
                          textScaler: const TextScaler.linear(1.0),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            letterSpacing: 0,
                            color: baseColor,
                            height: 24 / 16,
                            fontFamily: 'Samsung Sharp Sans',
                          ),
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
