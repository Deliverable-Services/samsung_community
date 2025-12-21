import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/constants/app_colors.dart';
import '../../../../data/constants/app_images.dart';

class FeedCardAuthorInfo extends StatelessWidget {
  final String authorName;
  final bool isVerified;
  final String publishedDate;

  const FeedCardAuthorInfo({
    super.key,
    required this.authorName,
    this.isVerified = false,
    required this.publishedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isVerified) ...[
                Image.asset(
                  AppImages.verifiedProfileIcon,
                  width: 20.w,
                  height: 20.h,
                  fit: BoxFit.fitHeight,
                ),
                SizedBox(width: 6.w),
              ],
              Text(
                authorName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  fontSize: 16.sp,
                  letterSpacing: 0,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '${'datePublished'.tr} $publishedDate',
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontSize: 12.sp,
              color: AppColors.textWhiteOpacity60,
            ),
          ),
        ],
      ),
    );
  }
}

