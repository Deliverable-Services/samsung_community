import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../helper_widgets/animated_press.dart';
import 'app_colors.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final Color textColor;
  final double? width;
  final double? height;
  final bool isEnabled;
  final bool isLoading;
  final String? iconPath;

  const AppButton({
    super.key,
    required this.onTap,
    required this.text,
    this.textColor = AppColors.white,
    this.width,
    this.height,
    this.isEnabled = true,
    this.isLoading = false,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: SizedBox(
        width: width ?? 350.w,
        height: height ?? 48.h,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 7.864322662353516,
              sigmaY: 7.864322662353516,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(214, 214, 214, 0.4),
                    Color.fromRGBO(112, 112, 112, 0.4),
                  ],
                  stops: [0.0, 1.0],
                ),
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  width: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
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
              padding: EdgeInsets.only(
                top: 3.h,
                right: 18.w,
                bottom: 3.h,
                left: 18.w,
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (iconPath != null) ...[
                            if (iconPath!.toLowerCase().endsWith('.svg'))
                              SvgPicture.asset(
                                iconPath!,
                                width: 24.w,
                                height: 24.h,
                              )
                            else
                              Image.asset(iconPath!, width: 24.w, height: 24.h),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            text,
                            style: TextStyle(
                              color: textColor,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );

    // Disable button if not enabled OR if loading
    final isButtonEnabled = isEnabled && !isLoading;

    if (isButtonEnabled) {
      return AnimatedPress(
        onTap: onTap,
        scaleFactor: 0.95,
        opacityFactor: 0.7,
        child: buttonContent,
      );
    } else {
      return GestureDetector(onTap: null, child: buttonContent);
    }
  }
}
