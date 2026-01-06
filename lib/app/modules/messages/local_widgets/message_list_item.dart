import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../routes/app_pages.dart';
import '../controllers/messages_controller.dart';

class MessageListItem extends StatelessWidget {
  final String username;
  final String message;
  final bool hasUnread;
  final String? conversationId;
  final String? userId;
  final String? avatarUrl;
  final int unreadCount;

  const MessageListItem({
    super.key,
    required this.username,
    required this.message,
    required this.hasUnread,
    this.conversationId,
    this.userId,
    this.avatarUrl,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final messagesController = Get.find<MessagesController>();
    return InkWell(
      onTap: () async {
        if (conversationId != null || userId != null) {
          await Get.toNamed(
            Routes.CHAT_SCREEN,
            arguments: {
              'conversationId': conversationId ?? '',
              'userId': userId,
            },
          );
          messagesController.refreshConversations();
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
                child: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Image.asset(AppImages.avatar, fit: BoxFit.cover),
                        errorWidget: (context, url, error) =>
                            Image.asset(AppImages.avatar, fit: BoxFit.cover),
                      )
                    : Image.asset(AppImages.avatar, fit: BoxFit.cover),
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
                    unreadCount.toString(),
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
