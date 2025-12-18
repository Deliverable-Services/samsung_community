import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_images.dart';
import 'option_item.dart';

class SocialMediaModal extends StatelessWidget {
  final VoidCallback? onInstagramTap;
  final VoidCallback? onFacebookTap;

  const SocialMediaModal({super.key, this.onInstagramTap, this.onFacebookTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instagram Option
        OptionItem(
          boxTextWidget: Image.asset(
            AppImages.instagramIcon,
            width: 14.w,
            height: 14.h,
            fit: BoxFit.contain,
          ),
          text: 'instagram'.tr,
          onTap: () {
            onInstagramTap?.call();
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        SizedBox(height: 24.h),
        // Facebook Option
        OptionItem(
          boxTextWidget: Image.asset(
            AppImages.facebookIcon,
            width: 14.w,
            height: 14.h,
            fit: BoxFit.contain,
          ),
          text: 'facebook'.tr,
          onTap: () {
            onFacebookTap?.call();
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ],
    );
  }
}
