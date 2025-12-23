import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../routes/app_pages.dart';

class MessageListItem extends StatelessWidget {
  final String username;
  final String message;
  final bool hasUnread;
  final String? conversationId;
  final String? userId;

  const MessageListItem({
    super.key,
    required this.username,
    required this.message,
    required this.hasUnread,
    this.conversationId,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (conversationId != null || userId != null) {
          Get.toNamed(
            Routes.CHAT_SCREEN,
            arguments: {
              'conversationId': conversationId ?? '',
              'userId': userId,
            },
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.overlayContainerBackground,
              ),
              child: ClipOval(
                child: Image.asset(AppImages.avatar, fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontFamily: 'Samsung Sharp Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Samsung Sharp Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: AppColors.textWhiteOpacity70,
                    ),
                  ),
                ],
              ),
            ),
            if (hasUnread) ...[
              SizedBox(width: 12.w),
              Container(
                width: 20.w,
                height: 20.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.unfollowPink,
                ),
                child: Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      fontFamily: 'Samsung Sharp Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
