import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/constants/app_colors.dart';
import '../../../../data/constants/app_images.dart';

class FeedCardCommentInput extends StatelessWidget {
  const FeedCardCommentInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24.w,
          height: 24.h,
          child: Image.asset(
            AppImages.avatar,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fitHeight,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: TextField(
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontSize: 12.sp,
              color: AppColors.textWhiteOpacity60,
            ),
            decoration: InputDecoration(
              hintText: 'addComment'.tr,
              hintStyle: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontSize: 12.sp,
                color: AppColors.textWhiteOpacity40,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

