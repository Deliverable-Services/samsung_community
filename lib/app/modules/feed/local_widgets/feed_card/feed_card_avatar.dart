import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:samsung_community_mobile/app/data/constants/app_colors.dart';

import '../../../../data/constants/app_images.dart';

class FeedCardAvatar extends StatelessWidget {
  final String? authorAvatar;
  final VoidCallback? onTap;

  const FeedCardAvatar({super.key, this.authorAvatar, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 57.h,
        height: 57.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textWhiteOpacity70, width: 1.w),
          borderRadius: BorderRadius.circular(100),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: authorAvatar?.isNotEmpty == true
              ? CachedNetworkImage(
                  imageUrl: authorAvatar!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Image.asset(
                    AppImages.avatar,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              // : Image.asset(
              //     AppImages.avatar,
              //     width: double.infinity,
              //     height: double.infinity,
              //     fit: BoxFit.cover,
              //   ),
              : Icon(
                  Icons.person,
                  color: AppColors.textWhiteOpacity70,
                  size: 24.sp,
                ),
        ),
      ),
    );
  }
}
