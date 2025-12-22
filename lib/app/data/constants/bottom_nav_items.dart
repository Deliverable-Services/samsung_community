import 'package:flutter/material.dart';
import 'package:samsung_community_mobile/app/modules/bottom_bar/controllers/bottom_bar_controller.dart';

import 'app_images.dart';

class BottomNavItem {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final bool Function() isActive;

  const BottomNavItem({
    required this.imagePath,
    required this.label,
    required this.onTap,
    required this.isActive,
  });
}

class BottomNavItems {
  BottomNavItems._();

  static List<BottomNavItem> getItems(
    BottomBarController controller,
    bool isBottomBar,
  ) {
    return [
      BottomNavItem(
        imagePath: AppImages.homeNavIcon,
        label: 'Home',
        onTap: () {
          controller.changeTab(0, isBottomBar);
        },
        isActive: () {
          if (!isBottomBar) {
            return false;
          }
          return controller.currentIndex.value == 0;
        },
      ),
      BottomNavItem(
        imagePath: AppImages.vodNavIcon,
        label: 'Vod',
        onTap: () {
          controller.changeTab(1, isBottomBar);
        },
        isActive: () {
          if (!isBottomBar) {
            return false;
          }
          return controller.currentIndex.value == 1;
        },
      ),
      BottomNavItem(
        imagePath: AppImages.academyNavIcon,
        label: 'Academy',
        onTap: () {
          controller.changeTab(2, isBottomBar);
        },
        isActive: () {
          if (!isBottomBar) {
            return false;
          }
          return controller.currentIndex.value == 2;
        },
      ),
      BottomNavItem(
        imagePath: AppImages.feedNavIcon,
        label: 'Feed',
        onTap: () {
          controller.changeTab(3, isBottomBar);
        },
        isActive: () {
          if (!isBottomBar) {
            return false;
          }
          return controller.currentIndex.value == 3;
        },
      ),
      BottomNavItem(
        imagePath: AppImages.eventsNavIcon,
        label: 'Events',
        onTap: () {
          controller.changeTab(4, isBottomBar);
        },
        isActive: () {
          if (!isBottomBar) {
            return false;
          }
          return controller.currentIndex.value == 4;
        },
      ),
    ];
  }
}
