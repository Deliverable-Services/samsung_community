import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';

class UploadFileField extends StatelessWidget {
  final VoidCallback? onTap;
  final String? iconPath;

  const UploadFileField({super.key, this.onTap, this.iconPath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.inputGradientStart, AppColors.inputGradientEnd],
            stops: [0.0, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.inputShadow,
              offset: Offset(2.w, -2.h),
              blurRadius: 2.r,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: EdgeInsets.only(left: 20.w, right: 6.w),
        child: Row(
          children: [
            // Placeholder text
            Expanded(
              child: Text(
                'uploadFile'.tr,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  letterSpacing: 0,
                  color: AppColors.textWhite,
                  height: 22 / 14,
                ),
              ),
            ),
            // Upload icon button
            Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: AppColors.accentBlue, // Blue square background
                borderRadius: BorderRadius.circular(
                  6.r,
                ), // Slightly rounded corners
              ),
              child: Center(
                child: Image.asset(
                  iconPath ?? AppImages.uploadFileIcon,
                  width: 30.w,
                  height: 30.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
