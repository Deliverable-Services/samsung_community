import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/constants/app_colors.dart';
import '../../../../data/models/user_model copy.dart';
import 'feed_card_header.dart';
import 'feed_card_content.dart';
import 'feed_card_media.dart';
import 'feed_card_liked_by.dart';
import 'feed_card_action_buttons.dart';
import 'feed_card_view_comments.dart';
import 'feed_card_comment_input.dart';

class FeedCard extends StatelessWidget {
  final String contentId;
  final String authorName;
  final String? authorAvatar;
  final bool isVerified;
  final String publishedDate;
  final String title;
  final String description;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final bool isLiked;
  final int likesCount;
  final List<UserModel>? likedByUsers;
  final int commentsCount;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onViewComments;
  final VoidCallback? onMenuTap;
  final Function(String, String)? onAddComment;

  const FeedCard({
    super.key,
    required this.contentId,
    required this.authorName,
    this.authorAvatar,
    this.isVerified = false,
    required this.publishedDate,
    required this.title,
    required this.description,
    this.mediaUrl,
    this.thumbnailUrl,
    this.isLiked = false,
    this.likesCount = 0,
    this.likedByUsers,
    this.commentsCount = 0,
    this.onLike,
    this.onComment,
    this.onViewComments,
    this.onMenuTap,
    this.onAddComment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
          stops: [-0.4925, 1.2388],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            offset: Offset(0, 7.43.h),
            blurRadius: 16.6.r,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FeedCardHeader(
            authorName: authorName,
            authorAvatar: authorAvatar,
            isVerified: isVerified,
            publishedDate: publishedDate,
            onMenuTap: onMenuTap,
          ),
          SizedBox(height: 20.h),
          const Divider(color: AppColors.dividerLight, thickness: 1, height: 1),
          SizedBox(height: 20.h),
          FeedCardContent(title: title, description: description),
          if (mediaUrl != null && mediaUrl!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            FeedCardMedia(
              mediaUrl: mediaUrl,
              thumbnailUrl: thumbnailUrl,
              contentId: contentId,
            ),
          ],
          SizedBox(height: 20.h),
          const Divider(color: AppColors.dividerLight, thickness: 1, height: 1),
          SizedBox(height: 20.h),
          FeedCardLikedBy(
            isLiked: isLiked,
            likesCount: likesCount,
            likedByUsers: likedByUsers,
          ),
          SizedBox(height: 14.h),
          FeedCardActionButtons(
            isLiked: isLiked,
            onLike: onLike,
            onComment: onComment,
          ),
          SizedBox(height: 20.h),
          FeedCardViewComments(
            commentsCount: commentsCount,
            onViewComments: onViewComments,
          ),
          FeedCardCommentInput(
            contentId: contentId,
            onComment: onComment,
            onAddComment: onAddComment,
          ),
        ],
      ),
    );
  }
}
