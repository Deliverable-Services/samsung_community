import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_button.dart';
import '../controllers/chat_screen_controller.dart';

class ChatUnblockButton extends StatelessWidget {
  final ChatScreenController controller;

  const ChatUnblockButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: AppButton(
        onTap: controller.unblockUser,
        text: 'unblock'.tr,
        width: double.infinity,
      ),
    );
  }
}

