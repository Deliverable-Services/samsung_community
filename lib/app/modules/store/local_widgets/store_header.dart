import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';

class StoreHeader extends StatelessWidget {
  const StoreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'exploreStore'.tr,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            height: 24 / 16,
            letterSpacing: 0,
            color: AppColors.white,
          ),
          textScaler: const TextScaler.linear(1.0),
        ),
        SizedBox(height: 5.h),
        Padding(
          padding: EdgeInsets.only(right: 30.w),
          child: Text(
            'storeDescription'.tr,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontSize: 14.sp,
              height: 22 / 14,
              letterSpacing: 0,
              color: AppColors.white,
            ),
            textScaler: const TextScaler.linear(1.0),
          ),
        ),
      ],
    );
  }
}

