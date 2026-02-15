import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../common/services/analytics_service.dart';
import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/constants/language_options.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/option_item.dart';
import '../../../data/localization/language_controller.dart';
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
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 16.h, right: 16.w),
                  child: GestureDetector(
                    onTap: () => _showLanguageSelector(context),
                    child: SvgPicture.asset(
                      AppImages.languageIcon,
                      width: 28.w,
                      height: 28.w,
                    ),
                  ),
                ),
              ),
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
                    SizedBox(height: MediaQuery.of(context).size.height * .66),
                    SizedBox(
                      width: 313.w,
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
                            fontFamily: 'Samsung Sharp Sans',
                          ),
                          textScaler: const TextScaler.linear(1.0),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                    SizedBox(height: 25.h),
                    AppButton(
                      onTap: () => controller.clickOnSignUpWithGoogleButton(),
                      text: 'signUpWithGoogle'.tr,
                      iconPath: AppImages.googleIcon,
                      iconSize: 20.w,
                    ),
                    SizedBox(height: 20.h),
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
                    SizedBox(height: 20.h),
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
                              fontFamily: 'Samsung Sharp Sans',
                            ),
                          ),
                          TextSpan(
                            text: 'signUp'.tr,
                            style: TextStyle(
                              color: AppColors.linkBlue,
                              fontSize: 16.sp,
                              letterSpacing: 0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Samsung Sharp Sans',
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
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

  void _showLanguageSelector(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    BottomSheetModal.show(
      context,
      content: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageOptions.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isLast = index == LanguageOptions.options.length - 1;
            final isSelected =
                languageController.currentLocale == option.locale;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 10.h : 15.h),
              child: OptionItem(
                text: option.name,
                boxText: option.boxText,
                isSelected: isSelected,
                onTap: () {
                  languageController.changeLanguage(option.id);
                  Get.back();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
