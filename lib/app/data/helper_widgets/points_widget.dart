import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';

class PointsWidget extends StatelessWidget {
  final int points;

  const PointsWidget({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74.w,
      height: 38.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(109.68.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(214, 214, 214, 0.2),
            Color.fromRGBO(112, 112, 112, 0.2),
          ],
          stops: [-0.4925, 1.2388],
        ),
        border: Border.all(width: 1.1, color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 8.15.h),
            blurRadius: 18.21.r,
            color: const Color(0x1A000000),
          ),
          BoxShadow(
            offset: Offset(0, 33.07.h),
            blurRadius: 33.07.r,
            color: const Color(0x17000000),
          ),
          BoxShadow(
            offset: Offset(0, 74.76.h),
            blurRadius: 45.05.r,
            color: const Color(0x0D000000),
          ),
          BoxShadow(
            offset: Offset(0, 132.74.h),
            blurRadius: 53.19.r,
            color: const Color(0x03000000),
          ),
          BoxShadow(
            offset: Offset(0, 207.5.h),
            blurRadius: 57.99.r,
            color: const Color(0x00000000),
          ),
          BoxShadow(
            offset: Offset(2.19.w, -2.19.h),
            blurRadius: 2.19.r,
            spreadRadius: 0,
            color: const Color(0x40000000),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(109.68.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8.625896453857422,
            sigmaY: 8.625896453857422,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18.w,
                height: 18.h,
                child: SvgPicture.asset(
                  AppImages.pointsIcon,
                  width: 12.w,
                  height: 12.h,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 4.39.w),
              Text(
                '$points',
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  height: 26.32 / 14,
                  letterSpacing: 0,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
