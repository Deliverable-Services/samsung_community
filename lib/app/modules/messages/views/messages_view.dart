import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/back_button.dart';
import '../../../data/helper_widgets/bottom_nav_bar.dart';
import '../controllers/messages_controller.dart';
import '../local_widgets/messages_search_bar.dart';
import '../local_widgets/message_list_item.dart';

class MessagesView extends GetView<MessagesController> {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'messages'.tr,
                              style: TextStyle(
                                fontFamily: 'Samsung Sharp Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 20.sp,
                                color: AppColors.white,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'messagesSubtitle'.tr,
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
                      CustomBackButton(rotation: 0, onTap: () => Get.back()),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  MessagesSearchBar(controller: controller),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.linkBlue,
                      ),
                    ),
                  );
                }

                final filteredConvs = controller.filteredConversations;
                if (filteredConvs.isEmpty) {
                  return Center(
                    child: Text(
                      'noMessagesYet'.tr,
                      style: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: AppColors.textWhiteOpacity70,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: filteredConvs.length,
                  itemBuilder: (context, index) {
                    final conv = filteredConvs[index];
                    return MessageListItem(
                      username: conv.otherUserName ?? 'user'.tr,
                      message: conv.lastMessage ?? '',
                      hasUnread: conv.unreadCount > 0,
                      conversationId: conv.conversationId,
                      userId: conv.otherUserId,
                      avatarUrl: conv.otherUserAvatar,
                      unreadCount: conv.unreadCount,
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 16.h),
              child: BottomNavBar(isBottomBar: false),
            ),
          ],
        ),
      ),
    );
  }
}

// Message item widget moved to ../local_widgets/message_list_item.dart
