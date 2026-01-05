import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';

class EventRegistrationSuccessModal extends StatelessWidget {
  const EventRegistrationSuccessModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20.h),
        SvgPicture.asset(
          AppImages.icVerify,
          width: 64.w,
          height: 64.h,
        ),
        SizedBox(height: 20.h),
        Text(
          'Registration Successful',
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          "You're successfully registered for\nthe event.",
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w400,
            fontSize: 16.sp,
            color: AppColors.textWhiteOpacity60,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),
        AppButton(
          text: 'Close',
          onTap: () => Get.back(),
          width: double.infinity,
          height: 56.h,
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
