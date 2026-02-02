import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/constants/app_colors.dart';
import '../../feed/local_widgets/feed_card/feed_card.dart';
import '../controllers/user_profile_controller.dart';

class UserPostsList extends GetView<UserProfileController> {
  const UserPostsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPosts.value) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.linkBlue),
            ),
          ),
        );
      }

      if (controller.postsList.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(40.h),
            child: Center(
              child: Text(
                'noPostsYet'.tr,
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
          top: 12.h,
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
