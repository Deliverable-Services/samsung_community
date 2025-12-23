import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/points_widget.dart';
import '../../../data/helper_widgets/settings_modal.dart';
import '../../bottom_bar/controllers/bottom_bar_controller.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              final bottomBarController = Get.find<BottomBarController>();
              return PointsWidget(
                points: bottomBarController.totalPoints.value,
              );
            }),
            GestureDetector(
              onTap: () {
                SettingsModal.show(Get.context!);
              },
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.overlayContainerBackground,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Image.asset(
                  AppImages.profileSettingsIcon,
                  width: 20.w,
                  height: 20.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
