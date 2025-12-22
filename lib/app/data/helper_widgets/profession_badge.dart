import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class ProfessionBadge extends StatelessWidget {
  final String profession;

  const ProfessionBadge({super.key, required this.profession});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(214, 214, 214, 0.4),
            Color.fromRGBO(112, 112, 112, 0.4),
          ],
          stops: [-0.4925, 1.2388],
        ),
        border: Border.all(width: 1, color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 7.43.h),
            blurRadius: 16.6.r,
            color: const Color(0x1A000000),
          ),
          BoxShadow(
            offset: Offset(0, 30.15.h),
            blurRadius: 30.15.r,
            color: const Color(0x17000000),
          ),
          BoxShadow(
            offset: Offset(0, 68.16.h),
            blurRadius: 41.07.r,
            color: const Color(0x0D000000),
          ),
          BoxShadow(
            offset: Offset(0, 121.02.h),
            blurRadius: 48.5.r,
            color: const Color(0x03000000),
          ),
          BoxShadow(
            offset: Offset(0, 189.18.h),
            blurRadius: 52.87.r,
            color: const Color(0x00000000),
          ),
          BoxShadow(
            offset: Offset(2.w, -2.h),
            blurRadius: 2.r,
            spreadRadius: 0,
            color: const Color(0x40000000),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 7.864322662353516,
            sigmaY: 7.864322662353516,
          ),
          child: Text(
            profession,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
              fontSize: 12.sp,
              height: 24 / 12,
              letterSpacing: 0,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
