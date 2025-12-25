import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/bottom_nav_bar.dart';
import '../../../data/helper_widgets/common_loader.dart';
import '../../../data/helper_widgets/create_post_button.dart';
import '../controllers/profile_controller.dart';
import '../local_widgets/posts_list.dart';
import '../local_widgets/profile_header.dart';
import '../local_widgets/profile_section.dart';
import '../local_widgets/stats_section.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.refreshProfileData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Obx(() {
                    final isLoading = controller.isLoading.value;
                    final user = controller.userRx.value;

                    return CustomScrollView(
                      key: ValueKey('profile_scroll_${user?.id ?? 'loading'}'),
                      slivers: [
                        const ProfileHeader(),
                        if (isLoading || user == null)
                          const CommonSliverLoader()
                        else ...[
                          SliverToBoxAdapter(
                            key: const ValueKey('profile_section'),
                            child: const ProfileSection(),
                          ),
                          SliverToBoxAdapter(
                            key: const ValueKey('stats_section'),
                            child: const StatsSection(),
                          ),
                          const PostsList(),
                        ],
                      ],
                    );
                  }),
                ),
              ],
            ),
            CreatePostButton(
              onSuccess: () {
                controller.loadUserPosts();
                controller.loadUserProfile();
              },
              onFailure: () {},
              bottomOffset: 10.h,
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
