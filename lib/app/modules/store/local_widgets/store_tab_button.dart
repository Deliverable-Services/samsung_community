import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/constants/app_colors.dart';

class StoreTabButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const StoreTabButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            height: 2.h,
            decoration: BoxDecoration(
              color: isActive ? AppColors.linkBlue : AppColors.dividerLight,
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
        ],
      ),
    );
  }
}

