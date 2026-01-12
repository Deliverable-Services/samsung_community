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
        SvgPicture.asset(AppImages.icVerify, width: 64.w, height: 64.h),
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

class EventCancellationSuccessModal extends StatelessWidget {
  const EventCancellationSuccessModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20.h),
        SvgPicture.asset(AppImages.icVerify, width: 64.w, height: 64.h),
        SizedBox(height: 20.h),
        Text(
          'Registration Cancelled',
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
          "Your registration has been\ncancelled for the event.",
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

class CancelEventConfirmationModal extends StatelessWidget {
  final VoidCallback? onConfirm;
  final bool isLoading;

  const CancelEventConfirmationModal({
    super.key,
    this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20.h),
        SvgPicture.asset(AppImages.icFailed, width: 50.w, height: 50.h),
        SizedBox(height: 20.h),
        Text(
          'Cancel Event',
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
          'Are you sure you want to cancel\nyour registration for this event?',
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w400,
            fontSize: 16.sp,
            color: AppColors.textWhiteOpacity60,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Cancel',
                iconPath: AppImages.cancelEventIcon,
                iconSize: 16.h,
                onTap: () => Get.back(),
                width: double.infinity,
                // height: 56.h,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AppButton(
                text: 'Confirm',
                iconPath: AppImages.confirmIcon,
                iconSize: 16.h,
                onTap: onConfirm,
                isLoading: isLoading,
                width: double.infinity,
                // height: 56.h,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
