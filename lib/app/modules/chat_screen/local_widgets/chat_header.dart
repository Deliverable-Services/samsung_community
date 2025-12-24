import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/back_button.dart';
import '../controllers/chat_screen_controller.dart';

class ChatHeader extends StatelessWidget {
  final ChatScreenController controller;

  const ChatHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
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
          CustomBackButton(rotation: 0, onTap: () => Get.back()),
        ],
      ),
    );
  }
}
