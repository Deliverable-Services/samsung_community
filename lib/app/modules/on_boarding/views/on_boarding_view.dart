import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            Image(
              image: AssetImage(AppImages.imageOnBoarding),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            SafeArea(
              top: true,
              bottom: true,
              child: Align(
                alignment: const AlignmentDirectional(0, 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .66,
                      ),
                      SizedBox(
                        width: 313.w,
                        height: 32.h,
                        child: Center(
                          child: Text(
                            'welcomeDescription'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
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
                      SizedBox(height: 90.h),
                      AppButton(
                        onTap: () => controller.clickOnSignUpWithGoogleButton(),
                        text: 'Sign up with google'.tr,
                      ),
                      SizedBox(height: 30.h),
                      AppButton(
                        onTap: () {
                          AnalyticsService.logButtonClick(
                            screenName: 'Main screen',
                            buttonName: 'Login',
                            eventName: 'main_screen_click',
                          );
                          controller.clickOnLogInButton();
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
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
