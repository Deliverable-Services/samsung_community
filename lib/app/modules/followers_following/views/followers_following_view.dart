import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/common_loader.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../controllers/followers_following_controller.dart';
import '../local_widgets/follower_following_item.dart';
import '../local_widgets/followers_following_header.dart';
import '../local_widgets/followers_following_search_bar.dart';

class FollowersFollowingView extends GetView<FollowersFollowingController> {
  const FollowersFollowingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: TitleAppBar(text: '', isLeading: false),
      body: SafeArea(
        child: Column(
          children: [
            Obx(
              () => FollowersFollowingHeader(
                followersCount: controller.followers.length,
                followingCount: controller.following.length,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: 20.h,
              ),
              child: const FollowersFollowingSearchBar(),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }

                final isFollowersTab = controller.selectedTab.value == 0;
                final users = isFollowersTab
                    ? controller.filteredFollowers
                    : controller.filteredFollowing;

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      isFollowersTab ? 'noFollowers'.tr : 'notFollowingAnyone'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textWhiteOpacity70,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return FollowerFollowingItem(
                      user: user,
                      isFollowersTab: isFollowersTab,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
