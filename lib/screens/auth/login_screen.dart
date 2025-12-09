import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constants/app_button.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../../helper_widgets/custom_text_field.dart';
import '../../services/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 56.h),
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
                    SizedBox(height: 73.h),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: 'mobile_number'.tr,
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            placeholder: 'type'.tr,
                          ),
                          SizedBox(height: 40.h),
                          CustomTextField(
                            label: 'password'.tr,
                            controller: _passwordController,
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            placeholder: 'type'.tr,
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: 350.w,
                            child: Text(
                              'forgotPassword'.tr,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                                letterSpacing: 0,
                                color: AppColors.linkBlue,
                                height: 1,
                              ),
                              textScaler: const TextScaler.linear(1.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 750.h,
                left: 20.w,
                child: AppButton(
                  onTap: () {
                    if (_formKey.currentState?.validate() ?? false) {}
                  },
                  text: 'logIn'.tr,
                  width: 350.w,
                  height: 48.h,
                ),
              ),
              Positioned(
                top: 828.h,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 237.w,
                    child: RichText(
                      textScaler: const TextScaler.linear(1.0),
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'dontHaveAccount'.tr,
                            style: TextStyle(
                              fontFamily: 'Rubik',
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
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              letterSpacing: 0,
                              color: AppColors.linkBlue,
                              height: 24 / 16,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                AppRoutes.go(AppRouteName.signUpScreen);
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
