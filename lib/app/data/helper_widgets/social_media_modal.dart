import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_images.dart';
import 'option_item.dart';

class SocialMediaModal extends StatelessWidget {
  final VoidCallback? onInstagramTap;
  final VoidCallback? onFacebookTap;
  final VoidCallback? onTikTokTap;
  final VoidCallback? onCommunityFeedTap;

  const SocialMediaModal({
    super.key,
    this.onInstagramTap,
    this.onFacebookTap,
    this.onTikTokTap,
    this.onCommunityFeedTap,
  });

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
          },
        ),
        SizedBox(height: 24.h),
        // TikTok Option
        OptionItem(
          boxTextWidget: SvgPicture.asset(
            AppImages.tiktokIcon,
            width: 14.w,
            height: 14.h,
            fit: BoxFit.contain,
          ),
          text: 'tikTok'.tr,
          onTap: () {
            onTikTokTap?.call();
          },
        ),
        SizedBox(height: 24.h),
        // Community Feed Option
        OptionItem(
          boxTextWidget: SvgPicture.asset(
            AppImages.communityFeedIcon,
            width: 14.w,
            height: 14.h,
            fit: BoxFit.contain,
          ),
          text: 'communityFeed'.tr,
          onTap: () {
            onCommunityFeedTap?.call();
          },
        ),
      ],
    );
  }
}
