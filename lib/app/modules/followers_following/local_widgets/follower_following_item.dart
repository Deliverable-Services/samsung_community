import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/models/user_model copy.dart';
import '../controllers/followers_following_controller.dart';

class FollowerFollowingItem extends GetView<FollowersFollowingController> {
  final UserModel user;
  final bool isFollowersTab;

  const FollowerFollowingItem({
    super.key,
    required this.user,
    required this.isFollowersTab,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.overlayContainerBackground,
            ),
            child: ClipOval(
              child:
                  user.profilePictureUrl != null &&
                      user.profilePictureUrl!.isNotEmpty
                  ? Image.network(
                      user.profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.overlayContainerBackground,
                          child: Icon(
                            Icons.person,
                            color: AppColors.textWhiteOpacity70,
                            size: 24.sp,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.overlayContainerBackground,
                      child: Icon(
                        Icons.person,
                        color: AppColors.textWhiteOpacity70,
                        size: 24.sp,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              user.fullName ?? 'username',
              style: TextStyle(fontSize: 14.sp, color: AppColors.white),
            ),
          ),
          SizedBox(width: 12.w),
          Row(
            children: [
              _buildMessageButton(),
              SizedBox(width: 8.w),
              _buildMoreButton(user.id),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: AppColors.overlayContainerBackground,
        ),
        child: Text(
          'message'.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(String userId) {
    return GestureDetector(
      onTap: () => _showMoreOptions(userId),
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.overlayContainerBackground,
        ),
        child: Icon(Icons.more_vert, color: AppColors.white, size: 20.sp),
      ),
    );
  }

  void _showMoreOptions(String userId) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.block, color: AppColors.white),
              title: Text('block'.tr, style: TextStyle(color: AppColors.white)),
              onTap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
