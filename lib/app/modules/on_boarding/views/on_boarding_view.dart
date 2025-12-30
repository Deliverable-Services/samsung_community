import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../common/services/analytics_service.dart';
import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../controllers/on_boarding_controller.dart';

class OnBoardingView extends GetView<OnBoardingController> {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Log screen view when screen appears
    AnalyticsService.trackScreenView(
      screenName: 'Main screen',
      screenClass: 'OnBoardingView',
    );
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            SizedBox(
              width: 390.w,
              height: 585.h,
              child: Image.asset(AppImages.tintBackground2, fit: BoxFit.cover),
            ),
            // Content
            SafeArea(
              top: true,
              bottom: true,
              child: Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 390.w,
                      height: 545.h,
                      child: SizedBox(
                        width: 390.w,
                        height: 585.h,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: 67.h,
                              left: 95.w,
                              child: SizedBox(
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
                                    overflow: TextOverflow.visible,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 239.55.h,
                              left: 35.w,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24.r),
                                child: Image(
                                  image: AssetImage(AppImages.appLogo),
                                  width: 266.w,
                                  height: 248.h,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 43.h),
                    Padding(
                      padding: EdgeInsets.only(),
                      child: SizedBox(
                        width: 313.w,
                        height: 32.h,
                        child: Center(
                          child: Text(
                            'welcomeDescription'.tr,
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
                    ),
                    SizedBox(height: 90.h),
                    AppButton(
                      onTap: () {
                        // Log button click event
                        AnalyticsService.logButtonClick(
                          screenName: 'Main screen',
                          buttonName: 'Login',
                          eventName: 'main_screen_click',
                        );
                        Get.toNamed(Routes.LOGIN);
                      },
                      text: 'logIn'.tr,
                    ),
                    SizedBox(height: 30.h),
                    RichText(
                      textScaler: const TextScaler.linear(1.0),
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'dontHaveAccount'.tr,
                            style: TextStyle(
                              color: AppColors.linkBlue,
                              letterSpacing: 0,
                              fontSize: 16.sp,
                            ),
                          ),
                          TextSpan(
                            text: 'signUp'.tr,
                            style: TextStyle(
                              color: AppColors.linkBlue,
                              fontSize: 16.sp,
                              letterSpacing: 0,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Log button click event
                                AnalyticsService.logButtonClick(
                                  screenName: 'Main screen',
                                  buttonName: 'signup',
                                  eventName: 'main_screen_click',
                                );
                                Get.toNamed(Routes.SIGN_UP);
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
