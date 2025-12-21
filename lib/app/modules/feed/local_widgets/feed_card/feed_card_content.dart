import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/constants/app_colors.dart';

class FeedCardContent extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onReadMore;

  const FeedCardContent({
    super.key,
    required this.title,
    required this.description,
    this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            color: AppColors.textWhite,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontSize: 14.sp,
                  color: AppColors.textWhiteOpacity70,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        GestureDetector(
          onTap: onReadMore,
          child: Text(
            'readMore'.tr,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontSize: 14.sp,
              color: AppColors.accentBlue,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
