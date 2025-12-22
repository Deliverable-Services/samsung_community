import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/bottom_nav_bar.dart';
import '../../../data/helper_widgets/points_widget.dart';
import '../../../data/helper_widgets/profession_badge.dart';
import '../../../data/helper_widgets/stat_card.dart';
import '../../../modules/bottom_bar/controllers/bottom_bar_controller.dart';
import '../../feed/local_widgets/feed_card/feed_card.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Obx(() {
                final isLoading = controller.isLoading.value;
                final user = controller.user.value;

                if (isLoading && user == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return CustomScrollView(
                  key: ValueKey('profile_scroll_${user?.id ?? 'loading'}'),
                  slivers: [
                    _buildHeader(),
                    if (isLoading || user == null)
                      _buildProfileAndStatsLoader()
                    else ...[
                      SliverToBoxAdapter(
                        key: const ValueKey('profile_section'),
                        child: _buildProfileSectionContent(),
                      ),
                      SliverToBoxAdapter(
                        key: const ValueKey('stats_section'),
                        child: _buildStatsSectionContent(),
                      ),
                    ],
                    _buildPostsList(),
                  ],
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 16.h),
              child: const BottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              final bottomBarController = Get.find<BottomBarController>();
              return PointsWidget(
                points: bottomBarController.totalPoints.value,
              );
            }),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.overlayContainerBackground,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Image.asset(
                  AppImages.profileSettingsIcon,
                  width: 20.w,
                  height: 20.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAndStatsLoader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSectionContent() {
    return Obx(() {
      final user = controller.user.value;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Container(
              width: 105.w,
              height: 105.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3.w),
              ),
              child: ClipOval(
                child:
                    user?.profilePictureUrl != null &&
                        user!.profilePictureUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user.profilePictureUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.overlayContainerBackground,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) =>
                            Image.asset(AppImages.avatar, fit: BoxFit.cover),
                      )
                    : Image.asset(AppImages.avatar, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              user?.fullName ?? 'User',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 8.h),
            if (user?.bio != null && user!.bio!.isNotEmpty)
              Text(
                user.bio!,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontSize: 14.sp,
                  color: AppColors.textWhiteOpacity70,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 12.h),
            if (user?.profession != null && user!.profession!.isNotEmpty)
              ProfessionBadge(profession: user.profession!),
            SizedBox(height: 24.h),
          ],
        ),
      );
    });
  }

  Widget _buildStatsSectionContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: StatCard(
              icon: AppImages.profilePostIcon,
              count: controller.postsCount,
              label: 'posts'.tr,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: StatCard(
              icon: AppImages.profileFollowersIcon,
              count: controller.followersCount,
              label: 'followers'.tr,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: StatCard(
              icon: AppImages.profileFollowingIcon,
              count: controller.followingCount,
              label: 'following'.tr,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return Obx(() {
      if (controller.isLoadingPosts.value) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.postsList.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(40.h),
            child: Center(
              child: Text(
                'No posts yet',
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontSize: 16.sp,
                  color: AppColors.textWhiteOpacity70,
                ),
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 24.h,
          bottom: 22.h,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final post = controller.postsList[index];
            final likedUsers = controller.getLikedByUsers(post.id);

            return Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: FeedCard(
                contentId: post.id,
                authorName: post.userModel?.fullName ?? '',
                authorAvatar: post.userModel?.profilePictureUrl ?? '',
                isVerified: post.isPublished,
                publishedDate: DateFormat('dd/MM/yy').format(post.createdAt),
                title: post.title ?? '',
                description: post.description ?? '',
                mediaUrl:
                    post.mediaFileUrl ??
                    (post.mediaFiles != null && post.mediaFiles!.isNotEmpty
                        ? post.mediaFiles!.first
                        : null),
                thumbnailUrl: post.thumbnailUrl,
                isLiked: controller.isLiked(post.id),
                likesCount: post.likesCount,
                likedByUsers: likedUsers.isNotEmpty ? likedUsers : null,
                commentsCount: post.commentsCount,
                onLike: () => controller.toggleLike(post.id),
                onComment: () => controller.showCommentsModal(post.id),
                onViewComments: () => controller.showCommentsModal(post.id),
                onMenuTap: () => controller.showFeedActionModal(post.id),
                onAddComment: (contentId, commentText) =>
                    controller.addComment(contentId, commentText),
              ),
            );
          }, childCount: controller.postsList.length),
        ),
      );
    });
  }
}
