import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.placeholder,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 105.w,
            height: 14.h,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                letterSpacing: 0,
                color: AppColors.white,
                height: 22 / 22,
              ),
              textScaler: const TextScaler.linear(1.0),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: 350.w,
            height: 48.h,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.inputGradientStart,
                    AppColors.inputGradientEnd,
                  ],
                  stops: [0.0, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x40000000),
                    offset: Offset(2.w, -2.h),
                    blurRadius: 2.r,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  letterSpacing: 0,
                  color: AppColors.white,
                  height: 22 / 14,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: placeholder,
                  hintStyle: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    letterSpacing: 0,
                    color: AppColors.white.withOpacity(0.3),
                    height: 22 / 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.only(
                    top: 16.h,
                    right: 20.w,
                    bottom: 16.h,
                    left: 20.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
