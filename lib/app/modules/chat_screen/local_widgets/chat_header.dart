import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/back_button.dart';
import '../../../data/helper_widgets/custom_circle_button.dart';
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
          CustomCircleButton(
            onTap: () => controller.showChatOptionsModal(),
            image: Icon(Icons.more_vert, color: AppColors.white, size: 20.sp),
            width: 32.w,
            height: 32.w,
            rotation: 1.5708, // 90 degrees in radians
          ),
          CustomBackButton(rotation: 0, onTap: () => Get.back()),
        ],
      ),
    );
  }
}
