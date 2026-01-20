import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/title_app_bar.dart';
import '../controllers/notifications_controller.dart';
import 'notification_list_item.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(text: 'notifications'.tr, isLeading: false),
      backgroundColor: AppColors.primary,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NotificationsHeader(controller: controller),
                  NotificationsSearchBar(controller: controller),
                  SizedBox(height: 20.h),
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.linkBlue),
                  );
                }

                final list = controller.filteredNotifications;

                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'noNotificationsFound'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textWhiteOpacity70,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount:
                      list.length + (controller.hasMoreData.value ? 1 : 0),
                  itemBuilder: (_, index) {
                    if (index == list.length) {
                      return controller.isLoadingMore.value
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.linkBlue,
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    }
                    return NotificationListItem(item: list[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsSearchBar extends StatelessWidget {
  final NotificationsController controller;

  const NotificationsSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 13.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment(-1.0, 0.0),
          end: Alignment(1.0, 0.0),
          colors: [AppColors.searchGradientStart, AppColors.searchGradientEnd],
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.white.withOpacity(0.6)),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              style: TextStyle(fontSize: 14.sp, color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'searchNotifications'.tr,
                hintStyle: TextStyle(color: AppColors.white.withOpacity(0.4)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsHeader extends StatelessWidget {
  final NotificationsController controller;
  const NotificationsHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => controller.markAllAsRead(),
          child: Text(
            'markAllAsRead'.tr,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.linkBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
