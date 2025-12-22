import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../controllers/chat_screen_controller.dart';

class ChatHeader extends StatelessWidget {
  final ChatScreenController controller;

  const ChatHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.overlayContainerBackground,
            ),
            child: Icon(Icons.more_vert, color: AppColors.white, size: 20.sp),
          ),
          Text(
            'chat'.tr,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              color: AppColors.white,
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.overlayContainerBackground,
              ),
              child: Icon(
                Icons.arrow_forward,
                color: AppColors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
