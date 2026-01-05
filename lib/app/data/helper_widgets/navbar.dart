import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import 'animated_press.dart';
import 'side_menu.dart';

class Navbar extends StatelessWidget {
  final int totalPoints;

  const Navbar({super.key, required this.totalPoints});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [_buildLeftContainer(), _buildRightContainer(context)],
    );
  }

  Widget _buildLeftContainer() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36.w,
          height: 33.559242248535156.h,
          child: SvgPicture.asset(
            AppImages.logo,
            width: 36.w,
            height: 33.559242248535156.h,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: 16.w),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'totalPoints'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  letterSpacing: 0,
                  color: AppColors.white,
                  height: 1,
                ),
                textScaler: const TextScaler.linear(1.0),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12.w,
                    height: 12.h,
                    child: SvgPicture.asset(
                      AppImages.pointsIcon,
                      width: 12.w,
                      height: 12.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    '$totalPoints',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      letterSpacing: 0,
                      color: AppColors.white,
                      height: 26.32 / 14,
                    ),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightContainer(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedIconContainer(
          child: Image.asset(
            AppImages.notificationIcon,
            width: 24.w,
            height: 24.h,
            fit: BoxFit.contain,
          ),
          onTap: () {
            // TODO: Handle notification tap
          },
        ),
        SizedBox(width: 12.w),
        _buildAnimatedIconContainer(
          child: Image.asset(
            AppImages.hamburgerIcon,
            width: 24.w,
            height: 24.h,
            fit: BoxFit.contain,
          ),
          onTap: () {
            SideMenu.show(context);
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedIconContainer({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return AnimatedPress(
      onTap: onTap,
      scaleFactor: 0.95,
      opacityFactor: 0.7,
      child: _buildIconContainer(child: child),
    );
  }

  Widget _buildIconContainer({required Widget child}) {
    return Container(
      width: 38.w,
      height: 38.h,
      padding: EdgeInsets.only(top: 8.55.h, bottom: 8.55.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(109.68.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(214, 214, 214, 0.2),
            Color.fromRGBO(112, 112, 112, 0.2),
          ],
          stops: [0.0, 1.0],
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
            spreadRadius: -1,
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
          child: Center(child: child),
        ),
      ),
    );
  }
}
