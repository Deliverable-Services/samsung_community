import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import 'animated_press.dart';

class CustomCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget image;
  final double width;
  final double height;
  final double rotation;

  const CustomCircleButton({
    super.key,
    required this.onTap,
    required this.image,
    required this.width,
    required this.height,
    this.rotation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: onTap,
      scaleFactor: 0.95,
      opacityFactor: 0.7,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(89.48.r),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(214, 214, 214, 0.2),
              Color.fromRGBO(112, 112, 112, 0.2),
            ],
            stops: [0.0, 1.0],
          ),
          border: Border.all(width: 0.89, color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 6.65.h),
              blurRadius: 14.86.r,
              spreadRadius: 0,
              color: const Color(0x1A000000),
            ),
            BoxShadow(
              offset: Offset(0, 26.97.h),
              blurRadius: 26.97.r,
              spreadRadius: 0,
              color: const Color(0x17000000),
            ),
            BoxShadow(
              offset: Offset(0, 60.99.h),
              blurRadius: 36.75.r,
              spreadRadius: 0,
              color: const Color(0x0D000000),
            ),
            BoxShadow(
              offset: Offset(0, 108.29.h),
              blurRadius: 43.39.r,
              spreadRadius: 0,
              color: const Color(0x03000000),
            ),
            BoxShadow(
              offset: Offset(0, 169.28.h),
              blurRadius: 47.3.r,
              spreadRadius: 0,
              color: const Color(0x00000000),
            ),
            BoxShadow(
              offset: Offset(1.79.w, -1.79.h),
              blurRadius: 1.79.r,
              spreadRadius: 0,
              color: AppColors.backButtonInsetShadow,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(89.48.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 7.036915302276611,
              sigmaY: 7.036915302276611,
            ),
            child: Center(
              child: Transform.rotate(angle: rotation, child: image),
            ),
          ),
        ),
      ),
    );
  }
}
