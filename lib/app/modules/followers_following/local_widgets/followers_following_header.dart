import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../controllers/followers_following_controller.dart';

class FollowersFollowingHeader extends GetView<FollowersFollowingController> {
  final int followersCount;
  final int followingCount;

  const FollowersFollowingHeader({
    super.key,
    required this.followersCount,
    required this.followingCount,
  });

  @override
  String? get tag => Get.parameters['userId'] ?? 'current_user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              text: '$followersCount ${'followers'.tr}',
              index: 0,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              text: '$followingCount ${'following'.tr}',
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({required String text, required int index}) {
    return Obx(() {
      final isActive = controller.selectedTab.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: AppColors.white,
                fontFamily: 'Samsung Sharp Sans',
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              height: 2.h,
              decoration: BoxDecoration(
                color: isActive ? AppColors.linkBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
          ],
        ),
      );
    });
  }
}
