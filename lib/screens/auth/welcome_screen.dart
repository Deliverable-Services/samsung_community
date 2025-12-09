import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:samsung_community/constants/app_colors.dart';

import '../../constants/app_button.dart';
import '../../constants/app_images.dart';
import '../../services/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldDark,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 390.w,
                  height: 585.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50.r),
                      bottomRight: Radius.circular(50.r),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.welcomeGradientStart,
                        AppColors.welcomeGradientEnd,
                      ],
                      stops: [0.0, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.welcomeContainerShadow,
                        offset: Offset(0, 7.43.h),
                        blurRadius: 16.6.r,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 390.w,
                    height: 585.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 107.h,
                          left: 95.w,
                          child: SizedBox(
                            width: 200.w,
                            height: 58.h,
                            child: Center(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'welcomeToOur'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
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
                                        fontFamily: 'Rubik',
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
                          top: 259.55.h,
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
                          fontFamily: 'Rubik',
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
                  onTap: () => AppRoutes.go(AppRouteName.loginScreen),
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
                          fontFamily: 'Rubik',
                          color: AppColors.linkBlue,
                          letterSpacing: 0,
                          fontSize: 16.sp,
                        ),
                      ),
                      TextSpan(
                        text: 'signUp'.tr,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: AppColors.linkBlue,
                          fontSize: 16.sp,
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            AppRoutes.go(AppRouteName.signUpScreen);
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
