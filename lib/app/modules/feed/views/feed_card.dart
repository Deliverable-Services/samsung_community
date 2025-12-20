import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';

class FeedCard extends StatelessWidget {
  final String authorName;
  final String? authorAvatar;
  final bool isVerified;
  final String publishedDate;
  final String title;
  final String description;
  final bool isLiked;
  final int likesCount;
  final String? likedByUsername;
  final int commentsCount;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onViewComments;
  final VoidCallback? onMenuTap;
  final VoidCallback? onReadMore;

  const FeedCard({
    super.key,
    required this.authorName,
    this.authorAvatar,
    this.isVerified = false,
    required this.publishedDate,
    required this.title,
    required this.description,
    this.isLiked = false,
    this.likesCount = 0,
    this.likedByUsername,
    this.commentsCount = 0,
    this.onLike,
    this.onComment,
    this.onViewComments,
    this.onMenuTap,
    this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            offset: Offset(0, 7.43.h),
            blurRadius: 16.6.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              _avatar(),
              SizedBox(width: 12.w),
              _authorInfo(),
              _menuButton(),
            ],
          ),

          SizedBox(height: 20.h),
          const Divider(color: AppColors.dividerLight),
          SizedBox(height: 20.h),

          /// TITLE
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),

          SizedBox(height: 8.h),

          /// DESCRIPTION
          Text(
            description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhiteOpacity70,
            ),
          ),

          SizedBox(height: 6.h),

          GestureDetector(
            onTap: onReadMore,
            child: Text(
              'readMore'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.accentBlue,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: 20.h),
          const Divider(color: AppColors.dividerLight),
          SizedBox(height: 14.h),

          /// LIKE / COMMENT
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppColors.likePink : AppColors.textWhite,
                  size: 21.sp,
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: onComment,
                child: Image.asset(
                  AppImages.commentIcon,
                  width: 16.w,
                  height: 16.h,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          GestureDetector(
            onTap: onViewComments,
            child: Text(
              'viewAllComments'.trParams({'count': commentsCount.toString()}),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textWhiteOpacity60,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return SizedBox(
      width: 57.h,
      height: 57.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: authorAvatar?.isNotEmpty == true
            ? CachedNetworkImage(
                imageUrl: authorAvatar!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Image.asset(AppImages.avatar),
              )
            : Image.asset(AppImages.avatar),
      ),
    );
  }

  Widget _authorInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isVerified) ...[
                Image.asset(AppImages.verifiedProfileIcon, width: 20.w),
                SizedBox(width: 6.w),
              ],
              Text(
                authorName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '${'datePublished'.tr} $publishedDate',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textWhiteOpacity60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton() {
    return GestureDetector(
      onTap: onMenuTap,
      child: Icon(Icons.more_vert, color: AppColors.textWhite),
    );
  }
}
