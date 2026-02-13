import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/constants/app_colors.dart';
import '../../../../data/constants/app_images.dart';
import '../../../../data/models/user_model copy.dart';

class FeedCardLikedBy extends StatelessWidget {
  final bool isLiked;
  final int likesCount;
  final List<UserModel>? likedByUsers;

  const FeedCardLikedBy({
    super.key,
    this.isLiked = false,
    this.likesCount = 0,
    this.likedByUsers,
  });

  @override
  Widget build(BuildContext context) {
    if (likesCount == 0) {
      return Text(
        'beTheFirstToLike'.tr,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textWhiteOpacity60,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    final usersToShow = likedByUsers?.take(3).toList() ?? [];

    return Row(
      children: [
        _StackedAvatars(users: usersToShow),
        SizedBox(width: 8.w),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'likedBy'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (usersToShow.isNotEmpty) ...[
                  TextSpan(
                    text: usersToShow.first.fullName ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (likesCount > 1) ...[
                    TextSpan(
                      text: 'and'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: '${likesCount - 1} ${'others'.tr}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ] else if (likesCount > 0) ...[
                  TextSpan(
                    text: '$likesCount ${'others'.tr}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StackedAvatars extends StatelessWidget {
  final List<UserModel> users;

  const _StackedAvatars({required this.users});

  @override
  Widget build(BuildContext context) {
    // Calculate width: last avatar position + avatar width
    // Avatar width is 18.w, positions are 0, 12.w, 24.w
    final avatarCount = users.length.clamp(1, 3);
    final lastPosition = (avatarCount - 1) * 12.w;
    final avatarWidth = 18.w;
    final containerWidth = lastPosition + avatarWidth;

    return SizedBox(
      width: containerWidth,
      height: 18.h,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (users.isNotEmpty) _AvatarItem(user: users[0], left: 0),
            if (users.length > 1) _AvatarItem(user: users[1], left: 12.w),
            if (users.length > 2) _AvatarItem(user: users[2], left: 24.w),
          ],
        ),
      ),
    );
  }
}

class _AvatarItem extends StatelessWidget {
  final UserModel? user;
  final double left;

  const _AvatarItem({this.user, required this.left});

  @override
  Widget build(BuildContext context) {
    final profilePictureUrl = user?.profilePictureUrl;
    final userId = user?.id;

    return Positioned(
      left: left,
      child: Container(
        key: ValueKey('avatar_${userId}_${profilePictureUrl ?? 'none'}'),
        width: 18.w,
        height: 18.h,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child:
            profilePictureUrl != null &&
                profilePictureUrl.isNotEmpty &&
                userId != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(9.r),
                child: CachedNetworkImage(
                  imageUrl: profilePictureUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  key: ValueKey('image_${userId}_$profilePictureUrl'),
                  placeholder: (context, url) => Image.asset(
                    AppImages.avatar,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fitHeight,
                  ),
                  errorWidget: (_, __, ___) => Image.asset(
                    AppImages.avatar,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              )
            : Image.asset(
                AppImages.avatar,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fitHeight,
              ),
      ),
    );
  }
}
