import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/profile_picture_widget.dart';
import '../../../data/helper_widgets/stat_card.dart';
import '../../../routes/app_pages.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileTopCard extends GetView<UserProfileController> {
  const UserProfileTopCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return Container(
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfilePictureWidget(
                  width: 79.w,
                  imageUrl: user?.profilePictureUrl,
                  isLoading: controller.isLoading.value,
                  showAddIcon: false,
                  showAddText: false,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: AppImages.profilePostIcon,
                          count: controller.postsCount.value,
                          label: 'posts'.tr,
                          isBold: false,
                          showBoxDecoration: false,
                          padding: false,
                        ),
                      ),
                      Expanded(
                        child: StatCard(
                          icon: AppImages.profileFollowersIcon,
                          count: controller.followersCount.value,
                          label: 'followers'.tr,
                          isBold: false,
                          showBoxDecoration: false,
                          padding: false,
                          onTap: () => Get.toNamed(
                            Routes.FOLLOWERS_FOLLOWING,
                            parameters: {
                              'tab': 'followers',
                              'userId': controller.targetUserId,
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: StatCard(
                          icon: AppImages.profileFollowingIcon,
                          count: controller.followingCount.value,
                          label: 'following'.tr,
                          isBold: false,
                          showBoxDecoration: false,
                          padding: false,
                          onTap: () => Get.toNamed(
                            Routes.FOLLOWERS_FOLLOWING,
                            parameters: {
                              'tab': 'following',
                              'userId': controller.targetUserId,
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if ((user?.profession ?? '').isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(100.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 7.864322662353516,
                    sigmaY: 7.864322662353516,
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15.w, 6.h, 15.w, 6.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(214, 214, 214, 0.4),
                          Color.fromRGBO(112, 112, 112, 0.4),
                        ],
                        stops: [-0.4925, 1.2388],
                      ),
                      border: Border.all(
                        width: 1,
                        color: const Color.fromRGBO(242, 242, 242, 0.2),
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
                        BoxShadow(
                          offset: Offset(2.w, -2.h),
                          blurRadius: 2.r,
                          spreadRadius: 0,
                          color: const Color(0x40000000),
                        ),
                      ],
                    ),
                    child: Text(
                      user!.profession!,
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
            if ((user?.profession ?? '').isNotEmpty) SizedBox(height: 12.h),
            Text(
              user?.fullName ?? '',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 6.h),
            if ((user?.bio ?? '').isNotEmpty)
              Text(
                user!.bio!,
                style: TextStyle(
                  color: AppColors.textWhiteOpacity70,
                  fontSize: 13.sp,
                ),
              ),
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: _GradientButton(
                    text: controller.isFollowing.value
                        ? 'unfollow'.tr
                        : controller.isFollowedBy.value
                        ? 'followBack'.tr
                        : 'follow'.tr,
                    isLoading: controller.isLoadingFollow.value,
                    onTap: controller.followOrUnfollow,
                    isUnfollow: controller.isFollowing.value,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 4,
                  child: _OutlinedButton(
                    text: 'message'.tr,
                    onTap: controller.navigateToChat,
                  ),
                ),
              ],
            ),
            SizedBox(height: 17.h),
          ],
        ),
      );
    });
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isUnfollow;
  const _GradientButton({
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.isUnfollow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(109.68.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8.625896453857422,
            sigmaY: 8.625896453857422,
          ),
          child: Container(
            padding: isLoading
                ? EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 10.h)
                : EdgeInsets.fromLTRB(15.w, 6.h, 15.w, 6.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(109.68.r),
              gradient: isUnfollow
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF20AEFE), Color(0xFF135FFF)],
                      stops: [0.0041, 1.0042],
                    ),
              color: isUnfollow ? Colors.transparent : null,
              border: isUnfollow
                  ? Border.all(width: 1, color: AppColors.unfollowPink)
                  : null,
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
                  spreadRadius: 0,
                  color: const Color(0x40000000),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        height: 26.32 / 14,
                        letterSpacing: 0,
                        color: isUnfollow
                            ? AppColors.unfollowPink
                            : AppColors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _OutlinedButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(109.68.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8.625896453857422,
            sigmaY: 8.625896453857422,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(15.w, 6.h, 15.w, 6.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(109.68.r),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(214, 214, 214, 0.2),
                  Color.fromRGBO(112, 112, 112, 0.2),
                ],
                stops: [-0.4925, 1.2388],
              ),
              border: Border.all(
                width: 1.1,
                color: const Color.fromRGBO(242, 242, 242, 0.2),
              ),
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
                  spreadRadius: 0,
                  color: const Color(0x40000000),
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  height: 26.32 / 14,
                  letterSpacing: 0,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
