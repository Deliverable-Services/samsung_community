import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class BottomNavMenuItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const BottomNavMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minWidth: 0, maxWidth: 67.w),
        height: 62.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isActive
                ? [
                    const Color.fromRGBO(214, 214, 214, 0.4),
                    const Color.fromRGBO(112, 112, 112, 0.4),
                  ]
                : [
                    const Color.fromRGBO(214, 214, 214, 0.14),
                    const Color.fromRGBO(112, 112, 112, 0.14),
                  ],
            stops: const [0.0, 1.0],
          ),
          border: isActive
              ? Border.all(width: 1, color: Colors.white.withOpacity(0.5))
              : null,
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
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 7.864322662353516,
              sigmaY: 7.864322662353516,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 26.w, height: 26.h, child: icon),
                  SizedBox(height: 6.h),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                        height: 1,
                        letterSpacing: 0,
                        color: isActive
                            ? AppColors.white
                            : AppColors.navTextInactive,
                        fontFamily: 'Samsung Sharp Sans',
                      ),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
