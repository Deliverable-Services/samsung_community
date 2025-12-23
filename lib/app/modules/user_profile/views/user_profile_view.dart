import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/bottom_nav_bar.dart';
import '../../../data/helper_widgets/common_loader.dart';
import '../controllers/user_profile_controller.dart';
import '../local_widgets/user_posts_list.dart';
import '../local_widgets/user_profile_top_card.dart';
import '../../../data/helper_widgets/title_app_bar.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(text: '', isLeading: false),
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.user.value == null) {
                      return const Center(child: CommonLoader());
                    }
                    final user = controller.user.value;
                    return CustomScrollView(
                      key: ValueKey(
                        'user_profile_scroll_${user?.id ?? 'loading'}',
                      ),
                      slivers: const [
                        SliverToBoxAdapter(child: UserProfileTopCard()),
                        UserPostsList(),
                        SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    );
                  }),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 16.h),
                child: BottomNavBar(isBottomBar: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
