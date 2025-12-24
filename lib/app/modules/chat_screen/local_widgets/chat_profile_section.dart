import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/services/app_lifecycle_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/profile_picture_widget.dart';
import '../controllers/chat_screen_controller.dart';

class ChatProfileSection extends StatelessWidget {
  final ChatScreenController controller;

  const ChatProfileSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.otherUser.value;
      if (user == null) {
        return const SizedBox.shrink();
      }

      final isOnline = AppLifecycleService.isUserOnline(
        user.isOnline,
        user.lastSeenAt,
      );

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            ProfilePictureWidget(
              imageUrl: user.profilePictureUrl,
              width: 105.w,
              showAddText: false,
              showAddIcon: false,
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 9.w,
                  height: 9.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline
                        ? AppColors.activeIndicatorBackground
                        : AppColors.inactiveIndicatorBackground,
                    border: Border.all(
                      width: 1,
                      color: isOnline
                          ? AppColors.activeIndicatorBorder
                          : AppColors.inactiveIndicatorBorder,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  isOnline ? 'active'.tr : 'inactive'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.sp,
                    height: 22 / 14,
                    letterSpacing: 0,
                    color: isOnline
                        ? AppColors.activeIndicatorBorder
                        : AppColors.inactiveIndicatorBorder,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              user.fullName ?? 'user'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 8.h),
            if (user.bio != null && user.bio!.isNotEmpty)
              Text(
                user.bio!,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: AppColors.textWhiteOpacity70,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: controller.navigateToProfile,
              child: Container(
                width: 97.w,
                height: 35.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.r),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.createPostGradientStart,
                      AppColors.createPostGradientEnd,
                    ],
                    stops: [0.0041, 1.0042],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 7.43),
                      blurRadius: 16.6,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.09),
                      offset: const Offset(0, 30.15),
                      blurRadius: 30.15,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 68.16),
                      blurRadius: 41.07,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      offset: const Offset(0, 121.02),
                      blurRadius: 48.5,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.0),
                      offset: const Offset(0, 189.18),
                      blurRadius: 52.87,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(2, -2),
                      blurRadius: 2,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.r),
                  child: SizedBox(
                    child: Center(
                      child: Text(
                        'seeProfile'.tr,
                        style: TextStyle(
                          fontFamily: 'Samsung Sharp Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          height: 24 / 12,
                          letterSpacing: 0,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
