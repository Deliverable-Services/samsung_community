import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          children: [
            ProfilePictureWidget(
              imageUrl: user.profilePictureUrl,
              width: 120.w,
              showAddText: false,
              showAddIcon: false,
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'active'.tr,
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              user.fullName ?? 'user'.tr,
              style: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 8.h),
            if (user.bio != null && user.bio!.isNotEmpty)
              Text(
                user.bio!,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
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
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.createPostGradientStart, AppColors.createPostGradientEnd],
                  ),
                ),
                child: Text(
                  'seeProfile'.tr,
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                    color: AppColors.white,
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

