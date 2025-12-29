import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../constants/app_button.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import 'event_tablet.dart';

class EventBuyingBottomBarModal extends StatelessWidget {
  final String title;
  final String description;
  final String? points;
  final String? date;
  final String? timing;
  final String? text;
  final VoidCallback? onButtonTap;
  final EdgeInsets? extraPaddingForButton;

  const EventBuyingBottomBarModal({
    super.key,
    required this.title,
    this.points,
    this.date,
    this.timing,
    required this.description,
    this.text,
    this.onButtonTap,
    this.extraPaddingForButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            EventTablet(
              widget: Text(
                date ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  letterSpacing: 0,
                  color: AppColors.white,
                ),
              ),
              extraPadding: EdgeInsets.symmetric(vertical: -2.5.w),
              onTap: () {},
            ),
            SizedBox(width: 8),
            EventTablet(
              widget: Text(
                timing ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                  letterSpacing: 0,
                  color: AppColors.white,
                ),
              ),
              extraPadding: EdgeInsets.symmetric(vertical: -2.5.w),
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            height: 24 / 16,
            letterSpacing: 0,
            color: AppColors.textWhite,
          ),
        ),
        // Description
        Text(
          description,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontSize: 14.sp,
            height: 22 / 14,
            letterSpacing: 0,
            color: AppColors.textWhite,
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            EventTablet(
              widget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    child: SvgPicture.asset(
                      AppImages.pointsIcon,
                      width: 18.w,
                      height: 18.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    "${'homePoints'.tr} $points",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      letterSpacing: 0,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              extraPadding: EdgeInsets.symmetric(vertical: -2.5.w),
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Center(
          child: AppButton(
            onTap: onButtonTap,
            text: 'registration'.tr,
            width: double.infinity,
            height: 48.h,
          ),
        ),
      ],
    );
  }
}



class RegistrationSuccessModal extends StatelessWidget {
  final String title;
  final String text;
  final String icon;
  final String description;
  final VoidCallback? onButtonTap;
  final EdgeInsets? extraPaddingForButton;

  const RegistrationSuccessModal({
    super.key,
    required this.title,
    required this.text,
    required this.icon,
    required this.description,
    this.onButtonTap,
    this.extraPaddingForButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        SvgPicture.asset(
          icon,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            height: 24 / 16,
            letterSpacing: 0,
            color: AppColors.textWhite,
          ),
        ),
        SizedBox(height: 10),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontSize: 14.sp,
            height: 22 / 14,
            letterSpacing: 0,
            color: AppColors.textWhite,
          ),
        ),
        SizedBox(height: 20.h),
        Center(
          child: AppButton(
            onTap: onButtonTap,
            text: text,
            width: double.infinity,
            height: 48.h,
          ),
        ),
      ],
    );
  }
}
