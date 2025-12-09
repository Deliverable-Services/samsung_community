import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class OptionItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const OptionItem({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 92.w,
        height: 24.h,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(214, 214, 214, 0.2),
                    Color.fromRGBO(112, 112, 112, 0.2),
                  ],
                  stops: [0.0, 1.0],
                ),
                border: Border.all(
                  width: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 3.57.h),
                    blurRadius: 7.97.r,
                    spreadRadius: 0,
                    color: AppColors.optionBoxShadow,
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.optionTextGradientStart,
                        AppColors.optionTextGradientEnd,
                      ],
                      stops: [0.0, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        letterSpacing: 0,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  letterSpacing: 0,
                  color: AppColors.white,
                  height: 24 / 16,
                ),
                textScaler: const TextScaler.linear(1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
