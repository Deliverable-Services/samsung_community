import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';

class StatCard extends StatelessWidget {
  final String icon;
  final int count;
  final String label;

  const StatCard({
    super.key,
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.61.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.9.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(214, 214, 214, 0.1),
            Color.fromRGBO(112, 112, 112, 0.1),
          ],
          stops: [-0.4925, 1.2388],
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4.38.h),
            blurRadius: 9.79.r,
            color: const Color(0x1A000000),
          ),
          BoxShadow(
            offset: Offset(0, 17.78.h),
            blurRadius: 17.78.r,
            color: const Color(0x17000000),
          ),
          BoxShadow(
            offset: Offset(0, 40.19.h),
            blurRadius: 24.22.r,
            color: const Color(0x0D000000),
          ),
          BoxShadow(
            offset: Offset(0, 71.36.h),
            blurRadius: 28.6.r,
            color: const Color(0x03000000),
          ),
          BoxShadow(
            offset: Offset(0, 111.56.h),
            blurRadius: 31.17.r,
            color: const Color(0x00000000),
          ),
          BoxShadow(
            offset: Offset(1.18.w, -1.18.h),
            blurRadius: 1.18.r,
            spreadRadius: 0,
            color: const Color(0x40000000),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.9.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4.637411117553711,
            sigmaY: 4.637411117553711,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    height: 14.15 / 18,
                    letterSpacing: 0,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14.w,
                      height: 14.h,
                      child: SvgPicture.asset(
                        AppImages.pointsIcon,
                        width: 14.w,
                        height: 14.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFBEBEBE), Color(0xFFFFFFFF)],
                        stops: [0.0101, 1.1984],
                      ).createShader(bounds),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Samsung Sharp Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          height: 14.15 / 12,
                          letterSpacing: 0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
