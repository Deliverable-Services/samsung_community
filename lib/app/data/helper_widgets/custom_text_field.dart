import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.placeholder,
    this.maxLines = 1,
    this.width,
    this.validator,
    this.onChanged,
    this.readOnly = false,
  });

  final String? label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? placeholder;
  final int maxLines;
  final double? width;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            SizedBox(
              height: 14.h,
              child: Text(
                widget.label!,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
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
          ],
          Container(
            width: double.infinity,
            height: widget.maxLines == 1 ? 48.h : null,
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
            child: widget.maxLines == 1
                ? SizedBox(
                    height: 48.h,
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextFormField(
                        controller: widget.controller,
                        keyboardType: widget.keyboardType,
                        obscureText: widget.obscureText,
                        readOnly: widget.readOnly,
                        maxLines: 1,
                        minLines: 1,
                        validator: widget.validator,
                        onChanged: widget.onChanged,
                        style: TextStyle(
                          fontFamily: 'Samsung Sharp Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          letterSpacing: 0,
                          color: AppColors.white,
                          height: 22 / 14,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: widget.placeholder,
                          hintStyle: TextStyle(
                            fontFamily: 'Samsung Sharp Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                            letterSpacing: 0,
                            color: AppColors.white.withOpacity(0.3),
                            height: 22 / 14,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          errorStyle: const TextStyle(height: 0, fontSize: 0),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 20.w,
                          ),
                        ),
                      ),
                    ),
                  )
                : TextFormField(
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    obscureText: widget.obscureText,
                    readOnly: widget.readOnly,
                    maxLines: widget.maxLines,
                    minLines: widget.maxLines,
                    validator: widget.validator,
                    onChanged: widget.onChanged,
                    style: TextStyle(
                      fontFamily: 'Samsung Sharp Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      letterSpacing: 0,
                      color: AppColors.white,
                      height: 22 / 14,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: widget.placeholder,
                      hintStyle: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        letterSpacing: 0,
                        color: AppColors.white.withOpacity(0.3),
                        height: 22 / 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                      contentPadding: EdgeInsets.only(
                        top: 12.h,
                        left: 20.w,
                        right: 20.w,
                        bottom: 12.h,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
