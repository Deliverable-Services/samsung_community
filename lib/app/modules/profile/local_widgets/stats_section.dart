import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/stat_card.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class StatsSection extends GetView<ProfileController> {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Expanded(
              child: StatCard(
                icon: AppImages.profilePostIcon,
                count: controller.postsCount,
                label: 'posts'.tr,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Obx(
            () => Expanded(
              child: StatCard(
                icon: AppImages.profileFollowersIcon,
                count: controller.followersCount,
                label: 'followers'.tr,
                onTap: () => Get.toNamed(
                  Routes.FOLLOWERS_FOLLOWING,
                  parameters: {'tab': 'followers'},
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Obx(
            () => Expanded(
              child: StatCard(
                icon: AppImages.profileFollowingIcon,
                count: controller.followingCount,
                label: 'following'.tr,
                onTap: () => Get.toNamed(
                  Routes.FOLLOWERS_FOLLOWING,
                  parameters: {'tab': 'following'},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
