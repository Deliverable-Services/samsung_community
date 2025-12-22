import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/modules/bottom_bar/controllers/bottom_bar_controller.dart';

import '../constants/app_colors.dart';
import '../constants/bottom_nav_items.dart';
import 'bottom_nav_menu_item.dart';

class BottomNavBar extends StatelessWidget {
  bool? isBottomBar;

  BottomNavBar({super.key, this.isBottomBar = true});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BottomBarController>();
    final items = BottomNavItems.getItems(controller, isBottomBar ?? true);

    return Container(
      width: 372.w,
      height: 79.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Flexible(
              child: Obx(() {
                controller.count.value;
                return BottomNavMenuItem(
                  icon: Image.asset(
                    items[i].imagePath,
                    width: 26.w,
                    height: 26.h,
                    fit: BoxFit.contain,
                  ),
                  label: items[i].label,
                  isActive: items[i].isActive(),
                  onTap: items[i].onTap,
                );
              }),
            ),
            if (i < items.length - 1) SizedBox(width: 6.w),
          ],
        ],
      ),
    );
  }
}
