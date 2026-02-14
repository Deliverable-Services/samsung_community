import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../controllers/notifications_controller.dart';
import '../repo/notifications_model.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationItem item;

  const NotificationListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return InkWell(
      onTap: () => controller.handleNotificationTap(item),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isRead
                        ? AppColors.overlayContainerBackground
                        : AppColors.unfollowPink,
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: AppColors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: AppColors.white,
                          fontFamily: 'Samsung Sharp Sans',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textWhiteOpacity70,
                          fontFamily: 'Samsung Sharp Sans',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Blue dot at top right of the card
            if (!item.isRead)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.linkBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
