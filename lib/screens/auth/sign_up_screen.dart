import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constants/app_button.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_images.dart';
import '../../constants/language_options.dart';
import '../../helper_widgets/back_button.dart';
import '../../helper_widgets/custom_text_field.dart';
import '../../helper_widgets/option_item.dart';
import '../../services/app_routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showOverlay = false;
  String? _selectedLanguageId;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                          'signUpDescription'.tr,
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
                  ],
                ),
              ),
              Positioned(
                top: 354.h,
                left: 20.w,
                child: SizedBox(
                  width: 350.w,
                  child: Form(
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
                        SizedBox(height: 40.h),
                        CustomTextField(
                          label: 'confirmPassword'.tr,
                          controller: _confirmPasswordController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          placeholder: 'type'.tr,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 750.h,
                left: 20.w,
                child: AppButton(
                  onTap: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      setState(() {
                        _showOverlay = true;
                      });
                    }
                  },
                  text: 'signUp'.tr,
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
                    child: RichText(
                      textScaler: const TextScaler.linear(1.0),
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'alreadyHaveAccount'.tr,
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
                            text: 'logIn'.tr,
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
                                AppRoutes.go(AppRouteName.loginScreen);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_showOverlay)
                Positioned.fill(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showOverlay = false;
                          });
                        },
                        child: Container(
                          width: 390.w,
                          height: 844.h,
                          color: AppColors.overlayBackground,
                        ),
                      ),
                      Positioned(
                        top: 761.h,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 390.w,
                            height: 144.h,
                            decoration: BoxDecoration(
                              color: AppColors.overlayContainerBackground,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, -6.h),
                                  blurRadius: 50.r,
                                  spreadRadius: 0,
                                  color: AppColors.overlayContainerShadow,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.only(top: 14.w, right: 20.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 19.h),
                                  child: SizedBox(
                                    width: 149.w,
                                    height: 78.h,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: LanguageOptions.options
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final index = entry.key;
                                            final option = entry.value;
                                            final isLast =
                                                index ==
                                                LanguageOptions.options.length -
                                                    1;
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: isLast ? 0 : 30.h,
                                              ),
                                              child: OptionItem(
                                                text: option.name,
                                                isSelected:
                                                    _selectedLanguageId ==
                                                    option.id,
                                                onTap: () {
                                                  setState(() {
                                                    _selectedLanguageId =
                                                        option.id;
                                                  });
                                                  AppRoutes.go(
                                                    AppRouteName
                                                        .personalDetails1,
                                                  );
                                                },
                                              ),
                                            );
                                          })
                                          .toList(),
                                    ),
                                  ),
                                ),
                                CustomBackButton(
                                  onTap: () {
                                    setState(() {
                                      _showOverlay = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
