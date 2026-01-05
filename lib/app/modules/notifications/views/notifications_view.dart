import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../controllers/notifications_controller.dart';
import 'notification_list_item.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header + Subtitle + Search
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const NotificationsHeader(),
                  SizedBox(height: 16.h),
                  NotificationsSearchBar(controller: controller),
                  SizedBox(height: 20.h),
                ],
              ),
            ),

            // 🔹 List
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
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: list.length,
                  itemBuilder: (_, index) {
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
  const NotificationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'notifications'.tr,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
            color: AppColors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'notificationsSubtitle'.tr,
          style: TextStyle(
            fontFamily: 'Samsung Sharp Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: AppColors.textWhiteOpacity70,
          ),
        ),
      ],
    );
  }
}
