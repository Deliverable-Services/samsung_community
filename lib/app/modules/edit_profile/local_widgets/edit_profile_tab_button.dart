import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileTabButton extends StatelessWidget {
  final String text;
  final int index;
  final EditProfileController controller;

  const EditProfileTabButton({
    super.key,
    required this.text,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.selectedTab.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: AppColors.white,
                fontFamily: 'Samsung Sharp Sans',
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              height: 2.h,
              decoration: BoxDecoration(
                color: isActive ? AppColors.linkBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
          ],
        ),
      );
    });
  }
}
