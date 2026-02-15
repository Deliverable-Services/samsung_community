import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../common/services/analytics_service.dart';
import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../../on_boarding/controllers/on_boarding_controller.dart';
import '../../verification_code/controllers/verification_code_controller.dart';

class LoginOptionsView extends GetView<VerificationCodeController> {
  const LoginOptionsView({super.key});

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
          child: Padding(
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
                SizedBox(height: 72.h),
                AppButton(
                  onTap: (controller.isLoading.value)
                      ? null
                      : () {
                          controller.clickOnSignUpWithGoogleButton();
                        },
                  text: 'signUpWithGoogle'.tr,
                  width: 350.w,
                  height: 48.h,
                  isEnabled: !controller.isLoading.value,
                  iconPath: AppImages.googleIcon,
                  iconSize: 20.w,
                ),
                SizedBox(height: 10.h),
                AppButton(
                  onTap: () {
                    userData.value = {};
                    Get.offNamed(
                      Routes.PERSONAL_DETAILS,
                      parameters: {'phoneNumber': controller.phoneNumber.value},
                    );
                  },
                  text: 'Continue with e-mail'.tr,
                  width: 350.w,
                  height: 48.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
