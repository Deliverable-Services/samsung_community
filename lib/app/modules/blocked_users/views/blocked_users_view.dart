import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/common_loader.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../controllers/blocked_users_controller.dart';
import '../local_widgets/blocked_user_item.dart';
import '../local_widgets/blocked_users_search_bar.dart';

class BlockedUsersView extends GetView<BlockedUsersController> {
  const BlockedUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: TitleAppBar(text: 'blockedUsers'.tr, isLeading: false),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 40.h),
              child: const BlockedUsersSearchBar(),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoader();
                }

                if (controller.filteredBlockedUsers.isEmpty) {
                  return Center(
        child: Text(
                      'noBlockedUsers'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textWhiteOpacity70,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: controller.filteredBlockedUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.filteredBlockedUsers[index];
                    return BlockedUserItem(user: user);
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
