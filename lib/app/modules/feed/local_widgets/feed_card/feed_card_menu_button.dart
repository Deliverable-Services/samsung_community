import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/constants/app_colors.dart';

class FeedCardMenuButton extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const FeedCardMenuButton({
    super.key,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onMenuTap,
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.buttonGradientStart,
              AppColors.buttonGradientEnd,
            ],
            stops: [0.0, 1.0],
          ),
          border: Border.all(
            width: 1.1,
            style: BorderStyle.solid,
            color: AppColors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              offset: Offset(0, 8.15),
              blurRadius: 18.21,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.buttonShadowMedium,
              offset: Offset(0, 33.07),
              blurRadius: 33.07,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.buttonShadowLight,
              offset: Offset(0, 74.76),
              blurRadius: 45.05,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.buttonShadowExtraLight,
              offset: Offset(0, 132.74),
              blurRadius: 53.19,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.shadowTransparent,
              offset: Offset(0, 207.5),
              blurRadius: 57.99,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Transform.rotate(
          angle: 1.5708,
          child: Icon(
            Icons.more_vert,
            color: AppColors.textWhite,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}

