import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/constants/app_colors.dart';
import '../controllers/chat_screen_controller.dart';
import 'chat_message_bubble.dart';

class ChatMessagesList extends StatelessWidget {
  final ChatScreenController controller;

  const ChatMessagesList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.messages.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Text(
              'noMessagesYet'.tr,
              style: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: AppColors.textWhiteOpacity70,
              ),
            ),
          ),
        );
      }

      String? lastDateKey;
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          final dateKey = DateFormat('MMM dd').format(message.createdAt);
          final timeStr = DateFormat('hh:mm a').format(message.createdAt);
          final dateTimeStr = '${dateKey.toUpperCase()}, $timeStr';
          final showDate = lastDateKey != dateKey;
          if (showDate) {
            lastDateKey = dateKey;
          }

          return Column(
            children: [
              if (showDate)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    dateTimeStr,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: AppColors.textWhiteOpacity70,
                      fontFamily: 'Samsung Sharp Sans',
                    ),
                  ),
                ),
              ChatMessageBubble(
                message: message.content,
                isFromCurrentUser: message.isFromCurrentUser,
                avatarUrl: message.isFromCurrentUser
                    ? null
                    : controller.otherUser.value?.profilePictureUrl,
              ),
            ],
          );
        },
      );
    });
  }
}
