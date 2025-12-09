import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../helper_widgets/back_button.dart';
import '../../services/app_routes.dart';

class PersonalDetails1Screen extends StatelessWidget {
  const PersonalDetails1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 27.h, left: 20.w),
              child: SizedBox(
                width: 350.w,
                height: 20.h,
                child: Center(
                  child: Text(
                    'Personal details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w400,
                      fontSize: 20.sp,
                      letterSpacing: 0,
                      color: AppColors.white,
                      height: 1,
                    ),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16.h,
              left: 339.w,
              child: CustomBackButton(
                rotation: 0,
                onTap: () {
                  AppRoutes.pop();
                },
              ),
            ),
            Positioned(
              top: 72.h,
              left: 116.5.w,
              child: SizedBox(
                width: 157.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 105.4310531616211.w,
                      height: 105.4310531616211.h,
                      decoration: BoxDecoration(
                        color: AppColors.uploadImageBackground,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 19.h),
                            blurRadius: 23.r,
                            spreadRadius: 0,
                            color: AppColors.uploadImageShadow,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: AppColors.white,
                          size: 32.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: 137.w,
                      height: 14.h,
                      child: Center(
                        child: Text(
                          'addProfilePicture'.tr,
                          textAlign: TextAlign.center,
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
