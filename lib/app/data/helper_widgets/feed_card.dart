import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_images.dart';

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
          // Header Section
          Row(
            children: [
              // Avatar
              SizedBox(
                width: 57.h,
                height: 57.h,
                child: Image.asset(
                  AppImages.avatar,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ),
              SizedBox(width: 12.w),
              // Author Name & Verification
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isVerified) ...[
                          Image.asset(
                            AppImages.verifiedProfileIcon,
                            width: 20.w,
                            height: 20.h,
                            fit: BoxFit.fitHeight,
                          ),
                          SizedBox(width: 6.w),
                        ],
                        Text(
                          authorName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            letterSpacing: 0,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Date Published: $publishedDate',
                      style: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontSize: 12.sp,
                        color: AppColors.textWhiteOpacity60,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Icon
              GestureDetector(
                onTap: onMenuTap,
                child: Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.buttonGradientStart,
                        AppColors.buttonGradientEnd,
                      ],
                      stops: [0.0, 1.0],
                    ),
                    border: Border.all(
                      width: 1.1,
                      style: BorderStyle.solid,
                      color: AppColors.transparent,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        offset: Offset(0, 8.15),
                        blurRadius: 18.21,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: AppColors.buttonShadowMedium,
                        offset: Offset(0, 33.07),
                        blurRadius: 33.07,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: AppColors.buttonShadowLight,
                        offset: Offset(0, 74.76),
                        blurRadius: 45.05,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: AppColors.buttonShadowExtraLight,
                        offset: Offset(0, 132.74),
                        blurRadius: 53.19,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: AppColors.shadowTransparent,
                        offset: Offset(0, 207.5),
                        blurRadius: 57.99,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: 1.5708,
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.textWhite,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          const Divider(color: AppColors.dividerLight, thickness: 1, height: 1),
          SizedBox(height: 20.h),

          // Title
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: AppColors.textWhite,
            ),
          ),
          SizedBox(height: 8.h),
          // Description with Read More
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontSize: 14.sp,
                    color: AppColors.textWhiteOpacity70,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 05.h),
          GestureDetector(
            onTap: onReadMore,
            child: Text(
              'read more',
              style: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontSize: 14.sp,
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          const Divider(color: AppColors.dividerLight, thickness: 1, height: 1),
          SizedBox(height: 20.h),
          Row(
            children: [
              SizedBox(
                width: 60.w,
                child: Stack(
                  children: [
                    Container(
                      width: 18.w,
                      height: 18.h,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(
                        AppImages.avatar,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    Positioned(
                      left: 12.w,
                      child: Container(
                        width: 18.w,
                        height: 18.h,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset(
                          AppImages.avatar,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24.w,
                      child: Container(
                        width: 18.w,
                        height: 18.h,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset(
                          AppImages.avatar,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Transform.translate(
                  offset: Offset(-8.w, 0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Liked by ',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (isLiked && likedByUsername != null) ...[
                          TextSpan(
                            text: likedByUsername,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' and ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                        TextSpan(
                          text: '$likesCount others',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
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
                  fit: BoxFit.fitHeight,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: onViewComments,
            child: Text(
              'View all $commentsCount comments',
              style: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontSize: 12.sp,
                color: AppColors.textWhiteOpacity60,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              SizedBox(
                width: 24.w,
                height: 24.h,
                child: Image.asset(
                  AppImages.avatar,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontSize: 12.sp,
                    color: AppColors.textWhiteOpacity60,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add comment...',
                    hintStyle: TextStyle(
                      fontFamily: 'Samsung Sharp Sans',
                      fontSize: 12.sp,
                      color: AppColors.textWhiteOpacity40,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
